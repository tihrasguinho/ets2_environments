import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ets2_environments/src/controllers/main_controller.dart';
import 'package:ets2_environments/src/entities/homedir_entity.dart';
import 'package:ets2_environments/src/extensions/build_context_extension.dart';
import 'package:ets2_environments/src/extensions/list_extension.dart';
import 'package:ets2_environments/src/extensions/row_extension.dart';
import 'package:ets2_environments/src/mixins/stateful_mixin.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../dialogs/add_homedir_dialog.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with StatefulMixin {
  final MainController controller = GetIt.I.get<MainController>();

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      await Future.wait(
        [
          controller.environmentStore.tryFindDefaultGamedirAutomatically(),
          controller.environmentStore.tryFindGamePathAutomatically(),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.environmentStore,
      builder: (context, state, child) {
        return state.when(
          onInitial: () => const SizedBox(),
          onLoading: () => const Center(child: CircularProgressIndicator()),
          onError: (error) => Center(child: Text(error)),
          onSuccess: (environment) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  tooltip: environment.gamePath.isNotEmpty ? 'Open in Explorer ${environment.gamePath}' : 'Please select the game path first!',
                  onPressed: () async => controller.pickGamePath(() => pickPath(context)),
                  icon: Container(
                    foregroundDecoration: environment.gamePath.isNotEmpty
                        ? null
                        : const BoxDecoration(
                            color: Colors.grey,
                            backgroundBlendMode: BlendMode.saturation,
                          ),
                    child: Image.asset(
                      'assets/ets2-logo.png',
                      height: 36.0,
                      width: 36.0,
                      cacheWidth: 36,
                      cacheHeight: 36,
                    ),
                  ),
                ),
                title: Text(
                  'ETS2 Environments - ${environment.gamePath.isNotEmpty ? 'Euro Truck Simulator 2 found!' : 'Euro Truck Simulator 2 not found!'}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pushNamed('/settings'),
                    icon: const Icon(Icons.settings_rounded),
                  ),
                  const SizedBox(width: 8.0),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView.separated(
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: environment.homedirs.length,
                        itemBuilder: (context, index) {
                          final homedir = environment.homedirs[index];

                          return ListTile(
                            onTap: () {},
                            title: Text(homedir.name),
                            subtitle: Text(homedir.homedirPathView),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    showLoading('Loading profiles...');

                                    final profiles = await controller.getProfilesList(homedir.directory.path);

                                    hideLoading();

                                    if (!mounted) return;
                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: SizedBox(
                                            width: 512.0,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                const SizedBox(height: 16.0),
                                                Text(
                                                  'Profiles (Local Only)',
                                                  textAlign: TextAlign.center,
                                                  style: context.textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (profiles.isEmpty) const SizedBox(height: 16.0),
                                                if (profiles.isEmpty)
                                                  Text(
                                                    'No local profiles found!',
                                                    textAlign: TextAlign.center,
                                                    style: context.textTheme.titleMedium?.copyWith(),
                                                  ),
                                                if (profiles.isEmpty) const SizedBox(height: 16.0),
                                                if (profiles.isNotEmpty)
                                                  Flexible(
                                                    child: ListView.separated(
                                                      separatorBuilder: (context, index) => const Divider(),
                                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                                      shrinkWrap: true,
                                                      itemCount: profiles.length,
                                                      itemBuilder: (context, index) {
                                                        final profile = profiles[index];

                                                        return ListTile(
                                                          title: Text('${profile.profileName} - ${profile.companyName}'),
                                                          subtitle: Text(
                                                            'Active mods\n${profile.activeMods.map((e) => ' - $e').join('\n')}',
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  tooltip: 'Show local profiles',
                                  icon: const Icon(Icons.people_rounded),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final path = await pickPath(
                                      context,
                                      title: 'Select your mod',
                                      fsType: FilesystemType.file,
                                    );

                                    if (path == null) return;

                                    if (path.isEmpty) return;

                                    final modFile = File(path);

                                    if (!await modFile.exists()) return;

                                    showLoading('Adding mod to this homedir');

                                    final modBytes = await modFile.readAsBytes();

                                    final filename = p.basename(path);

                                    final modDir = Directory(p.join(homedir.directory.path, 'Euro Truck Simulator 2', 'mod'));

                                    if (!await modDir.exists()) await modDir.create(recursive: true);

                                    await File(p.join(modDir.path, filename)).writeAsBytes(modBytes);

                                    hideLoading();
                                  },
                                  tooltip: 'Add new mods to this homedir',
                                  icon: const Icon(Icons.add_rounded),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    showLoading('Loading mods list details\nIt may take a while depending on the number of mods');

                                    final modListDetails = await controller.getModListDetails(homedir.directory.path);

                                    if (!mounted) return;

                                    hideLoading();

                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: SizedBox(
                                            width: 512.0,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                const SizedBox(height: 16.0),
                                                Text(
                                                  'Mods (Local Only)',
                                                  textAlign: TextAlign.center,
                                                  style: context.textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (modListDetails.isEmpty) const SizedBox(height: 16.0),
                                                if (modListDetails.isEmpty)
                                                  Text(
                                                    'No local mods found!',
                                                    textAlign: TextAlign.center,
                                                    style: context.textTheme.titleMedium?.copyWith(),
                                                  ),
                                                if (modListDetails.isEmpty) const SizedBox(height: 16.0),
                                                if (modListDetails.isNotEmpty)
                                                  Flexible(
                                                    child: ListView.separated(
                                                      separatorBuilder: (context, index) => const Divider(),
                                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                                      shrinkWrap: true,
                                                      itemCount: modListDetails.length,
                                                      itemBuilder: (context, index) {
                                                        final mod = modListDetails[index];

                                                        return ListTile(
                                                          title: Text(mod.displayName),
                                                          subtitle: Text(
                                                            'Author: ${mod.author}\nVersion: ${mod.packageVersion}${mod.categories.isNotEmpty ? '\nCategories: ${mod.categories.join(', ')}' : ''}${mod.compatibleVersions.isNotEmpty ? '\nCompatible versions: ${mod.compatibleVersions.join(', ')}' : ''}',
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  tooltip: 'Show the mods list details',
                                  icon: const Icon(Icons.format_list_bulleted),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final uri = Uri.file(homedir.homedirPathView);

                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                  tooltip: 'Open this homedir in Explorer',
                                  icon: const Icon(Icons.folder_rounded),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    showLoading('Starting game...');

                                    await controller.startGameFromHomedir(
                                      homedir.directory.path,
                                      environment.launchArguments,
                                      environment.closeAppWhenGameLaunch,
                                    );

                                    hideLoading();
                                  },
                                  tooltip: 'Start game from this homedir',
                                  color: Colors.green,
                                  icon: const Icon(Icons.play_arrow_rounded),
                                ),
                              ],
                            ).withSpacing(16.0),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                elevation: 2,
                onPressed: () async {
                  final homedir = await showDialog<HomedirEntity>(
                    context: context,
                    builder: (context) => AddHomedirDialog(
                      defaultHomedirPath: environment.homedirs.firstWhereOrNull((e) => e.isDefault)?.directory,
                    ),
                  );

                  if (homedir != null) {
                    controller.environmentStore.addHomedir(homedir);
                  }
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add new homedir'),
              ),
            );
          },
        );
      },
    );
  }
}

List<String> getDrivesOnWindows() {
  final data = (Process.runSync('wmic', ['logicaldisk', 'get', 'caption'], stdoutEncoding: const SystemEncoding())).stdout as String;

  return LineSplitter.split(data).map((string) => string.trim()).where((string) => string.isNotEmpty).skip(1).toList();
}

Future<String?> pickPath(
  BuildContext context, {
  String title = 'Select a folder to pick',
  FilesystemType fsType = FilesystemType.folder,
}) async {
  final drivers = getDrivesOnWindows();

  String? drive;

  if (drivers.length > 1) {
    final selectedDrive = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select witch drive you want to use'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final driver in drivers)
                ListTile(
                  title: Text(driver),
                  onTap: () => Navigator.of(context).pop(driver),
                ),
            ],
          ),
        );
      },
    );

    if (selectedDrive != null) {
      drive = selectedDrive;
    }
  } else {
    drive = drivers.first;
  }

  if (drive == null) return null;

  if (!context.mounted) return null;

  final path = await FilesystemPicker.openDialog(
    context: context,
    title: title,
    rootDirectory: Directory(p.normalize('$drive/')),
    fsType: fsType,
    pickText: 'Select',
    requestPermission: () async => true,
    itemFilter: (fsEntity, path, name) {
      if (name.startsWith(r'$') || name.startsWith('.') || ['system volume information', 'windows', 'recovery', 'temp'].contains(name.toLowerCase())) {
        return false;
      }

      return true;
    },
    rootName: '$drive/',
    directory: Directory(p.normalize('$drive/')),
  );

  return path;
}

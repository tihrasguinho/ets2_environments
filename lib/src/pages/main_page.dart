import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ets2_environments/src/controllers/main_controller.dart';
import 'package:ets2_environments/src/dialogs/add_homedir_dialog.dart';
import 'package:ets2_environments/src/entities/homedir_entity.dart';
import 'package:ets2_environments/src/extensions/build_context_extension.dart';
import 'package:ets2_environments/src/extensions/column_extension.dart';
import 'package:ets2_environments/src/extensions/list_extension.dart';
import 'package:ets2_environments/src/extensions/row_extension.dart';
import 'package:ets2_environments/src/mixins/stateful_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with StatefulMixin {
  final MainController controller = GetIt.I.get<MainController>();

  Future<void> onPopupMenuSelected(String value, Directory homedir) async {
    switch (value) {
      case 'List Local Profiles':
        {
          showLoading('Loading profiles...');

          final profiles = await controller.getProfilesList(homedir.path);

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

          break;
        }
      case 'List Local Mods':
        {
          showLoading('Loading mods list details\nIt may take a while depending on the number of mods');

          final modListDetails = await controller.getModListDetails(homedir.path);

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

          break;
        }
      case 'Add Mods':
        {
          showLoading();

          await controller.pickModFiles(homedir);

          hideLoading();

          break;
        }
      case 'Open in Explorer':
        {
          final uri = Uri.file(p.join(homedir.path, 'Euro Truck Simulator 2'));

          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }

          break;
        }
      default:
        {
          break;
        }
    }
  }

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      controller.environmentStore.loadFromLocalStorage(true);

      await controller.environmentStore.tryFindGamePathAutomatically();

      await controller.environmentStore.tryFindDefaultGamedirAutomatically();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.environmentStore,
      builder: (context, state, child) {
        return state.when(
          onInitial: () => const Material(),
          onLoading: () => const Material(child: Center(child: CircularProgressIndicator())),
          onError: (error) => Material(
            child: Center(
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          onSuccess: (environment) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  tooltip: environment.gamePath.isNotEmpty ? 'Open in Explorer ${environment.gamePath}' : 'Please select the game path first!',
                  onPressed: () async => await controller.pickGamePath(showErrorDialog),
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
                  'ETS2 Environments${environment.gamePath.isNotEmpty ? '' : ' - Euro Truck Simulator 2 not found!'}',
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
                            subtitle: Text(homedir.directory.path),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                PopupMenuButton<String>(
                                  onSelected: (value) => onPopupMenuSelected(value, homedir.directory),
                                  itemBuilder: (context) {
                                    return List.from(
                                      <String>[
                                        'List Local Profiles',
                                        'List Local Mods',
                                        'Add Mods',
                                        'Open in Explorer',
                                        'Remove',
                                      ].map(
                                        (item) {
                                          return PopupMenuItem(value: item, child: Text(item));
                                        },
                                      ),
                                    );
                                  },
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
                  if (environment.gamePath.isEmpty) {
                    return await showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: SizedBox(
                            width: 512.0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Error!',
                                      textAlign: TextAlign.center,
                                      style: context.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Text(
                                    'Please select the game path first!',
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: ButtonStyle(fixedSize: MaterialStateProperty.all(const Size(52.0 * 2, 48.0))),
                                    child: const Text('Ok'),
                                  ),
                                ],
                              ).withSpacing(16.0),
                            ),
                          ),
                        );
                      },
                    );
                  }

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

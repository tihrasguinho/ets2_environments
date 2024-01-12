import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ets2_environments/src/entities/homedir_entity.dart';
import 'package:ets2_environments/src/entities/mod_entity.dart';
import 'package:ets2_environments/src/entities/profile_entity.dart';
import 'package:ets2_environments/src/enums/system_architecture.dart';
import 'package:ets2_environments/src/extensions/build_context_extension.dart';
import 'package:ets2_environments/src/extensions/list_extension.dart';
import 'package:ets2_environments/src/extensions/row_extension.dart';
import 'package:ets2_environments/src/stores/environment_store.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
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

class _MainPageState extends State<MainPage> {
  final EnvironmentStore environmentStore = GetIt.I.get<EnvironmentStore>();

  Future<void> pickGamePath() async {
    if (environmentStore.value.environment.gamePath.isNotEmpty) {
      final uri = Uri.file(p.dirname(environmentStore.value.environment.gamePath));

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
      return;
    }

    final path = await pickFolderPath(context);

    if (path == null) return;

    if (!File(p.join(path, 'bin', 'win_x64', 'eurotrucks2.exe')).existsSync()) {
      return;
    }

    environmentStore.setGamePath(path);
  }

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      await Future.wait(
        [
          environmentStore.tryFindDefaultGamedirAutomatically(),
          environmentStore.tryFindGamePathAutomatically(),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: environmentStore,
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
                  onPressed: pickGamePath,
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
                                  onPressed: () {},
                                  tooltip: 'Show local profiles',
                                  icon: const Icon(Icons.people_rounded),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final modListDetails = await getModListDetails(homedir.directory.path);

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
                                                  'Mods list details',
                                                  textAlign: TextAlign.center,
                                                  style: context.textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
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
                                  icon: const Icon(Icons.list_alt_rounded),
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
                                  onPressed: () => startGameFromHomedir(
                                    environment.gamePath,
                                    homedir.directory.path,
                                    environment.launchArguments,
                                    environment.closeAppWhenGameLaunch,
                                  ),
                                  tooltip: 'Start game from this homedir',
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
                    environmentStore.addHomedir(homedir);
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

Future<String?> pickFolderPath(
  BuildContext context, {
  String title = 'Select a folder to pick',
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
    fsType: FilesystemType.folder,
    pickText: 'Select',
    requestPermission: () async => true,
    itemFilter: (fsEntity, path, name) {
      if (name.startsWith(r'$') || ['system volume information', 'windows', 'recovery', 'temp'].contains(name.toLowerCase())) {
        return false;
      }

      return true;
    },
    rootName: '$drive/',
    directory: Directory(p.normalize('$drive/')),
  );

  return path;
}

Future<List<ModEntity>> getModListDetails(String path) async {
  final modDir = Directory(p.join(path, 'Euro Truck Simulator 2', 'mod'));

  if (!modDir.existsSync()) return [];

  final modList = modDir.listSync();

  if (modList.isEmpty) return [];

  final modListNames = <ModEntity>[];

  for (final mod in modList) {
    if (mod is File) {
      final sxcPath = switch (kDebugMode) {
        true => getSystemArchitecture() == SystemArchitecture.x64 ? './assets/sxc/sxc64.exe' : './assets/sxc/sxc.exe',
        false => getSystemArchitecture() == SystemArchitecture.x64 ? './data/flutter_assets/assets/sxc/sxc64.exe' : './data/flutter_assets/assets/sxc/sxc.exe',
      };

      await Process.run(
        sxcPath,
        [
          mod.path,
          '-f',
          'manifest.sii',
          '-oc',
          p.join(modDir.path, 'temp'),
        ],
      );

      final manifest = File(p.join(modDir.path, 'temp', 'manifest.sii'));

      if (await manifest.exists()) {
        final manifestContent = await manifest.readAsString();

        final packageVersion = RegExp(r'package_version: "(.*)"').firstMatch(manifestContent)?.group(1);

        final displayName = RegExp(r'display_name: "(.*)"').firstMatch(manifestContent)?.group(1);

        final author = RegExp(r'author: "(.*)"').firstMatch(manifestContent)?.group(1);

        final categories = RegExp(r'category\[\]: "(.*)"').allMatches(manifestContent).map((e) => e.group(1) ?? 'N/A').toList();

        final compatibleVersions = RegExp(r'compatible_versions\[\]: "(.*)"').allMatches(manifestContent).map((e) => e.group(1) ?? 'N/A').toList();

        modListNames.add(
          ModEntity(
            displayName: displayName ?? 'N/A',
            packageVersion: packageVersion ?? 'N/A',
            author: author ?? 'N/A',
            categories: categories,
            compatibleVersions: compatibleVersions,
          ),
        );

        await Directory(p.join(modDir.path, 'temp')).delete(recursive: true);
      } else {
        modListNames.add(
          ModEntity(
            displayName: mod.path.split(r'\').last,
            packageVersion: 'N/A',
            author: 'N/A',
            categories: [],
            compatibleVersions: [],
          ),
        );
      }
    }
  }

  return modListNames;
}

Future<List<ProfileEntity>> getProfilesList(String path) async {
  final profilesDir = Directory(p.join(path, 'Euro Truck Simulator 2', 'profiles'));

  if (!await profilesDir.exists()) return [];

  final profilesDirList = profilesDir.listSync();

  if (profilesDirList.isEmpty) return [];

  final profiles = <ProfileEntity>[];

  for (final profileDir in profilesDirList) {
    if (profileDir is Directory) {
      final profile = File(p.join(profileDir.path, 'profile.sii'));

      if (await profile.exists()) {
        final profileContent = await profile.readAsBytes();

        final decoded = utf8.decode(profileContent, allowMalformed: true);

        if (decoded.startsWith(RegExp(r'SiiNunit'))) {
          final companyName = RegExp(r'company_name: ["]?(.*)["]?').firstMatch(decoded)?.group(1)?.replaceAll('"', '');

          final profileName = RegExp(r'profile_name: ["]?(.*)["]?').firstMatch(decoded)?.group(1)?.replaceAll('"', '');

          final activeMods = RegExp(r'active_mods\[[0-9]{1,}\]: ["]?(.*)["]?').allMatches(decoded).map((e) {
            return e.group(1)?.split('|').last.replaceAll('"', '') ?? 'N/A';
          }).toList();

          profiles.add(
            ProfileEntity(
              companyName: companyName ?? 'N/A',
              profileName: profileName ?? 'N/A',
              activeMods: activeMods,
            ),
          );
        } else {
          final profileTemp = File(p.join(profileDir.path, 'profileTemp.sii'));

          final decryptPath = switch (kDebugMode) {
            true => './assets/sii_decrypt/SII_Decrypt.exe',
            false => './data/flutter_assets/assets/sii_decrypt/SII_Decrypt.exe',
          };

          await Process.run(decryptPath, [profile.path, profileTemp.path]);

          if (!await profileTemp.exists()) {
            continue;
          }

          final profileContent = await profileTemp.readAsString();

          final companyName = RegExp(r'company_name: ["]?(.*)["]?').firstMatch(profileContent)?.group(1)?.replaceAll('"', '');

          final profileName = RegExp(r'profile_name: ["]?(.*)["]?').firstMatch(profileContent)?.group(1)?.replaceAll('"', '');

          final activeMods = RegExp(r'active_mods\[[0-9]{1,}\]: ["]?(.*)["]?').allMatches(profileContent).map((e) {
            return e.group(1)?.split('|').last.replaceAll('"', '') ?? 'N/A';
          }).toList();

          profiles.add(
            ProfileEntity(
              companyName: companyName ?? 'N/A',
              profileName: profileName ?? 'N/A',
              activeMods: activeMods,
            ),
          );

          await profileTemp.delete();
        }
      }
    }
  }

  return profiles;
}

void startGameFromHomedir(
  String gamePath,
  String homedirPath, [
  List<String> launchArguments = const [],
  bool closeAppWhenGameLaunch = true,
]) async {
  if (gamePath.isEmpty) return;

  await Process.run(
    gamePath,
    [
      '-homedir',
      homedirPath,
      ...launchArguments,
    ],
  );

  if (closeAppWhenGameLaunch) {
    exit(0);
  }
}

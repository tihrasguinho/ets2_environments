import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ets2_environments/src/controllers/main_controller.dart';
import 'package:ets2_environments/src/dialogs/add_homedir_dialog.dart';
import 'package:ets2_environments/src/entities/homedir_entity.dart';
import 'package:ets2_environments/src/extensions/build_context_extension.dart';
import 'package:ets2_environments/src/extensions/column_extension.dart';
import 'package:ets2_environments/src/extensions/row_extension.dart';
import 'package:ets2_environments/src/mixins/stateful_mixin.dart';
import 'package:ets2_environments/src/others/system_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with StatefulMixin {
  late final SystemManager manager = SystemManager.of(context);
  final MainController controller = GetIt.I.get<MainController>();

  void initTray() async {
    await trayManager.setIcon('assets/app_icon.ico');

    final menu = Menu(
      items: [
        MenuItem(
          key: 'show_ets2_environments',
          label: 'Show ETS2 Environments',
        ),
        MenuItem(
          key: 'close_ets2_environments',
          label: 'Close ETS2 Environments',
        ),
      ],
    );

    await trayManager.setContextMenu(menu);
  }

  Future<void> onPopupMenuSelected(String value, HomedirEntity homedir) async {
    switch (value) {
      case 'List Local Profiles':
        {
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

          break;
        }
      case 'List Local Mods':
        {
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

          break;
        }
      case 'Add Mods':
        {
          showLoading();

          await controller.pickModFiles(homedir.directory);

          hideLoading();

          break;
        }
      case 'Open in Explorer':
        {
          final uri = Uri.file(homedir.homedirPathView);

          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }

          break;
        }
      case 'Remove':
        {
          final result = await showDialog<({bool remove, bool keep})>(
            context: context,
            builder: (context) {
              final keepDir = ValueNotifier(false);

              return AlertDialog(
                title: Text(
                  'Remove This Homedir?',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Are you sure you want to remove this homedir?',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: keepDir,
                      builder: (context, value, child) {
                        return CheckboxListTile.adaptive(
                          value: value,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Keep the directory folder?',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          onChanged: (foo) {
                            keepDir.value = foo ?? false;
                          },
                        );
                      },
                    ),
                  ],
                ).withSpacing(16.0),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop((remove: false, keep: keepDir.value)),
                    child: const Text('Cancel!'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop((remove: true, keep: keepDir.value)),
                    child: const Text('Yes, remove it!'),
                  )
                ],
              );
            },
          );

          if (result?.remove ?? false) {
            controller.environmentStore.removeHomedir(homedir);

            if (!result!.keep) {
              await homedir.directory.delete(recursive: true);
            }
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
      controller.environmentStore.loadFromLocalStorage();

      await manager.tryFindGamePathAutomatically();

      await manager.tryFindDefaultGamedirAutomatically();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: manager.system.gameFileExists ? 'Open in Explorer ${manager.system.gameFile.path}' : 'Please select the game executable first!',
          onPressed: () async {
            if (manager.system.gameFileExists) {
              final uri = Uri.file(p.dirname(manager.system.gameFile.path));

              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            } else {
              final gameFile = await controller.pickGamePath();

              if (gameFile == null) {
                return showErrorDialog('Failed to pick game path');
              }

              return manager.setGameFile(gameFile);
            }
          },
          icon: Container(
            foregroundDecoration: manager.system.gameFileExists
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
          'ETS2 Environments${manager.system.gameFileExists ? '' : ' - Euro Truck Simulator 2 not found!'}',
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
      body: ValueListenableBuilder(
        valueListenable: controller.environmentStore,
        builder: (context, state, child) {
          return state.when(
            onInitial: () => const SizedBox(),
            onLoading: () => const Center(child: CircularProgressIndicator()),
            onError: (error) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_rounded,
                    size: 52.0,
                  ),
                  Text(
                    error,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            onSuccess: (environment) => Padding(
              padding: const EdgeInsets.all(16.0),
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

                            await manager.startGameFromHomedir(homedir);

                            hideLoading();
                          },
                          tooltip: 'Start game from this homedir',
                          color: Colors.green,
                          icon: const Icon(Icons.play_arrow_rounded),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) => onPopupMenuSelected(value, homedir),
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 2,
        onPressed: () async {
          if (!manager.system.gameFileExists) {
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
              defaultHomedirPath: manager.system.defaultHomedir,
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
  }
}

List<String> getDrivesOnWindows() {
  final data = (Process.runSync('wmic', ['logicaldisk', 'get', 'caption'], stdoutEncoding: const SystemEncoding())).stdout as String;

  return LineSplitter.split(data).map((string) => string.trim()).where((string) => string.isNotEmpty).skip(1).toList();
}

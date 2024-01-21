import 'dart:async';

import 'package:ets2_environments/l10n/l10n.dart';
import 'package:ets2_environments/src/presentation/controllers/main_controller.dart';
import 'package:ets2_environments/src/domain/entities/homedir_entity.dart';
import 'package:ets2_environments/src/presentation/extensions/build_context_extension.dart';
import 'package:ets2_environments/src/presentation/extensions/column_extension.dart';
import 'package:ets2_environments/src/presentation/extensions/row_extension.dart';
import 'package:ets2_environments/src/presentation/dialogs/add_homedir_dialog.dart';
import 'package:ets2_environments/src/presentation/mixins/stateful_mixin.dart';
import 'package:ets2_environments/src/presentation/others/system_manager.dart';
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
  late final I10n i10n = GetIt.I.get();
  late final SystemManager manager = SystemManager.of(context);
  final MainController controller = GetIt.I.get<MainController>();

  Future<void> onPopupMenuSelected(String value, HomedirEntity homedir) async {
    if (value == i10n.main_page_environments_profiles_item) {
      showLoading(i10n.main_page_environments_loading_profiles_list_message);

      final profiles = await controller.getProfilesList(homedir.directory.path);

      hideLoading();

      if (!mounted) return;

      return await showDialog(
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
                    i10n.main_page_environments_profiles_dialog_title,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (profiles.isEmpty) const SizedBox(height: 16.0),
                  if (profiles.isEmpty)
                    Text(
                      i10n.main_page_environments_profiles_dialog_empty_message,
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
                              '${i10n.main_page_environments_active_mods_dialog_subtitle}\n${profile.activeMods.map((e) => ' - $e').join('\n')}',
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
    } else if (value == i10n.main_page_environments_mods_item) {
      showLoading(i10n.main_page_environments_loading_mods_list_message);

      final modListDetails = await controller.getModListDetails(homedir.directory.path);

      if (!mounted) return;

      hideLoading();

      return await showDialog(
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
                    i10n.main_page_environments_mods_dialog_title,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (modListDetails.isEmpty) const SizedBox(height: 16.0),
                  if (modListDetails.isEmpty)
                    Text(
                      i10n.main_page_environments_mods_dialog_empty_message,
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
                              '${i10n.main_page_environments_mods_dialog_author_subtitle}: ${mod.author}\n${i10n.main_page_environments_mods_dialog_version_subtitle}: ${mod.packageVersion}${mod.categories.isNotEmpty ? '\n${i10n.main_page_environments_mods_dialog_categories_subtitle}: ${mod.categories.join(', ')}' : ''}${mod.compatibleVersions.isNotEmpty ? '\n${i10n.main_page_environments_mods_dialog_compatibility}: ${mod.compatibleVersions.join(', ')}' : ''}',
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
    } else if (value == i10n.main_page_environments_add_mods_item) {
      showLoading();

      await controller.pickModFiles(homedir.directory);

      hideLoading();
    } else if (value == i10n.main_page_environments_open_in_explorer_item) {
      final uri = Uri.file(homedir.homedirPathView);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else if (value == i10n.main_page_environments_enable_camera_zero_item || value == i10n.main_page_environments_disable_camera_zero_item) {
      controller.setEnableCameraZero(homedir);

      if (controller.enableCameraZero(homedir)) {
        showSuccessSnackbar(i10n.main_page_environments_enable_camera_zero_item_message);
      } else {
        showSuccessSnackbar(i10n.main_page_environments_disable_camera_zero_item_message);
      }
    } else if (value == i10n.main_page_environments_remove_item) {
      final result = await showDialog<({bool remove, bool keep})>(
        context: context,
        builder: (context) {
          final keepDir = ValueNotifier(false);

          return AlertDialog(
            title: Text(
              i10n.main_page_environments_remove_dialog_title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  i10n.main_page_environments_remove_dialog_subtitle,
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
                        i10n.main_page_environments_remove_dialog_check_title,
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
                child: Text(i10n.main_page_environments_remove_dialog_cancel_button),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop((remove: true, keep: keepDir.value)),
                child: Text(i10n.main_page_environments_remove_dialog_confirm_button),
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
          tooltip: manager.system.gameFileExists ? '${i10n.main_page_leading_tooltip} ${manager.system.gameFile.path}' : i10n.main_page_leading_tooltip_empty,
          onPressed: () async {
            if (manager.system.gameFileExists) {
              final uri = Uri.file(p.dirname(manager.system.gameFile.path));

              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            } else {
              final gameFile = await controller.pickGamePath();

              if (gameFile == null) {
                return showErrorDialog(i10n.main_page_pick_game_executable_dialog_error);
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
          'ETS2 Environments${manager.system.gameFileExists ? '' : ' - ${i10n.main_page_toolbar_game_not_found}'}',
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
            onSuccess: (environment) => environment.homedirs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_rounded,
                          size: 52.0,
                        ),
                        Text(
                          i10n.main_page_empty_environments_message,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: environment.homedirs.length,
                      itemBuilder: (context, index) {
                        final homedir = environment.homedirs[index];

                        return ListTile(
                          title: Text(homedir.name),
                          subtitle: Text(homedir.directory.path),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  showLoading(i10n.message_starting_the_game);

                                  await manager.startGameFromHomedir(homedir);

                                  hideLoading();
                                },
                                tooltip: i10n.main_page_environments_start_game_tooltip,
                                color: Colors.green,
                                icon: const Icon(Icons.play_arrow_rounded),
                              ),
                              PopupMenuButton<String>(
                                tooltip: i10n.main_page_environments_show_menu_tooltip,
                                onSelected: (value) => onPopupMenuSelected(value, homedir),
                                itemBuilder: (context) {
                                  return List.from(
                                    <String>[
                                      i10n.main_page_environments_profiles_item,
                                      i10n.main_page_environments_mods_item,
                                      i10n.main_page_environments_add_mods_item,
                                      i10n.main_page_environments_open_in_explorer_item,
                                      if (controller.enableCameraZero(homedir)) i10n.main_page_environments_disable_camera_zero_item,
                                      if (!controller.enableCameraZero(homedir)) i10n.main_page_environments_enable_camera_zero_item,
                                      i10n.main_page_environments_remove_item,
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
                          Text(
                            i10n.main_page_environments_error_dialog_title,
                            textAlign: TextAlign.center,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            i10n.main_page_environments_error_dialog_subtitle,
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
        label: Text(i10n.main_page_fab_title),
      ),
    );
  }
}

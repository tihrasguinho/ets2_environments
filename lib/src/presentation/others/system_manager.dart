import 'dart:io';

import 'package:ets2_environments/l10n/l10n.dart';
import 'package:ets2_environments/src/domain/entities/environment_entity.dart';
import 'package:ets2_environments/src/domain/entities/homedir_entity.dart';
import 'package:ets2_environments/src/domain/entities/system_entity.dart';
import 'package:ets2_environments/src/presentation/extensions/list_extension.dart';
import 'package:ets2_environments/src/presentation/others/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class SystemManager extends InheritedNotifier<ValueNotifier<SystemEntity>> {
  late final LocalStorage _localStorage;

  SystemManager({
    super.key,
    required super.child,
    required LocalStorage localStorage,
  }) : super(notifier: ValueNotifier(SystemEntity.defaultConfig())) {
    _localStorage = localStorage;
    _loadFromLocalStorage();
  }

  void _loadFromLocalStorage() {
    final systemJson = _localStorage.getString('system');

    if (systemJson == null) return;

    final system = SystemEntity.fromJson(systemJson);

    notifier!.value = system;
  }

  void setThemeMode(ThemeMode? mode) {
    final system = notifier!.value.copyWith(themeMode: mode);

    _localStorage.setString('system', system.toJson());

    notifier!.value = system;
  }

  void setLocale(Locale? locale) {
    final system = notifier!.value.copyWith(locale: locale);

    _localStorage.setString('system', system.toJson());

    notifier!.value = system;
  }

  void setMinimizeToTray(bool? value) {
    final system = notifier!.value.copyWith(minimizeToTray: value);

    _localStorage.setString('system', system.toJson());

    notifier!.value = system;
  }

  void setGameFile(File gameFile) async {
    final system = notifier!.value.copyWith(gameFile: gameFile);

    _localStorage.setString('system', system.toJson());

    notifier!.value = system;
  }

  void setDefaultHomedir(Directory defaultHomedir) async {
    final system = notifier!.value.copyWith(defaultHomedir: defaultHomedir);

    _localStorage.setString('system', system.toJson());

    notifier!.value = system;
  }

  void setLaunchArguments(List<String> args) async {
    final system = notifier!.value.copyWith(launchArguments: args);

    _localStorage.setString('system', system.toJson());

    notifier!.value = system;
  }

  SystemEntity get system => notifier!.value;

  Future<void> tryFindGamePathAutomatically() async {
    if (system.gameFileExists) return;

    final defaultPaths = <String>[
      p.normalize('C:/Program Files (x86)/Steam/steamapps/common/Euro Truck Simulator 2/bin/win_x64/eurotrucks2.exe'),
      p.normalize('C:/Program Files/Steam/steamapps/common/Euro Truck Simulator 2/bin/win_x64/eurotrucks2.exe')
    ];

    for (final path in defaultPaths) {
      if (File(path).existsSync()) {
        setGameFile(File(path));

        break;
      }
    }
  }

  Future<void> tryFindDefaultGamedirAutomatically() async {
    if (system.defaultHomedirExists) return;

    final documentsDir = await getApplicationDocumentsDirectory();

    final defaultHomedirPath = Directory(p.join(documentsDir.path, 'Euro Truck Simulator 2'));

    if (defaultHomedirPath.existsSync()) {
      setDefaultHomedir(defaultHomedirPath);
    }
  }

  Future<void> startGameFromHomedir(HomedirEntity homedir) async {
    if (!homedir.directory.existsSync()) return;

    await Process.run(
      system.gameFile.path,
      [
        '-homedir',
        homedir.directory.path,
        ...system.launchArguments,
      ],
    );

    if (system.minimizeToTray) {
      return await setupTrayMenu();
    }
  }

  Future<void> setupTrayMenu() async {
    if (!system.minimizeToTray) return;

    final I10n i10n = GetIt.I.get<I10n>();

    await windowManager.hide();

    await trayManager.setIcon('assets/app_icon.ico');

    await trayManager.setToolTip(i10n.tray_tooltip);

    final enviroment = _localStorage.getString('environment');

    final homedirs = switch (enviroment != null) {
      true => <HomedirEntity>[...EnvironmentEntity.fromJson(enviroment!).homedirs],
      false => <HomedirEntity>[],
    };

    await trayManager.setContextMenu(
      Menu(
        items: [
          if (homedirs.isNotEmpty)
            MenuItem(
              label: i10n.tray_menu_option_environment_title,
              disabled: true,
            ),
          if (homedirs.isNotEmpty) MenuItem.separator(),
          for (final homedir in homedirs)
            MenuItem(
              key: 'start_ets2_from_homedir_${homedir.name.toLowerCase().split(' ').join('_')}',
              label: '${i10n.tray_menu_option_start_from_specific_environment} ${homedir.name}',
            ),
          if (homedirs.isNotEmpty) MenuItem.separator(),
          MenuItem(
            key: 'close_ets2_environments',
            label: i10n.tray_menu_option_close,
          ),
        ],
      ),
    );
  }

  Future<void> removeTrayMenu() async {
    if (!system.minimizeToTray) return;

    await trayManager.destroy();

    await windowManager.show();
  }

  Future<void> onMenuItemTapped(MenuItem item) async {
    final enviroment = _localStorage.getString('environment');

    final homedirs = switch (enviroment != null) {
      true => <HomedirEntity>[...EnvironmentEntity.fromJson(enviroment!).homedirs],
      false => <HomedirEntity>[],
    };

    final homedir = homedirs.firstWhereOrNull((homedir) => 'start_ets2_from_homedir_${homedir.name.toLowerCase().split(' ').join('_')}' == item.key);

    if (homedir != null) {
      return await startGameFromHomedir(homedir);
    }

    if (item.key == 'close_ets2_environments') {
      exit(0);
    }
  }

  static SystemManager of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<SystemManager>()!;
}

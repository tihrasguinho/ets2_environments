import 'dart:io';

import 'package:ets2_environments/l10n/l10n.dart';
import 'package:ets2_environments/src/entities/homedir_entity.dart';
import 'package:ets2_environments/src/entities/system_entity.dart';
import 'package:ets2_environments/src/others/local_storage.dart';
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

  void setThemeMode(ThemeMode mode) async {
    final system = notifier!.value.copyWith(themeMode: mode);

    _localStorage.setString('system', system.toJson());

    notifier!.value = system;
  }

  void setLocale(Locale locale) async {
    final system = notifier!.value.copyWith(locale: locale);

    _localStorage.setString('system', system.toJson());

    notifier!.value = system;
  }

  void setMinimizeToTray(bool? value) async {
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

    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(
            key: 'show_ets2_environments',
            label: i10n.tray_menu_option_show,
          ),
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

  static SystemManager of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<SystemManager>()!;
}

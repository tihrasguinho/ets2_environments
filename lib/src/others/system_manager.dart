import 'dart:io';

import 'package:ets2_environments/src/entities/homedir_entity.dart';
import 'package:ets2_environments/src/entities/system_entity.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemManager extends InheritedNotifier<ValueNotifier<SystemEntity>> {
  late final SharedPreferences _preferences;

  SystemManager({
    super.key,
    required super.child,
    required SharedPreferences preferences,
  }) : super(notifier: ValueNotifier(SystemEntity.defaultConfig())) {
    _preferences = preferences;
    _loadFromLocalStorage();
  }

  void _loadFromLocalStorage() {
    final systemJson = _preferences.getString('system');

    if (systemJson == null) return;

    final system = SystemEntity.fromJson(systemJson);

    notifier!.value = system;
  }

  void setThemeMode(ThemeMode mode) async {
    final system = notifier!.value.copyWith(themeMode: mode);

    await _preferences.setString('system', system.toJson());

    notifier!.value = system;
  }

  void setCloseAppWhenGameLaunche(bool? value) async {
    final system = notifier!.value.copyWith(closeAppWhenGameLaunch: value);

    await _preferences.setString('system', system.toJson());

    notifier!.value = system;
  }

  void setMinimizeToTray(bool value) async {
    final system = notifier!.value.copyWith(minimizeToTray: value);

    await _preferences.setString('system', system.toJson());

    notifier!.value = system;
  }

  void setGameFile(File gameFile) async {
    final system = notifier!.value.copyWith(gameFile: gameFile);

    await _preferences.setString('system', system.toJson());

    notifier!.value = system;
  }

  void setDefaultHomedir(Directory defaultHomedir) async {
    final system = notifier!.value.copyWith(defaultHomedir: defaultHomedir);

    await _preferences.setString('system', system.toJson());

    notifier!.value = system;
  }

  void setLaunchArguments(List<String> args) async {
    final system = notifier!.value.copyWith(launchArguments: args);

    await _preferences.setString('system', system.toJson());

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
      // TODO: minimize to tray
    } else if (system.closeAppWhenGameLaunch) {
      exit(0);
    }
  }

  static SystemManager of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<SystemManager>()!;
}

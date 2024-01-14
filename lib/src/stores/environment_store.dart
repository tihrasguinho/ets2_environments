import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:ets2_environments/src/entities/environment_entity.dart';
import 'package:ets2_environments/src/entities/homedir_entity.dart';
import 'package:ets2_environments/src/states/environment_state.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class EnvironmentStore extends ValueNotifier<EnvironmentState> {
  final SharedPreferences _preferences;

  Timer? _timer;

  EnvironmentStore(this._preferences) : super(InitialEnvironmentState());

  void loadFromLocalStorage({bool verbose = false, void Function()? doWhenDone}) {
    if (verbose) log('Loading from local storage...', name: 'EnvironmentStore:loadFromLocalStorage');

    value = LoadingEnvironmentState();

    final environmentJson = _preferences.getString('environment');

    if (environmentJson == null) {
      value = SuccessEnvironmentState(value.environment);

      return doWhenDone?.call();
    } else {
      final environment = EnvironmentEntity.fromJson(environmentJson);

      value = SuccessEnvironmentState(environment);

      return doWhenDone?.call();
    }
  }

  void setGamePath(String path) async {
    final environment = value.environment.copyWith(gamePath: path);

    await _preferences.setString('environment', environment.toJson());

    value = SuccessEnvironmentState(environment);
  }

  void addHomedir(HomedirEntity homedir) async {
    final environment = value.environment.copyWith(homedirs: [...value.environment.homedirs, homedir]);

    await _preferences.setString('environment', environment.toJson());

    value = SuccessEnvironmentState(environment);
  }

  void removeHomedir(HomedirEntity homedir) async {
    final environment = value.environment.copyWith(homedirs: [...value.environment.homedirs]..remove(homedir));

    await _preferences.setString('environment', environment.toJson());

    value = SuccessEnvironmentState(environment);
  }

  void addLaunchArguments(String arguments) async {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () async {
      final environment = value.environment.copyWith(launchArguments: arguments.split(' '));

      await _preferences.setString('environment', environment.toJson());

      value = SuccessEnvironmentState(environment);
    });
  }

  void setCloseAppWhenGameLaunche(bool? foo) async {
    if (foo == null) return;

    final environment = value.environment.copyWith(closeAppWhenGameLaunch: foo);

    await _preferences.setString('environment', environment.toJson());

    value = SuccessEnvironmentState(environment);
  }

  void setThemeMode(ThemeMode mode) async {
    final environment = value.environment.copyWith(themeMode: mode);

    await _preferences.setString('environment', environment.toJson());

    value = SuccessEnvironmentState(environment);
  }

  Future<void> tryFindDefaultGamedirAutomatically() async {
    if (value.environment.homedirs.any((e) => e.isDefault)) return;

    final documentsDir = await getApplicationDocumentsDirectory();

    final defaultHomedirPath = Directory(p.join(documentsDir.path, 'Euro Truck Simulator 2'));

    if (defaultHomedirPath.existsSync()) {
      addHomedir(
        HomedirEntity(
          name: 'Default',
          directory: documentsDir,
          createdAt: DateTime.now(),
          isDefault: true,
        ),
      );
    }
  }

  Future<void> tryFindGamePathAutomatically() async {
    if (value.environment.gamePath.isNotEmpty) return;

    final defaultPaths = <String>[
      p.normalize('C:/Program Files (x86)/Steam/steamapps/common/Euro Truck Simulator 2/bin/win_x64/eurotrucks2.exe'),
      p.normalize('C:/Program Files/Steam/steamapps/common/Euro Truck Simulator 2/bin/win_x64/eurotrucks2.exe')
    ];

    for (final path in defaultPaths) {
      if (File(path).existsSync()) {
        setGamePath(path);

        break;
      }
    }
  }
}

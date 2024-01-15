import 'dart:developer';

import 'package:ets2_environments/l10n/l10n.dart';
import 'package:ets2_environments/src/entities/environment_entity.dart';
import 'package:ets2_environments/src/entities/homedir_entity.dart';
import 'package:ets2_environments/src/states/environment_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnvironmentStore extends ValueNotifier<EnvironmentState> {
  final SharedPreferences _preferences;

  EnvironmentStore(this._preferences) : super(InitialEnvironmentState());

  void loadFromLocalStorage({bool verbose = false}) {
    final i10n = GetIt.I.get<I10n>();

    if (verbose) log('Loading from local storage...', name: 'EnvironmentStore:loadFromLocalStorage');

    value = LoadingEnvironmentState();

    final environmentJson = _preferences.getString('environment');

    if (environmentJson == null) {
      value = ErrorEnvironmentState(i10n.main_page_empty_homedirs);
    } else {
      final environment = EnvironmentEntity.fromJson(environmentJson);

      if (environment.homedirs.isEmpty) {
        value = ErrorEnvironmentState(i10n.main_page_empty_homedirs);
      } else {
        value = SuccessEnvironmentState(environment);
      }
    }
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
}

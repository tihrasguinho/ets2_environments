import 'dart:developer';

import 'package:ets2_environments/l10n/l10n.dart';
import 'package:ets2_environments/src/domain/entities/environment_entity.dart';
import 'package:ets2_environments/src/domain/entities/homedir_entity.dart';
import 'package:ets2_environments/src/presentation/others/local_storage.dart';
import 'package:ets2_environments/src/presentation/states/environment_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class EnvironmentStore extends ValueNotifier<EnvironmentState> {
  final LocalStorage _localStorage;

  EnvironmentStore(this._localStorage) : super(InitialEnvironmentState());

  void loadFromLocalStorage({bool verbose = false}) {
    final i10n = GetIt.I.get<I10n>();

    if (verbose) log('Loading from local storage...', name: 'EnvironmentStore:loadFromLocalStorage');

    value = LoadingEnvironmentState();

    final environmentJson = _localStorage.getString('environment');

    if (environmentJson == null) {
      value = ErrorEnvironmentState(i10n.main_page_empty_environments_message);
    } else {
      final environment = EnvironmentEntity.fromJson(environmentJson);

      if (environment.homedirs.isEmpty) {
        value = ErrorEnvironmentState(i10n.main_page_empty_environments_message);
      } else {
        value = SuccessEnvironmentState(environment);
      }
    }
  }

  void addHomedir(HomedirEntity homedir) {
    final environment = value.environment.copyWith(homedirs: [...value.environment.homedirs, homedir]);

    _localStorage.setString('environment', environment.toJson());

    value = SuccessEnvironmentState(environment);
  }

  void removeHomedir(HomedirEntity homedir) {
    final environment = value.environment.copyWith(homedirs: [...value.environment.homedirs]..remove(homedir));

    _localStorage.setString('environment', environment.toJson());

    value = SuccessEnvironmentState(environment);
  }
}

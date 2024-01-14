import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:ets2_environments/src/entities/homedir_entity.dart';
import 'package:flutter/material.dart';

class EnvironmentEntity {
  final String gamePath;
  final List<HomedirEntity> homedirs;
  final bool closeAppWhenGameLaunch;
  final ThemeMode themeMode;
  final List<String> launchArguments;

  EnvironmentEntity({
    required this.gamePath,
    required this.homedirs,
    required this.closeAppWhenGameLaunch,
    required this.themeMode,
    required this.launchArguments,
  });

  factory EnvironmentEntity.empty() {
    return EnvironmentEntity(
      gamePath: '',
      homedirs: [],
      closeAppWhenGameLaunch: true,
      themeMode: ThemeMode.system,
      launchArguments: [],
    );
  }

  EnvironmentEntity copyWith({
    String? gamePath,
    List<HomedirEntity>? homedirs,
    bool? closeAppWhenGameLaunch,
    ThemeMode? themeMode,
    List<String>? launchArguments,
  }) {
    return EnvironmentEntity(
      gamePath: gamePath ?? this.gamePath,
      homedirs: homedirs ?? this.homedirs,
      closeAppWhenGameLaunch: closeAppWhenGameLaunch ?? this.closeAppWhenGameLaunch,
      themeMode: themeMode ?? this.themeMode,
      launchArguments: launchArguments ?? this.launchArguments,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gamePath': gamePath,
      'homedirs': homedirs.map((x) => x.toMap()).toList(),
      'closeAppWhenGameLaunch': closeAppWhenGameLaunch,
      'themeMode': themeMode.name,
      'launchArguments': launchArguments,
    };
  }

  factory EnvironmentEntity.fromMap(Map<String, dynamic> map) {
    return EnvironmentEntity(
      gamePath: map['gamePath'] as String,
      homedirs: List<HomedirEntity>.from(
        (map['homedirs'] as List).map<HomedirEntity>(
          (x) => HomedirEntity.fromMap(x as Map<String, dynamic>),
        ),
      ),
      closeAppWhenGameLaunch: map['closeAppWhenGameLaunch'] as bool,
      themeMode: ThemeMode.values.byName(map['themeMode'] as String),
      launchArguments: List<String>.from((map['launchArguments'] as List)),
    );
  }

  String toJson() => json.encode(toMap());

  factory EnvironmentEntity.fromJson(String source) => EnvironmentEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EnvironmentEntity(gamePath: $gamePath, homedirs: $homedirs, closeAppWhenGameLaunch: $closeAppWhenGameLaunch, themeMode: $themeMode, launchArguments: $launchArguments)';
  }

  @override
  bool operator ==(covariant EnvironmentEntity other) {
    if (identical(this, other)) return true;

    return other.gamePath == gamePath &&
        listEquals(other.homedirs, homedirs) &&
        other.closeAppWhenGameLaunch == closeAppWhenGameLaunch &&
        other.themeMode == themeMode &&
        listEquals(other.launchArguments, launchArguments);
  }

  @override
  int get hashCode {
    return gamePath.hashCode ^ homedirs.hashCode ^ closeAppWhenGameLaunch.hashCode ^ themeMode.hashCode ^ launchArguments.hashCode;
  }
}

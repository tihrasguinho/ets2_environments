// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SystemEntity {
  final bool closeAppWhenGameLaunch;
  final bool minimizeToTray;
  final File gameFile;
  final Directory defaultHomedir;
  final List<String> launchArguments;
  final ThemeMode themeMode;

  SystemEntity({
    required this.closeAppWhenGameLaunch,
    required this.minimizeToTray,
    required this.gameFile,
    required this.defaultHomedir,
    required this.launchArguments,
    required this.themeMode,
  });

  bool get gameFileExists => gameFile.existsSync();

  bool get defaultHomedirExists => defaultHomedir.existsSync();

  factory SystemEntity.defaultConfig() {
    return SystemEntity(
      closeAppWhenGameLaunch: false,
      minimizeToTray: false,
      gameFile: File(''),
      defaultHomedir: Directory(''),
      launchArguments: const [],
      themeMode: ThemeMode.system,
    );
  }

  SystemEntity copyWith({
    bool? closeAppWhenGameLaunch,
    bool? minimizeToTray,
    File? gameFile,
    Directory? defaultHomedir,
    List<String>? launchArguments,
    ThemeMode? themeMode,
  }) {
    return SystemEntity(
      closeAppWhenGameLaunch: closeAppWhenGameLaunch ?? this.closeAppWhenGameLaunch,
      minimizeToTray: minimizeToTray ?? this.minimizeToTray,
      gameFile: gameFile ?? this.gameFile,
      defaultHomedir: defaultHomedir ?? this.defaultHomedir,
      launchArguments: launchArguments ?? this.launchArguments,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'closeAppWhenGameLaunch': closeAppWhenGameLaunch,
      'minimizeToTray': minimizeToTray,
      'gameFile': gameFile.path,
      'defaultHomedir': defaultHomedir.path,
      'launchArguments': launchArguments,
      'themeMode': themeMode.name,
    };
  }

  factory SystemEntity.fromMap(Map<String, dynamic> map) {
    return SystemEntity(
      closeAppWhenGameLaunch: map['closeAppWhenGameLaunch'] as bool,
      minimizeToTray: map['minimizeToTray'] as bool,
      gameFile: File(map['gameFile'] as String),
      defaultHomedir: Directory(map['defaultHomedir'] as String),
      launchArguments: List<String>.from((map['launchArguments'] as List)),
      themeMode: ThemeMode.values.byName(map['themeMode'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory SystemEntity.fromJson(String source) => SystemEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SystemEntity(closeAppWhenGameLaunch: $closeAppWhenGameLaunch, minimizeToTray: $minimizeToTray, gameFile: $gameFile, defaultHomedir: $defaultHomedir, launchArguments: $launchArguments, themeMode: $themeMode)';
  }

  @override
  bool operator ==(covariant SystemEntity other) {
    if (identical(this, other)) return true;

    return other.closeAppWhenGameLaunch == closeAppWhenGameLaunch &&
        other.minimizeToTray == minimizeToTray &&
        other.gameFile == gameFile &&
        other.defaultHomedir == defaultHomedir &&
        listEquals(other.launchArguments, launchArguments) &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode {
    return closeAppWhenGameLaunch.hashCode ^ minimizeToTray.hashCode ^ gameFile.hashCode ^ defaultHomedir.hashCode ^ launchArguments.hashCode ^ themeMode.hashCode;
  }
}

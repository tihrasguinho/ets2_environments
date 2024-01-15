// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SystemEntity {
  final bool minimizeToTray;
  final File gameFile;
  final Directory defaultHomedir;
  final List<String> launchArguments;
  final ThemeMode themeMode;
  final Locale locale;

  SystemEntity({
    required this.minimizeToTray,
    required this.gameFile,
    required this.defaultHomedir,
    required this.launchArguments,
    required this.themeMode,
    required this.locale,
  });

  bool get gameFileExists => gameFile.existsSync();

  bool get defaultHomedirExists => defaultHomedir.existsSync();

  factory SystemEntity.defaultConfig() {
    return SystemEntity(
      minimizeToTray: false,
      gameFile: File(''),
      defaultHomedir: Directory(''),
      launchArguments: const [],
      themeMode: ThemeMode.system,
      locale: const Locale('en'),
    );
  }

  SystemEntity copyWith({
    bool? minimizeToTray,
    File? gameFile,
    Directory? defaultHomedir,
    List<String>? launchArguments,
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return SystemEntity(
      minimizeToTray: minimizeToTray ?? this.minimizeToTray,
      gameFile: gameFile ?? this.gameFile,
      defaultHomedir: defaultHomedir ?? this.defaultHomedir,
      launchArguments: launchArguments ?? this.launchArguments,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'minimizeToTray': minimizeToTray,
      'gameFile': gameFile.path,
      'defaultHomedir': defaultHomedir.path,
      'launchArguments': launchArguments,
      'themeMode': themeMode.name,
      'locale': locale.languageCode,
    };
  }

  factory SystemEntity.fromMap(Map<String, dynamic> map) {
    return SystemEntity(
      minimizeToTray: map['minimizeToTray'] as bool,
      gameFile: File(map['gameFile'] as String),
      defaultHomedir: Directory(map['defaultHomedir'] as String),
      launchArguments: List<String>.from((map['launchArguments'] as List)),
      themeMode: ThemeMode.values.byName(map['themeMode'] as String),
      locale: Locale.fromSubtags(languageCode: map['locale'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory SystemEntity.fromJson(String source) => SystemEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SystemEntity(minimizeToTray: $minimizeToTray, gameFile: $gameFile, defaultHomedir: $defaultHomedir, launchArguments: $launchArguments, themeMode: $themeMode, locale: $locale)';
  }

  @override
  bool operator ==(covariant SystemEntity other) {
    if (identical(this, other)) return true;

    return other.minimizeToTray == minimizeToTray &&
        other.gameFile == gameFile &&
        other.defaultHomedir == defaultHomedir &&
        listEquals(other.launchArguments, launchArguments) &&
        other.themeMode == themeMode &&
        other.locale == locale;
  }

  @override
  int get hashCode {
    return minimizeToTray.hashCode ^ gameFile.hashCode ^ defaultHomedir.hashCode ^ launchArguments.hashCode ^ themeMode.hashCode ^ locale.hashCode;
  }
}

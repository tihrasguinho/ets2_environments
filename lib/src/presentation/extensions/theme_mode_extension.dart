import 'package:ets2_environments/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

extension ThemeModeExtension on ThemeMode {
  String get translatedName {
    final I10n i10n = GetIt.I.get();

    return switch (this) {
      ThemeMode.system => i10n.theme_mode_system,
      ThemeMode.light => i10n.theme_mode_light,
      ThemeMode.dark => i10n.theme_mode_dark,
    };
  }
}

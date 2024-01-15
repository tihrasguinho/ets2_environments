import 'package:ets2_environments/l10n/l10n.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

extension LocaleExtension on Locale {
  String get translatedName {
    final I10n i10n = GetIt.I.get();

    return switch (languageCode) {
      'en' => i10n.language_name_en,
      'pt' => i10n.language_name_pt,
      _ => languageCode,
    };
  }
}

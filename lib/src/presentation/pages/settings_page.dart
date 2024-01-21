import 'package:ets2_environments/l10n/l10n.dart';
import 'package:ets2_environments/src/presentation/extensions/build_context_extension.dart';
import 'package:ets2_environments/src/presentation/extensions/column_extension.dart';
import 'package:ets2_environments/src/presentation/extensions/locale_extension.dart';
import 'package:ets2_environments/src/presentation/extensions/theme_mode_extension.dart';
import 'package:ets2_environments/src/presentation/others/system_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final I10n i10n = GetIt.I.get();
  late final SystemManager manager = SystemManager.of(context);

  late final launchArguments = TextEditingController(text: manager.system.launchArguments.join(' '));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(i10n.settings_page_toolbar_title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CheckboxListTile(
              value: manager.system.minimizeToTray,
              hoverColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              contentPadding: EdgeInsets.zero,
              title: Text(
                i10n.settings_page_minimize_to_tray_title,
                style: context.textTheme.titleMedium,
              ),
              subtitle: Text(
                i10n.settings_page_minimize_to_tray_description,
                style: context.textTheme.bodySmall?.copyWith(),
              ),
              onChanged: manager.setMinimizeToTray,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    i10n.settings_page_theme_title,
                    style: context.textTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  width: 256.0,
                  child: DropdownButtonFormField<ThemeMode>(
                    value: manager.system.themeMode,
                    onChanged: manager.setThemeMode,
                    decoration: InputDecoration(
                      labelText: i10n.settings_page_theme_title,
                      labelStyle: context.theme.inputDecorationTheme.labelStyle,
                      enabledBorder: context.theme.inputDecorationTheme.enabledBorder,
                      focusedBorder: context.theme.inputDecorationTheme.focusedBorder,
                      errorBorder: context.theme.inputDecorationTheme.errorBorder,
                      focusedErrorBorder: context.theme.inputDecorationTheme.focusedErrorBorder,
                      disabledBorder: context.theme.inputDecorationTheme.disabledBorder,
                      isDense: context.theme.inputDecorationTheme.isDense,
                      border: context.theme.inputDecorationTheme.border,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    items: List.from(
                      ThemeMode.values.map(
                        (mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(mode.translatedName),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    i10n.settings_page_language_title,
                    style: context.textTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  width: 256.0,
                  child: DropdownButtonFormField<Locale>(
                    value: manager.system.locale,
                    onChanged: manager.setLocale,
                    decoration: InputDecoration(
                      labelText: i10n.settings_page_language_title,
                      labelStyle: context.theme.inputDecorationTheme.labelStyle,
                      enabledBorder: context.theme.inputDecorationTheme.enabledBorder,
                      focusedBorder: context.theme.inputDecorationTheme.focusedBorder,
                      errorBorder: context.theme.inputDecorationTheme.errorBorder,
                      focusedErrorBorder: context.theme.inputDecorationTheme.focusedErrorBorder,
                      disabledBorder: context.theme.inputDecorationTheme.disabledBorder,
                      isDense: context.theme.inputDecorationTheme.isDense,
                      border: context.theme.inputDecorationTheme.border,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    items: List.from(
                      I10n.delegate.supportedLocales.map(
                        (locale) => DropdownMenuItem(
                          value: locale,
                          child: Text(locale.translatedName),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(indent: 24.0, endIndent: 24.0),
            Text(
              i10n.settings_page_game_configurations,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(),
            TextFormField(
              controller: launchArguments,
              onChanged: (value) => manager.setLaunchArguments(value.split(' ')),
              decoration: InputDecoration(
                labelText: i10n.settings_page_launch_arguments_title,
                hintText: i10n.settings_page_launch_arguments_description,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ],
        ).withSpacing(16.0),
      ),
    );
  }
}

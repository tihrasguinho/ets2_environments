import 'package:ets2_environments/src/extensions/build_context_extension.dart';
import 'package:ets2_environments/src/extensions/column_extension.dart';
import 'package:ets2_environments/src/others/system_manager.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SystemManager manager = SystemManager.of(context);

  late final launchArguments = TextEditingController(text: manager.system.launchArguments.join(' '));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CheckboxListTile(
              value: manager.system.closeAppWhenGameLaunch,
              hoverColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Close ETS2 Environments after Euro Truck Simulator 2 launch?',
                style: context.textTheme.titleMedium,
              ),
              onChanged: manager.setCloseAppWhenGameLaunche,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Set the ThemeMode: ',
                    style: context.textTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  width: 256.0,
                  child: DropdownButtonFormField<ThemeMode>(
                    value: manager.system.themeMode,
                    onChanged: (value) {
                      if (value == null) return;

                      return switch (value) {
                        ThemeMode.system => manager.setThemeMode(ThemeMode.system),
                        ThemeMode.light => manager.setThemeMode(ThemeMode.light),
                        ThemeMode.dark => manager.setThemeMode(ThemeMode.dark),
                      };
                    },
                    decoration: InputDecoration(
                      labelText: 'ThemeMode',
                      labelStyle: context.theme.inputDecorationTheme.labelStyle,
                      enabledBorder: context.theme.inputDecorationTheme.enabledBorder,
                      focusedBorder: context.theme.inputDecorationTheme.focusedBorder,
                      errorBorder: context.theme.inputDecorationTheme.errorBorder,
                      focusedErrorBorder: context.theme.inputDecorationTheme.focusedErrorBorder,
                      disabledBorder: context.theme.inputDecorationTheme.disabledBorder,
                      isDense: context.theme.inputDecorationTheme.isDense,
                      border: context.theme.inputDecorationTheme.border,
                      contentPadding: context.theme.inputDecorationTheme.contentPadding,
                    ),
                    items: List.from(
                      ThemeMode.values.map(
                        (mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(mode.name[0].toUpperCase() + mode.name.substring(1)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: launchArguments,
              onChanged: (value) => manager.setLaunchArguments(value.split(' ')),
              decoration: const InputDecoration(
                labelText: 'Launch arguments',
                hintText: 'Enter launch arguments',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ).withSpacing(16.0),
      ),
    );
  }
}

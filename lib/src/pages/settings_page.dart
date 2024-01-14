import 'package:ets2_environments/src/extensions/build_context_extension.dart';
import 'package:ets2_environments/src/extensions/column_extension.dart';
import 'package:ets2_environments/src/others/theme_mode_widget.dart';
import 'package:ets2_environments/src/stores/environment_store.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final environmentStore = GetIt.I.get<EnvironmentStore>();

  late final launchArguments = TextEditingController(text: environmentStore.value.environment.launchArguments.join(' '));

  @override
  Widget build(BuildContext context) {
    final themeMode = ThemeModeWidget.of(context);

    return ValueListenableBuilder(
      valueListenable: environmentStore,
      builder: (context, state, child) {
        return state.when(
          onInitial: () => const SizedBox(),
          onSuccess: (environment) {
            return Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CheckboxListTile(
                      value: environment.closeAppWhenGameLaunch,
                      hoverColor: Colors.transparent,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Close ETS2 Environments after Euro Truck Simulator 2 launch?',
                        style: context.textTheme.titleMedium,
                      ),
                      onChanged: environmentStore.setCloseAppWhenGameLaunche,
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
                            value: themeMode.themeMode,
                            onChanged: (value) {
                              if (value == null) return;

                              environmentStore.setThemeMode(value);

                              return switch (value) {
                                ThemeMode.system => themeMode.setSystemMode(),
                                ThemeMode.light => themeMode.setLightMode(),
                                ThemeMode.dark => themeMode.setDarkMode(),
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
                      onChanged: environmentStore.addLaunchArguments,
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
          },
        );
      },
    );
  }
}

import 'package:ets2_environments/src/extensions/build_context_extension.dart';
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
                    const SizedBox(height: 16.0),
                    CheckboxListTile(
                      value: environment.setAppThemeToDarkMode,
                      hoverColor: Colors.transparent,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Set app theme to Dark Mode',
                        style: context.textTheme.titleMedium,
                      ),
                      onChanged: environmentStore.setAppThemeToDarkMode,
                    ),
                    const SizedBox(height: 16.0),
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
                ),
              ),
            );
          },
        );
      },
    );
  }
}

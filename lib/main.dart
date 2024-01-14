import 'package:ets2_environments/src/others/theme_mode_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/controllers/main_controller.dart';
import 'src/main_widget.dart';
import 'src/stores/environment_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final GetIt getIt = GetIt.instance;

  final SharedPreferences preferences = await SharedPreferences.getInstance();

  getIt.registerSingleton<SharedPreferences>(preferences);

  getIt.registerSingleton<EnvironmentStore>(EnvironmentStore(getIt()));

  getIt.registerSingleton<MainController>(MainController(getIt()));

  runApp(ThemeModeWidget(child: const MainWidget()));
}

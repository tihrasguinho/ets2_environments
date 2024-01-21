import 'package:ets2_environments/l10n/l10n.dart';
import 'package:ets2_environments/src/presentation/others/local_storage.dart';
import 'package:ets2_environments/src/presentation/others/system_manager.dart';
import 'package:ets2_environments/src/presentation/stores/environment_store.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:window_manager/window_manager.dart';

import 'src/presentation/controllers/main_controller.dart';
import 'src/main_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const WindowOptions options = WindowOptions(
    center: true,
    fullScreen: false,
    skipTaskbar: false,
    minimumSize: Size(1280, 720),
    size: Size(1280, 720),
    backgroundColor: Colors.transparent,
  );

  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
  });

  final GetIt getIt = GetIt.instance;

  final LocalStorage storage = LocalStorageImp();

  getIt.registerLazySingleton<I10n>(() => I10n());

  getIt.registerSingleton<LocalStorage>(storage);

  getIt.registerSingleton<EnvironmentStore>(EnvironmentStore(getIt()));

  getIt.registerSingleton<MainController>(MainController(getIt()));

  runApp(
    SystemManager(
      localStorage: storage,
      child: const MainWidget(),
    ),
  );
}

import 'package:ets2_environments/l10n/l10n.dart';
import 'package:ets2_environments/src/presentation/others/system_manager.dart';
import 'package:ets2_environments/src/presentation/pages/main_page.dart';
import 'package:ets2_environments/src/presentation/pages/settings_page.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> with WindowListener, TrayListener {
  late final SystemManager manager = SystemManager.of(context);

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    trayManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMinimize() async {
    super.onWindowMinimize();

    await manager.setupTrayMenu();
  }

  @override
  void onWindowMaximize() async {
    super.onWindowMaximize();

    await manager.removeTrayMenu();
  }

  @override
  void onTrayIconRightMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    return await manager.onMenuItemTapped(menuItem);
  }

  @override
  void onTrayIconMouseDown() async {
    await manager.removeTrayMenu();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: SystemManager.of(context).notifier!,
      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ETS2 Environments',
          initialRoute: '/',
          onGenerateRoute: (settings) => switch (settings.name) {
            '/' => PageRouteBuilder(
                settings: settings,
                pageBuilder: (_, __, ___) => const MainPage(),
              ),
            '/settings' => PageRouteBuilder(
                settings: settings,
                pageBuilder: (_, __, ___) => const SettingsPage(),
              ),
            _ => PageRouteBuilder(
                settings: settings,
                pageBuilder: (_, __, ___) => const MainPage(),
              ),
          },
          localizationsDelegates: const [
            I10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: I10n.delegate.supportedLocales,
          locale: manager.system.locale,
          localeResolutionCallback: (locale, supportedLocales) {
            if (supportedLocales.map((e) => e.languageCode).contains(locale?.languageCode)) {
              return locale;
            } else {
              return const Locale('en');
            }
          },
          builder: (context, child) {
            return Overlay(
              initialEntries: [
                OverlayEntry(builder: (context) => SelectionArea(child: child ?? const SizedBox())),
              ],
            );
          },
          theme: FlexThemeData.light(
            scheme: FlexScheme.blue,
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 7,
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 10,
              blendOnColors: false,
              useTextTheme: true,
              useM2StyleDividerInM3: true,
              textButtonRadius: 8.0,
              filledButtonRadius: 8.0,
              elevatedButtonRadius: 8.0,
              outlinedButtonRadius: 8.0,
              inputDecoratorIsFilled: false,
              inputDecoratorRadius: 8.0,
              inputDecoratorUnfocusedBorderIsColored: false,
              alignedDropdown: true,
              useInputDecoratorThemeInDialogs: true,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            swapLegacyOnMaterial3: true,
            fontFamily: GoogleFonts.notoSans().fontFamily,
          ),
          darkTheme: FlexThemeData.dark(
            scheme: FlexScheme.blue,
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 13,
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 20,
              useTextTheme: true,
              useM2StyleDividerInM3: true,
              textButtonRadius: 8.0,
              filledButtonRadius: 8.0,
              elevatedButtonRadius: 8.0,
              outlinedButtonRadius: 8.0,
              inputDecoratorIsFilled: false,
              inputDecoratorRadius: 8.0,
              inputDecoratorUnfocusedBorderIsColored: false,
              alignedDropdown: true,
              useInputDecoratorThemeInDialogs: true,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            swapLegacyOnMaterial3: true,
            fontFamily: GoogleFonts.notoSans().fontFamily,
          ),
          themeMode: value.themeMode,
        );
      },
    );
  }
}

import 'package:ets2_environments/src/others/system_manager.dart';
import 'package:ets2_environments/src/pages/settings_page.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/main_page.dart';

class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

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

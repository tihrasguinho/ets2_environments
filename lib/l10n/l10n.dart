// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class I10n {
  I10n();

  static I10n? _current;

  static I10n get current {
    assert(_current != null,
        'No instance of I10n was loaded. Try to initialize the I10n delegate before accessing I10n.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<I10n> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = I10n();
      I10n._current = instance;

      return instance;
    });
  }

  static I10n of(BuildContext context) {
    final instance = I10n.maybeOf(context);
    assert(instance != null,
        'No instance of I10n present in the widget tree. Did you add I10n.delegate in localizationsDelegates?');
    return instance!;
  }

  static I10n? maybeOf(BuildContext context) {
    return Localizations.of<I10n>(context, I10n);
  }

  /// `Please select the game executable first!`
  String get main_page_leading_tooltip_empty {
    return Intl.message(
      'Please select the game executable first!',
      name: 'main_page_leading_tooltip_empty',
      desc: '',
      args: [],
    );
  }

  /// `Open in Explorer`
  String get main_page_leading_tooltip {
    return Intl.message(
      'Open in Explorer',
      name: 'main_page_leading_tooltip',
      desc: '',
      args: [],
    );
  }

  /// `Select the Euro Truck Simulator 2 executable!`
  String get main_page_pick_game_executable_dialog_title {
    return Intl.message(
      'Select the Euro Truck Simulator 2 executable!',
      name: 'main_page_pick_game_executable_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Failed to pick game executable!`
  String get main_page_pick_game_executable_dialog_error {
    return Intl.message(
      'Failed to pick game executable!',
      name: 'main_page_pick_game_executable_dialog_error',
      desc: '',
      args: [],
    );
  }

  /// `Euro Truck Simulator 2 not found!`
  String get main_page_toolbar_game_not_found {
    return Intl.message(
      'Euro Truck Simulator 2 not found!',
      name: 'main_page_toolbar_game_not_found',
      desc: '',
      args: [],
    );
  }

  /// `You do not have any environments yet.`
  String get main_page_empty_environments_message {
    return Intl.message(
      'You do not have any environments yet.',
      name: 'main_page_empty_environments_message',
      desc: '',
      args: [],
    );
  }

  /// `Add New Environment`
  String get main_page_fab_title {
    return Intl.message(
      'Add New Environment',
      name: 'main_page_fab_title',
      desc: '',
      args: [],
    );
  }

  /// `Add New Environment`
  String get add_environment_dialog_title {
    return Intl.message(
      'Add New Environment',
      name: 'add_environment_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get add_environment_dialog_field_name {
    return Intl.message(
      'Name',
      name: 'add_environment_dialog_field_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter the name of the new environment.`
  String get add_environment_dialog_field_name_hint {
    return Intl.message(
      'Enter the name of the new environment.',
      name: 'add_environment_dialog_field_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a name!`
  String get add_environment_dialog_field_name_error {
    return Intl.message(
      'Please enter a name!',
      name: 'add_environment_dialog_field_name_error',
      desc: '',
      args: [],
    );
  }

  /// `Path`
  String get add_environment_dialog_field_path {
    return Intl.message(
      'Path',
      name: 'add_environment_dialog_field_path',
      desc: '',
      args: [],
    );
  }

  /// `Enter the path of the new environment.`
  String get add_environment_dialog_field_path_hint {
    return Intl.message(
      'Enter the path of the new environment.',
      name: 'add_environment_dialog_field_path_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a path!`
  String get add_environment_dialog_field_path_error {
    return Intl.message(
      'Please enter a path!',
      name: 'add_environment_dialog_field_path_error',
      desc: '',
      args: [],
    );
  }

  /// `Path does not exist!`
  String get add_environment_dialog_field_path_error_not_exists {
    return Intl.message(
      'Path does not exist!',
      name: 'add_environment_dialog_field_path_error_not_exists',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add_environment_dialog_button_title {
    return Intl.message(
      'Add',
      name: 'add_environment_dialog_button_title',
      desc: '',
      args: [],
    );
  }

  /// `List Local Profiles`
  String get main_page_environments_profiles_item {
    return Intl.message(
      'List Local Profiles',
      name: 'main_page_environments_profiles_item',
      desc: '',
      args: [],
    );
  }

  /// `List Local Mods`
  String get main_page_environments_mods_item {
    return Intl.message(
      'List Local Mods',
      name: 'main_page_environments_mods_item',
      desc: '',
      args: [],
    );
  }

  /// `Add Mods`
  String get main_page_environments_add_mods_item {
    return Intl.message(
      'Add Mods',
      name: 'main_page_environments_add_mods_item',
      desc: '',
      args: [],
    );
  }

  /// `Open in Explorer`
  String get main_page_environments_open_in_explorer_item {
    return Intl.message(
      'Open in Explorer',
      name: 'main_page_environments_open_in_explorer_item',
      desc: '',
      args: [],
    );
  }

  /// `Enable Camera Zero`
  String get main_page_environments_enable_camera_zero_item {
    return Intl.message(
      'Enable Camera Zero',
      name: 'main_page_environments_enable_camera_zero_item',
      desc: '',
      args: [],
    );
  }

  /// `Camera Zero is enabled.`
  String get main_page_environments_enable_camera_zero_item_message {
    return Intl.message(
      'Camera Zero is enabled.',
      name: 'main_page_environments_enable_camera_zero_item_message',
      desc: '',
      args: [],
    );
  }

  /// `Disable Camera Zero`
  String get main_page_environments_disable_camera_zero_item {
    return Intl.message(
      'Disable Camera Zero',
      name: 'main_page_environments_disable_camera_zero_item',
      desc: '',
      args: [],
    );
  }

  /// `Camera Zero is disabled.`
  String get main_page_environments_disable_camera_zero_item_message {
    return Intl.message(
      'Camera Zero is disabled.',
      name: 'main_page_environments_disable_camera_zero_item_message',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get main_page_environments_remove_item {
    return Intl.message(
      'Remove',
      name: 'main_page_environments_remove_item',
      desc: '',
      args: [],
    );
  }

  /// `Start game from this environment`
  String get main_page_environments_start_game_tooltip {
    return Intl.message(
      'Start game from this environment',
      name: 'main_page_environments_start_game_tooltip',
      desc: '',
      args: [],
    );
  }

  /// `Show options`
  String get main_page_environments_show_menu_tooltip {
    return Intl.message(
      'Show options',
      name: 'main_page_environments_show_menu_tooltip',
      desc: '',
      args: [],
    );
  }

  /// `Select a folder to your new environment`
  String get main_page_environments_pick_environment_folder_selector_title {
    return Intl.message(
      'Select a folder to your new environment',
      name: 'main_page_environments_pick_environment_folder_selector_title',
      desc: '',
      args: [],
    );
  }

  /// `Select mods that you want to add to this environment`
  String get main_page_environments_pick_mods_selector_title {
    return Intl.message(
      'Select mods that you want to add to this environment',
      name: 'main_page_environments_pick_mods_selector_title',
      desc: '',
      args: [],
    );
  }

  /// `Profiles (Local Only)`
  String get main_page_environments_profiles_dialog_title {
    return Intl.message(
      'Profiles (Local Only)',
      name: 'main_page_environments_profiles_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Active Mods`
  String get main_page_environments_active_mods_dialog_subtitle {
    return Intl.message(
      'Active Mods',
      name: 'main_page_environments_active_mods_dialog_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `No profiles found.`
  String get main_page_environments_profiles_dialog_empty_message {
    return Intl.message(
      'No profiles found.',
      name: 'main_page_environments_profiles_dialog_empty_message',
      desc: '',
      args: [],
    );
  }

  /// `Mods (Local Only)`
  String get main_page_environments_mods_dialog_title {
    return Intl.message(
      'Mods (Local Only)',
      name: 'main_page_environments_mods_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `No mods found.`
  String get main_page_environments_mods_dialog_empty_message {
    return Intl.message(
      'No mods found.',
      name: 'main_page_environments_mods_dialog_empty_message',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get main_page_environments_mods_dialog_author_subtitle {
    return Intl.message(
      'Author',
      name: 'main_page_environments_mods_dialog_author_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get main_page_environments_mods_dialog_version_subtitle {
    return Intl.message(
      'Version',
      name: 'main_page_environments_mods_dialog_version_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get main_page_environments_mods_dialog_categories_subtitle {
    return Intl.message(
      'Categories',
      name: 'main_page_environments_mods_dialog_categories_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Compatible Versions`
  String get main_page_environments_mods_dialog_compatibility {
    return Intl.message(
      'Compatible Versions',
      name: 'main_page_environments_mods_dialog_compatibility',
      desc: '',
      args: [],
    );
  }

  /// `Remove This Environment?`
  String get main_page_environments_remove_dialog_title {
    return Intl.message(
      'Remove This Environment?',
      name: 'main_page_environments_remove_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this environment?`
  String get main_page_environments_remove_dialog_subtitle {
    return Intl.message(
      'Are you sure you want to remove this environment?',
      name: 'main_page_environments_remove_dialog_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Keep the directory folder?`
  String get main_page_environments_remove_dialog_check_title {
    return Intl.message(
      'Keep the directory folder?',
      name: 'main_page_environments_remove_dialog_check_title',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get main_page_environments_remove_dialog_cancel_button {
    return Intl.message(
      'Cancel',
      name: 'main_page_environments_remove_dialog_cancel_button',
      desc: '',
      args: [],
    );
  }

  /// `Yes, remove it!`
  String get main_page_environments_remove_dialog_confirm_button {
    return Intl.message(
      'Yes, remove it!',
      name: 'main_page_environments_remove_dialog_confirm_button',
      desc: '',
      args: [],
    );
  }

  /// `Error!`
  String get main_page_environments_error_dialog_title {
    return Intl.message(
      'Error!',
      name: 'main_page_environments_error_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Please select the game path first!`
  String get main_page_environments_error_dialog_subtitle {
    return Intl.message(
      'Please select the game path first!',
      name: 'main_page_environments_error_dialog_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Loading mods list details\nIt may take a while depending on the number of mods`
  String get main_page_environments_loading_mods_list_message {
    return Intl.message(
      'Loading mods list details\nIt may take a while depending on the number of mods',
      name: 'main_page_environments_loading_mods_list_message',
      desc: '',
      args: [],
    );
  }

  /// `Loading profiles`
  String get main_page_environments_loading_profiles_list_message {
    return Intl.message(
      'Loading profiles',
      name: 'main_page_environments_loading_profiles_list_message',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings_page_toolbar_title {
    return Intl.message(
      'Settings',
      name: 'settings_page_toolbar_title',
      desc: '',
      args: [],
    );
  }

  /// `Minimize to system tray when click to minimize.`
  String get settings_page_minimize_to_tray_title {
    return Intl.message(
      'Minimize to system tray when click to minimize.',
      name: 'settings_page_minimize_to_tray_title',
      desc: '',
      args: [],
    );
  }

  /// `When the game starts, the app will minimize to system tray.`
  String get settings_page_minimize_to_tray_description {
    return Intl.message(
      'When the game starts, the app will minimize to system tray.',
      name: 'settings_page_minimize_to_tray_description',
      desc: '',
      args: [],
    );
  }

  /// `Theme Mode`
  String get settings_page_theme_title {
    return Intl.message(
      'Theme Mode',
      name: 'settings_page_theme_title',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get settings_page_language_title {
    return Intl.message(
      'Language',
      name: 'settings_page_language_title',
      desc: '',
      args: [],
    );
  }

  /// `Launch Arguments`
  String get settings_page_launch_arguments_title {
    return Intl.message(
      'Launch Arguments',
      name: 'settings_page_launch_arguments_title',
      desc: '',
      args: [],
    );
  }

  /// `Launch arguments to be passed to the game.`
  String get settings_page_launch_arguments_description {
    return Intl.message(
      'Launch arguments to be passed to the game.',
      name: 'settings_page_launch_arguments_description',
      desc: '',
      args: [],
    );
  }

  /// `Game Configurations`
  String get settings_page_game_configurations {
    return Intl.message(
      'Game Configurations',
      name: 'settings_page_game_configurations',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get language_name_en {
    return Intl.message(
      'English',
      name: 'language_name_en',
      desc: '',
      args: [],
    );
  }

  /// `Portuguese`
  String get language_name_pt {
    return Intl.message(
      'Portuguese',
      name: 'language_name_pt',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get theme_mode_system {
    return Intl.message(
      'System',
      name: 'theme_mode_system',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get theme_mode_light {
    return Intl.message(
      'Light',
      name: 'theme_mode_light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get theme_mode_dark {
    return Intl.message(
      'Dark',
      name: 'theme_mode_dark',
      desc: '',
      args: [],
    );
  }

  /// `Starting the game`
  String get message_starting_the_game {
    return Intl.message(
      'Starting the game',
      name: 'message_starting_the_game',
      desc: '',
      args: [],
    );
  }

  /// `ETS2 Environments running`
  String get tray_tooltip {
    return Intl.message(
      'ETS2 Environments running',
      name: 'tray_tooltip',
      desc: '',
      args: [],
    );
  }

  /// `Environment Options`
  String get tray_menu_option_environment_title {
    return Intl.message(
      'Environment Options',
      name: 'tray_menu_option_environment_title',
      desc: '',
      args: [],
    );
  }

  /// `Start from`
  String get tray_menu_option_start_from_specific_environment {
    return Intl.message(
      'Start from',
      name: 'tray_menu_option_start_from_specific_environment',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get tray_menu_option_close {
    return Intl.message(
      'Close',
      name: 'tray_menu_option_close',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<I10n> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'pt'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<I10n> load(Locale locale) => I10n.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

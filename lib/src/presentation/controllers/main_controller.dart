import 'dart:convert';
import 'dart:io';

import 'package:ets2_environments/l10n/l10n.dart';
import 'package:ets2_environments/src/domain/entities/homedir_entity.dart';
import 'package:ets2_environments/src/domain/entities/mod_entity.dart';
import 'package:ets2_environments/src/domain/entities/profile_entity.dart';
import 'package:ets2_environments/src/domain/enums/system_architecture.dart';
import 'package:ets2_environments/src/presentation/others/sii_decrypt.dart';
import 'package:ets2_environments/src/presentation/stores/environment_store.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;

class MainController {
  final EnvironmentStore environmentStore;

  MainController(this.environmentStore);

  Future<List<ProfileEntity>> getProfilesList(String path) async {
    final profilesDir = Directory(p.join(path, 'Euro Truck Simulator 2', 'profiles'));

    if (!await profilesDir.exists()) return [];

    final profilesDirList = profilesDir.listSync();

    if (profilesDirList.isEmpty) return [];

    final profiles = <ProfileEntity>[];

    for (final profileDir in profilesDirList) {
      if (profileDir is Directory) {
        final profile = File(p.join(profileDir.path, 'profile.sii'));

        if (await profile.exists()) {
          final siiDecryptDllPath = switch (kDebugMode) {
            true => './assets/sii_decrypt/SII_Decrypt_x64.dll',
            false => './data/flutter_assets/assets/sii_decrypt/SII_Decrypt_x64.dll',
          };

          final decrypt = SiiDecrypt(siiDecryptDllPath);

          final isEncrypted = decrypt.isEncrypted(profile.path);

          if (isEncrypted == null) continue;

          if (!isEncrypted) {
            final profileContent = await profile.readAsBytes();

            final decoded = utf8.decode(profileContent, allowMalformed: true);

            final companyName = RegExp(r'company_name: ["]?(.*)["]?').firstMatch(decoded)?.group(1)?.replaceAll('"', '');

            final profileName = RegExp(r'profile_name: ["]?(.*)["]?').firstMatch(decoded)?.group(1)?.replaceAll('"', '');

            final activeMods = RegExp(r'active_mods\[[0-9]{1,}\]: ["]?(.*)["]?').allMatches(decoded).map((e) {
              return e.group(1)?.split('|').last.replaceAll('"', '') ?? 'N/A';
            }).toList();

            profiles.add(
              ProfileEntity(
                companyName: _withCharBugSolved(companyName ?? 'N/A'),
                profileName: _withCharBugSolved(profileName ?? 'N/A'),
                activeMods: activeMods,
              ),
            );
          } else {
            final profileContent = decrypt.decryptAndDecodeFile(profile.path, verbose: true);

            if (profileContent == null) continue;

            final companyName = RegExp(r'company_name: ["]?(.*)["]?').firstMatch(profileContent)?.group(1)?.replaceAll('"', '');

            final profileName = RegExp(r'profile_name: ["]?(.*)["]?').firstMatch(profileContent)?.group(1)?.replaceAll('"', '');

            final activeMods = RegExp(r'active_mods\[[0-9]{1,}\]: ["]?(.*)["]?').allMatches(profileContent).map((e) {
              return e.group(1)?.split('|').last.replaceAll('"', '') ?? 'N/A';
            }).toList();

            profiles.add(
              ProfileEntity(
                companyName: _withCharBugSolved(companyName ?? 'N/A'),
                profileName: _withCharBugSolved(profileName ?? 'N/A'),
                activeMods: activeMods,
              ),
            );
          }
        }
      }
    }

    return profiles;
  }

  Future<void> pickModFiles(Directory homedir) async {
    final I10n i10n = GetIt.I.get();

    final picker = OpenFilePicker()
      ..title = i10n.main_page_environments_pick_mods_selector_title
      ..initialDirectory = homedir.path
      ..filterSpecification = {
        'Euro Truck Simulator 2 Mods': '*.scs;*.zip',
      }
      ..defaultFilterIndex = 0
      ..defaultExtension = 'scs';

    final files = picker.getFiles();

    if (files.isEmpty) return;

    final modsDir = Directory(p.join(homedir.path, 'Euro Truck Simulator 2', 'mod'));

    if (!await modsDir.exists()) {
      await modsDir.create(recursive: true);
    }

    for (final file in files) {
      await file.copy(p.join(modsDir.path, p.basename(file.path)));
    }
  }

  Future<List<ModEntity>> getModListDetails(String path) async {
    final modDir = Directory(p.join(path, 'Euro Truck Simulator 2', 'mod'));

    if (!modDir.existsSync()) return [];

    final modList = modDir.listSync();

    if (modList.isEmpty) return [];

    final modListNames = <ModEntity>[];

    for (final mod in modList) {
      if (mod is File) {
        final sxcPath = switch (kDebugMode) {
          true => getSystemArchitecture() == SystemArchitecture.x64 ? './assets/sxc/sxc64.exe' : './assets/sxc/sxc.exe',
          false => getSystemArchitecture() == SystemArchitecture.x64 ? './data/flutter_assets/assets/sxc/sxc64.exe' : './data/flutter_assets/assets/sxc/sxc.exe',
        };

        await Process.run(
          sxcPath,
          [
            mod.path,
            '-f',
            'manifest.sii',
            '-oc',
            p.join(modDir.path, 'temp'),
          ],
        );

        final manifest = File(p.join(modDir.path, 'temp', 'manifest.sii'));

        if (await manifest.exists()) {
          final manifestContent = await manifest.readAsString();

          final packageVersion = RegExp(r'package_version: "(.*)"').firstMatch(manifestContent)?.group(1);

          final displayName = RegExp(r'display_name: "(.*)"').firstMatch(manifestContent)?.group(1);

          final author = RegExp(r'author: "(.*)"').firstMatch(manifestContent)?.group(1);

          final categories = RegExp(r'category\[\]: "(.*)"').allMatches(manifestContent).map((e) => e.group(1) ?? 'N/A').toList();

          final compatibleVersions = RegExp(r'compatible_versions\[\]: "(.*)"').allMatches(manifestContent).map((e) => e.group(1) ?? 'N/A').toList();

          modListNames.add(
            ModEntity(
              displayName: displayName ?? 'N/A',
              packageVersion: packageVersion ?? 'N/A',
              author: author ?? 'N/A',
              categories: categories,
              compatibleVersions: compatibleVersions,
            ),
          );

          await Directory(p.join(modDir.path, 'temp')).delete(recursive: true);
        } else {
          modListNames.add(
            ModEntity(
              displayName: mod.path.split(r'\').last,
              packageVersion: 'N/A',
              author: 'N/A',
              categories: [],
              compatibleVersions: [],
            ),
          );
        }
      }
    }

    return modListNames;
  }

  Future<File?> pickGamePath() async {
    final I10n i10n = GetIt.I.get();

    final picker = OpenFilePicker()
      ..title = i10n.main_page_pick_game_executable_dialog_title
      ..fileName = 'eurotrucks2.exe'
      ..defaultExtension = 'exe'
      ..fileMustExist = true
      ..filterSpecification = {
        'Euro Truck Simulator 2': '*.exe',
      };

    final file = picker.getFile();

    if (file == null) {
      return null;
    }

    if (!file.existsSync()) {
      return null;
    }

    if (p.basename(file.path) != 'eurotrucks2.exe') {
      return null;
    }

    return file;
  }

  String _withCharBugSolved(String encodedString) {
    final decoded = encodedString.replaceAllMapped(
      RegExp(r'\\x[0-9a-fA-F]{2}\\x[0-9a-fA-F]{2}'),
      (match) {
        final value = match.group(0)!.split('\\x').toList().where((e) => e.isNotEmpty).join();

        final bytes = <int>[];

        for (var i = 0; i < value.length; i += 2) {
          final hexByte = value.substring(i, i + 2);
          bytes.add(int.parse(hexByte, radix: 16));
        }

        return utf8.decode(bytes);
      },
    );

    return decoded;
  }

  bool enableCameraZero(HomedirEntity homedir) {
    final config = File(p.join(homedir.directory.path, 'Euro Truck Simulator 2', 'config.cfg'));

    if (!config.existsSync()) return false;

    final configContent = config.readAsStringSync();

    final developerRegex = RegExp(r'uset g_developer "1"');

    final consoleRegex = RegExp(r'uset g_console "1"');

    return developerRegex.hasMatch(configContent) && consoleRegex.hasMatch(configContent);
  }

  void setEnableCameraZero(HomedirEntity homedir) {
    final config = File(p.join(homedir.directory.path, 'Euro Truck Simulator 2', 'config.cfg'));

    if (!config.existsSync()) return;

    final configContent = config.readAsStringSync();

    final developerRegex = RegExp(r'uset g_developer "(.*)"');

    final consoleRegex = RegExp(r'uset g_console "(.*)"');

    if (enableCameraZero(homedir)) {
      return config.writeAsStringSync(configContent.replaceAll(developerRegex, 'uset g_developer "0"').replaceAll(consoleRegex, 'uset g_console "0"'));
    } else {
      return config.writeAsStringSync(configContent.replaceAll(developerRegex, 'uset g_developer "1"').replaceAll(consoleRegex, 'uset g_console "1"'));
    }
  }
}

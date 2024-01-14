import 'dart:convert';
import 'dart:io';

import 'package:ets2_environments/src/entities/mod_entity.dart';
import 'package:ets2_environments/src/entities/profile_entity.dart';
import 'package:ets2_environments/src/enums/system_architecture.dart';
import 'package:ets2_environments/src/stores/environment_store.dart';
import 'package:ets2_environments/src/utils/sii_decrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

class MainController {
  final EnvironmentStore environmentStore;

  MainController(this.environmentStore);

  Future<void> startGameFromHomedir(
    String homedirPath, [
    List<String> launchArguments = const [],
    bool closeAppWhenGameLaunch = true,
  ]) async {
    final gamePath = environmentStore.value.environment.gamePath;

    if (gamePath.isEmpty) return;

    await Process.run(
      gamePath,
      [
        '-homedir',
        homedirPath,
        ...launchArguments,
      ],
    );

    if (closeAppWhenGameLaunch) {
      exit(0);
    }
  }

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

  Future<void> pickGamePath(Future<String?> Function() fun) async {
    if (environmentStore.value.environment.gamePath.isNotEmpty) {
      final uri = Uri.file(p.dirname(environmentStore.value.environment.gamePath));

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
      return;
    }

    final path = await fun();

    if (path == null) return;

    if (!File(p.join(path, 'bin', 'win_x64', 'eurotrucks2.exe')).existsSync()) {
      return;
    }

    environmentStore.setGamePath(path);
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
}

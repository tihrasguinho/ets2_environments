import 'dart:io';

enum SystemArchitecture { x86, x64, unknown }

SystemArchitecture getSystemArchitecture() {
  final result = Process.runSync('wmic', ['os', 'get', 'OSArchitecture']);

  if (result.exitCode == 0) {
    if ((result.stdout as String).contains(RegExp(r'(32|86)'))) {
      return SystemArchitecture.x86;
    }

    if ((result.stdout as String).contains(RegExp(r'64'))) {
      return SystemArchitecture.x64;
    }

    return SystemArchitecture.unknown;
  } else {
    return SystemArchitecture.unknown;
  }
}

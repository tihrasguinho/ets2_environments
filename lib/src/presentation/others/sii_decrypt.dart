import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class SiiDecrypt {
  late final DynamicLibrary _decryptLibrary;

  SiiDecrypt(String path) {
    _decryptLibrary = DynamicLibrary.open(p.normalize(path));
  }

  int _getMemoryFormat(Pointer<Uint8> inputMS, int inputMSSize) {
    return _decryptLibrary.lookupFunction<Int32 Function(Pointer<Uint8> inputMS, Uint32 inputMSSize), int Function(Pointer<Uint8> inputMS, int inputMSSize)>('GetMemoryFormat')(
      inputMS,
      inputMSSize,
    );
  }

  int _decryptAndDecodeFile(Pointer<Utf8> inputMS, Pointer<Utf8> outputMS) {
    return _decryptLibrary.lookupFunction<Int32 Function(Pointer<Utf8> inputMS, Pointer<Utf8> outputMS), int Function(Pointer<Utf8> inputMS, Pointer<Utf8> outputMS)>('DecryptAndDecodeFile')(
      inputMS,
      outputMS,
    );
  }

  bool? isEncrypted(String inputPath) {
    final inputFile = File(p.normalize(inputPath));

    if (!inputFile.existsSync()) return null;

    final List<int> fileDataB = inputFile.readAsBytesSync();
    final int memFileFrm = _getMemoryFormat(fileDataB.toPointer(), fileDataB.length);

    if (memFileFrm != 2) return false;

    return true;
  }

  String? decryptAndDecodeFile(String inputPath, {bool verbose = false}) {
    if (verbose && kDebugMode) {
      log('Decrypting...');
    }

    final inputFile = File(p.normalize(inputPath));

    if (!inputFile.existsSync()) {
      if (verbose && kDebugMode) {
        log('File not found!');
      }

      return null;
    }

    final List<int> fileDataB = inputFile.readAsBytesSync();
    final int memFileFrm = _getMemoryFormat(fileDataB.toPointer(), fileDataB.length);

    if (memFileFrm != 2) {
      if (verbose && kDebugMode) {
        log('File not encrypted!');
      }

      return null;
    }

    final filename = p.basenameWithoutExtension(inputFile.path);
    final sufix = p.extension(inputFile.path);
    final dirname = p.dirname(inputFile.path);

    final outputFile = File(p.join(dirname, '${filename}Temp.$sufix'));

    if (outputFile.existsSync()) outputFile.createSync(recursive: true);

    final result = _decryptAndDecodeFile(inputFile.path.toNativeUtf8(), outputFile.path.toNativeUtf8());

    if (result == 0) {
      if (verbose && kDebugMode) {
        log('Decrypted!');
      }

      final content = outputFile.readAsStringSync();

      outputFile.deleteSync();

      return content;
    } else {
      if (verbose && kDebugMode) {
        log('Error decrypting!');
      }

      outputFile.deleteSync();

      return null;
    }
  }
}

extension ListIntPointer on List<int> {
  Pointer<Uint8> toPointer() {
    final pointer = malloc<Uint8>(length);
    for (int i = 0; i < length; i++) {
      pointer[i] = this[i];
    }
    return pointer;
  }
}

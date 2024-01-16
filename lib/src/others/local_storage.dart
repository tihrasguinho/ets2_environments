import 'dart:convert';
import 'dart:io';

abstract interface class LocalStorage {
  void setString(String key, String value);
  void setInt(String key, int value);
  void setBool(String key, bool value);
  void setDouble(String key, double value);
  void setStringList(String key, List<String> value);
  String? getString(String key);
  int? getInt(String key);
  bool? getBool(String key);
  double? getDouble(String key);
  List<String>? getStringList(String key);
  void remove(String key);
  void clear();
  bool containsKey(String key);
}

class LocalStorageImp implements LocalStorage {
  late final File _storage;

  late final Map<String, dynamic> _values;

  LocalStorageImp() {
    _storage = File('./storage.json');

    if (!_storage.existsSync()) {
      _values = {};
      _storage.createSync(recursive: true);
      _storage.writeAsStringSync(jsonEncode(_values));
    } else {
      _values = Map<String, dynamic>.from(jsonDecode(_storage.readAsStringSync()));
    }
  }

  @override
  void clear() async {
    _values.clear();
    _storage.writeAsStringSync(jsonEncode(_values));
  }

  @override
  bool containsKey(String key) {
    return _values.containsKey(key);
  }

  @override
  bool? getBool(String key) {
    if (_values[key] is bool) {
      return _values[key];
    } else {
      return null;
    }
  }

  @override
  double? getDouble(String key) {
    if (_values[key] is double) {
      return _values[key];
    } else {
      return null;
    }
  }

  @override
  int? getInt(String key) {
    if (_values[key] is int) {
      return _values[key];
    } else {
      return null;
    }
  }

  @override
  String? getString(String key) {
    if (_values[key] is String) {
      return _values[key];
    } else {
      return null;
    }
  }

  @override
  List<String>? getStringList(String key) {
    if (_values[key] is List<String>) {
      return _values[key];
    } else {
      return null;
    }
  }

  @override
  void remove(String key) {
    _values.remove(key);
    _storage.writeAsStringSync(jsonEncode(_values));
  }

  @override
  void setBool(String key, bool value) {
    _values[key] = value;
    _storage.writeAsStringSync(jsonEncode(_values));
  }

  @override
  void setDouble(String key, double value) {
    _values[key] = value;
    _storage.writeAsStringSync(jsonEncode(_values));
  }

  @override
  void setInt(String key, int value) {
    _values[key] = value;
    _storage.writeAsStringSync(jsonEncode(_values));
  }

  @override
  void setString(String key, String value) {
    _values[key] = value;
    _storage.writeAsStringSync(jsonEncode(_values));
  }

  @override
  void setStringList(String key, List<String> value) {
    _values[key] = value;
    _storage.writeAsStringSync(jsonEncode(_values));
  }
}

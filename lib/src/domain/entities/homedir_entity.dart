import 'dart:convert';
import 'dart:io';

class HomedirEntity {
  final String name;
  final Directory directory;
  final bool isDefault;
  final DateTime createdAt;

  String get homedirPathView => '${directory.path}\\Euro Truck Simulator 2';

  HomedirEntity({
    required this.name,
    required this.directory,
    required this.isDefault,
    required this.createdAt,
  });

  HomedirEntity copyWith({
    String? name,
    Directory? directory,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return HomedirEntity(
      name: name ?? this.name,
      directory: directory ?? this.directory,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'directory': directory.path,
      'isDefault': isDefault,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory HomedirEntity.fromMap(Map<String, dynamic> map) {
    return HomedirEntity(
      name: map['name'] as String,
      directory: Directory(map['directory'] as String),
      isDefault: map['isDefault'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory HomedirEntity.fromJson(String source) => HomedirEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'HomedirEntity(name: $name, directory: $directory, isDefault: $isDefault, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant HomedirEntity other) {
    if (identical(this, other)) return true;

    return other.name == name && other.directory == directory && other.isDefault == isDefault && other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return name.hashCode ^ directory.hashCode ^ isDefault.hashCode ^ createdAt.hashCode;
  }
}

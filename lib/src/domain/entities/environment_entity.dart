import 'dart:convert';

import 'package:ets2_environments/src/domain/entities/homedir_entity.dart';
import 'package:flutter/foundation.dart';

class EnvironmentEntity {
  final List<HomedirEntity> homedirs;

  EnvironmentEntity({
    required this.homedirs,
  });

  factory EnvironmentEntity.empty() {
    return EnvironmentEntity(
      homedirs: [],
    );
  }

  EnvironmentEntity copyWith({
    List<HomedirEntity>? homedirs,
  }) {
    return EnvironmentEntity(
      homedirs: homedirs ?? this.homedirs,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'homedirs': homedirs.map((x) => x.toMap()).toList(),
    };
  }

  factory EnvironmentEntity.fromMap(Map<String, dynamic> map) {
    return EnvironmentEntity(
      homedirs: List<HomedirEntity>.from(
        (map['homedirs'] as List).map<HomedirEntity>(
          (x) => HomedirEntity.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory EnvironmentEntity.fromJson(String source) => EnvironmentEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'EnvironmentEntity(homedirs: $homedirs)';

  @override
  bool operator ==(covariant EnvironmentEntity other) {
    if (identical(this, other)) return true;

    return listEquals(other.homedirs, homedirs);
  }

  @override
  int get hashCode => homedirs.hashCode;
}

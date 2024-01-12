import 'dart:convert';

import 'package:flutter/foundation.dart';

class ProfileEntity {
  final String profileName;
  final String companyName;
  final List<String> activeMods;

  ProfileEntity({
    required this.profileName,
    required this.companyName,
    required this.activeMods,
  });

  ProfileEntity copyWith({
    String? profileName,
    String? companyName,
    List<String>? activeMods,
  }) {
    return ProfileEntity(
      profileName: profileName ?? this.profileName,
      companyName: companyName ?? this.companyName,
      activeMods: activeMods ?? this.activeMods,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'profileName': profileName,
      'companyName': companyName,
      'activeMods': activeMods,
    };
  }

  factory ProfileEntity.fromMap(Map<String, dynamic> map) {
    return ProfileEntity(
      profileName: map['profileName'] as String,
      companyName: map['companyName'] as String,
      activeMods: List<String>.from((map['activeMods'] as List)),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileEntity.fromJson(String source) => ProfileEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ProfileEntity(profileName: $profileName, companyName: $companyName, activeMods: $activeMods)';

  @override
  bool operator ==(covariant ProfileEntity other) {
    if (identical(this, other)) return true;

    return other.profileName == profileName && other.companyName == companyName && listEquals(other.activeMods, activeMods);
  }

  @override
  int get hashCode => profileName.hashCode ^ companyName.hashCode ^ activeMods.hashCode;
}

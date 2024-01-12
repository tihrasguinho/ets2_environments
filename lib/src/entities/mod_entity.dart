import 'dart:convert';

import 'package:flutter/foundation.dart';

class ModEntity {
  final String displayName;
  final String packageVersion;
  final String author;
  final List<String> categories;
  final List<String> compatibleVersions;

  ModEntity({
    required this.displayName,
    required this.packageVersion,
    required this.author,
    required this.categories,
    required this.compatibleVersions,
  });

  ModEntity copyWith({
    String? displayName,
    String? packageVersion,
    String? author,
    List<String>? categories,
    List<String>? compatibleVersions,
  }) {
    return ModEntity(
      displayName: displayName ?? this.displayName,
      packageVersion: packageVersion ?? this.packageVersion,
      author: author ?? this.author,
      categories: categories ?? this.categories,
      compatibleVersions: compatibleVersions ?? this.compatibleVersions,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'displayName': displayName,
      'packageVersion': packageVersion,
      'author': author,
      'categories': categories,
      'compatibleVersions': compatibleVersions,
    };
  }

  factory ModEntity.fromMap(Map<String, dynamic> map) {
    return ModEntity(
      displayName: map['displayName'] as String,
      packageVersion: map['packageVersion'] as String,
      author: map['author'] as String,
      categories: List<String>.from((map['categories'] as List)),
      compatibleVersions: List<String>.from((map['compatibleVersions'] as List)),
    );
  }

  String toJson() => json.encode(toMap());

  factory ModEntity.fromJson(String source) => ModEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ModEntity(displayName: $displayName, packageVersion: $packageVersion, author: $author, categories: $categories, compatibleVersions: $compatibleVersions)';
  }

  @override
  bool operator ==(covariant ModEntity other) {
    if (identical(this, other)) return true;

    return other.displayName == displayName &&
        other.packageVersion == packageVersion &&
        other.author == author &&
        listEquals(other.categories, categories) &&
        listEquals(other.compatibleVersions, compatibleVersions);
  }

  @override
  int get hashCode {
    return displayName.hashCode ^ packageVersion.hashCode ^ author.hashCode ^ categories.hashCode ^ compatibleVersions.hashCode;
  }
}

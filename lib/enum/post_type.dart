import 'package:flutter/material.dart';

enum PostType {
  GENERAL,
  SKILL,
  EQUIPMENT
}

extension PostTypeExtension on PostType {
  // 한글명 반환
  String get label {
    switch (this) {
      case PostType.GENERAL:
        return "자유";
      case PostType.SKILL:
        return "기술";
      case PostType.EQUIPMENT:
        return "장비";
    }
  }

  // 영문 반환
  String get value => name;

  Color get color {
    switch (this) {
      case PostType.GENERAL:
        return Colors.blue.withOpacity(0.3);
      case PostType.SKILL:
        return Colors.green.withOpacity(0.3);
      case PostType.EQUIPMENT:
        return Colors.orange.withOpacity(0.3);
    }
  }

  // 문자열로부터 enum 값 반환
  static PostType fromString(String postType) {
    return PostType.values.firstWhere(
      (e) => e.name.toUpperCase() == postType.toUpperCase(),
      orElse: () => PostType.GENERAL
    );
  }
}
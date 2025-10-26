import 'package:flutter/material.dart';

enum PostSortOption {
  CREATED_DESC,
  CREATED_ASC
}

extension PostSortOptionExtension on PostSortOption {
  // 한글명 반환
  String get label {
    switch (this) {
      case PostSortOption.CREATED_DESC:
        return "최신순";
      case PostSortOption.CREATED_ASC:
        return "오래된순";
    }
  }

  // 영문 반환
  String get value => name;

  // 문자열로부터 enum 값 반환
  static PostSortOption fromString(String postSortPostSortOption) {
    return PostSortOption.values.firstWhere(
      (e) => e.name.toUpperCase() == postSortPostSortOption.toUpperCase(),
      orElse: () => PostSortOption.CREATED_DESC
    );
  }

  // PostSortOption의 label을 리스트로 반환
  static List<String> get labels =>
    PostSortOption.values.map((e) => e.label).toList();
}
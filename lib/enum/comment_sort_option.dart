import 'package:flutter/material.dart';

enum CommentSortOption {
  CREATED_DESC,
  CREATED_ASC
}

extension CommentSortOptionExtension on CommentSortOption {
  // 한글명 반환
  String get label {
    switch (this) {
      case CommentSortOption.CREATED_DESC:
        return "최신순";
      case CommentSortOption.CREATED_ASC:
        return "오래된순";
    }
  }

  // 영문 반환
  String get value => name;

  // 문자열로부터 enum 값 반환
  static CommentSortOption fromString(String commentSortOption) {
    return CommentSortOption.values.firstWhere(
      (e) => e.name.toUpperCase() == commentSortOption.toUpperCase(),
      orElse: () => CommentSortOption.CREATED_DESC
    );
  }

  // PostSortOption의 label을 리스트로 반환
  static List<String> get labels =>
    CommentSortOption.values.map((e) => e.label).toList();
}
enum ReviewType {
  RECEIVED,
  WRITTEN
}

extension ReviewTypeExtension on ReviewType {
  static ReviewType fromString(String type) {
    return ReviewType.values.firstWhere(
      (e) => e.name.toUpperCase() == type.toUpperCase(),
      orElse: () => ReviewType.WRITTEN // 기본값
    );
  }

  String get toKorean {
    switch (this) {
      case ReviewType.RECEIVED:
        return "받은 리뷰";
      case ReviewType.WRITTEN:
        return "작성한 리뷰";
    }
  }

  String get toValue => name;
}
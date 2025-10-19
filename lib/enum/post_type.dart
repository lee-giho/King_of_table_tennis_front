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

  // 문자열로부터 enum 값 반환
  static PostType fromValue(String value) {
    return PostType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => PostType.GENERAL
    );
  }
}
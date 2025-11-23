enum RankingSortOption {
  WIN_RATE,
  WIN_COUNT
}

extension RankingSortOptionExtension on RankingSortOption {
  // 한글명 반환
  String get label {
    switch (this) {
      case RankingSortOption.WIN_RATE:
        return "승률순";
      case RankingSortOption.WIN_COUNT:
        return "승리 수 순";
    }
  }

  // 영문 반환
  String get value => name;

  // 문자열로부터 enum 값 반환
  static RankingSortOption fromString(String rankingSortOption) {
    return RankingSortOption.values.firstWhere(
      (e) => e.name.toUpperCase() == rankingSortOption.toUpperCase(),
      orElse: () => RankingSortOption.WIN_RATE
    );
  }

  // PostSortOption의 label을 리스트로 반환
  static List<String> get labels =>
    RankingSortOption.values.map((e) => e.label).toList();
}
enum SearchUserRange {
  FRIEND,
  ALL
}

extension SearchUserRangeExtension on SearchUserRange {
  // 한글명 반환
  String get label {
    switch (this) {
      case SearchUserRange.FRIEND:
        return "친구";
      case SearchUserRange.ALL:
        return "전체";
    }
  }

  // 영문 반환
  String get value => name;

  // 문자열로부터 enum 값 반환
  static SearchUserRange fromString(String searchUserRange) {
    return SearchUserRange.values.firstWhere(
      (e) => e.name.toUpperCase() == searchUserRange.toUpperCase(),
      orElse: () => SearchUserRange.FRIEND
    );
  }

  // PostSortOption의 label을 리스트로 반환
  static List<String> get labels =>
    SearchUserRange.values.map((e) => e.label).toList();
}
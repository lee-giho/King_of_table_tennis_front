enum FriendStatus {
  NOTHING, // 관계 없음
  REQUESTED, // 요청
  FRIEND, // 친구
  BLOCKED // 차단
}

extension FriendStatusExtension on FriendStatus {
  static FriendStatus fromString(String state) {
    return FriendStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == state.toUpperCase(),
      orElse: () => FriendStatus.NOTHING // 기본값
    );
  }

  String get toKorean {
    switch (this) {
      case FriendStatus.NOTHING:
        return "관계 없음";
      case FriendStatus.REQUESTED:
        return "친구 요청";
      case FriendStatus.FRIEND:
        return "친구";
      case FriendStatus.BLOCKED:
        return "차단";
    }
  }

  String get toValue => name;
}
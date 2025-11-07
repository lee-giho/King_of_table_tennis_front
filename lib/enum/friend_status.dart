enum FriendStatus {
  NOTHING, // 관계 없음
  REQUESTED, // 요청 보냄
  RECEIVED, // 요청 받음
  FRIEND, // 친구
  BLOCKED, // 차단함
  BANED // 차단 당함
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
        return "친구 요청 보냄";
      case FriendStatus.RECEIVED:
        return "친구 요청 받음";
      case FriendStatus.FRIEND:
        return "친구";
      case FriendStatus.BLOCKED:
        return "차단함";
      case FriendStatus.BANED:
        return "차단됨";
    }
  }

  String get toValue => name;
}
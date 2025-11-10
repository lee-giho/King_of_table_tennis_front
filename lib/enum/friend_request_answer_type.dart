enum FriendRequestAnswerType {
  ACCEPT, // 수락
  REJECT // 거절
}

extension FriendRequestAnswerTypeExtension on FriendRequestAnswerType {
  // 한글명 반환
  String get label {
    switch (this) {
      case FriendRequestAnswerType.ACCEPT:
        return "수락";
      case FriendRequestAnswerType.REJECT:
        return "거절";
    }
  }

  // 영문 반환
  String get value => name;

  // 문자열로부터 enum 값 반환
  static FriendRequestAnswerType fromString(String friendRequestAnswerType) {
    return FriendRequestAnswerType.values.firstWhere(
      (e) => e.name.toUpperCase() == friendRequestAnswerType.toUpperCase(),
      orElse: () => FriendRequestAnswerType.ACCEPT
    );
  }
}
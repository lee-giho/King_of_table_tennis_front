class GameUserInfo {
  final String id;
  final String nickName;
  final String profileImage;
  final String racketType;
  int setScore;
  int score;

  GameUserInfo({
    required this.id,
    required this.nickName,
    required this.profileImage,
    required this.racketType,
    required this.setScore,
    required this.score
  });

  factory GameUserInfo.fromJson(Map<String, dynamic> json) {
    return GameUserInfo(
      id: json['id'],
      nickName: json['nickName'],
      profileImage: json['profileImage'],
      racketType: json['racketType'],
      setScore: json['setScore'],
      score: json['score']
    );
  }

  factory GameUserInfo.empty() {
    return GameUserInfo(
      id: '',
      nickName: '',
      profileImage: '',
      racketType: '',
      setScore: 0,
      score: 0
    );
  }

  void incrementScore() {
    score += 1;
  }

  void decrementScore() {
    score -= 1;
  }
}
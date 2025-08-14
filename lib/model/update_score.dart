class UpdateScore {
  final String side;
  final int newScore;

  UpdateScore({
    required this.side,
    required this.newScore
  });

  UpdateScore copyWith({
    String? roomId,
    String? side,
    int? newScore
  }) {
    return UpdateScore(
      side: side ?? this.side,
      newScore: newScore ?? this.newScore
    );
  }

  // JSON -> 객체 변환
  factory UpdateScore.fromJson(Map<String, dynamic> json) {
    return UpdateScore(
      side: json['side'] ?? '',
      newScore: json['newScore'] ?? 0
    );
  }

  // 객체 -> JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'side': side,
      'newScore': newScore
    };
  }
}
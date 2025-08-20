class UpdateSetScore {
  final String side;
  final int newSetScore;

  UpdateSetScore({
    required this.side,
    required this.newSetScore
  });

  UpdateSetScore copyWith({
    String? roomId,
    String? side,
    int? newSetScore
  }) {
    return UpdateSetScore(
      side: side ?? this.side,
      newSetScore: newSetScore ?? this.newSetScore
    );
  }

  // JSON -> 객체 변환
  factory UpdateSetScore.fromJson(Map<String, dynamic> json) {
    return UpdateSetScore(
      side: json['side'] ?? '',
      newSetScore: json['newSetScore'] ?? 0
    );
  }

  // 객체 -> JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'side': side,
      'newSetScore': newSetScore
    };
  }
}
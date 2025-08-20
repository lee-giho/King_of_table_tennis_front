class EndGame {
  final String winner;
  final String loser;

  EndGame({
    required this.winner,
    required this.loser
  });

  EndGame copyWith({
    String? winner,
    String? loser
  }) {
    return EndGame(
      winner: winner ?? this.winner,
      loser: loser ?? this.loser
    );
  }

  // JSON -> 객체 변환
  factory EndGame.fromJson(Map<String, dynamic> json) {
    return EndGame(
      winner: json['winner'] ?? '',
      loser: json['loser'] ?? ''
    );
  }

  // 객체 -> JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'winner': winner,
      'loser': loser
    };
  }
}
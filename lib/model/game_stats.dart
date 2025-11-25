class GameStats {
  final int? totalGames;
  final int? winCount;
  final int? defeatCount;
  final double? winRate;

  GameStats({
    required this.totalGames,
    required this.winCount,
    required this.defeatCount,
    required this.winRate
  });

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      totalGames: json['totalGames'] ?? 0,
      winCount: json['winCount'] ?? 0,
      defeatCount: json['defeatCount'] ?? 0,
      winRate: json['winRate'] ?? 0.0,
    );
  }
}
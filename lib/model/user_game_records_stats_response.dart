import 'package:king_of_table_tennis/model/game_stats.dart';

class UserGameRecordsStatsResponse {
  final GameStats totalStats;
  final GameStats recentStats;

  UserGameRecordsStatsResponse({
    required this.totalStats,
    required this.recentStats
  });

  factory UserGameRecordsStatsResponse.fromJson(Map<String, dynamic> json) {
    return UserGameRecordsStatsResponse(
      totalStats: GameStats.fromJson(json['totalStats']),
      recentStats: GameStats.fromJson(json['recentStats'])
    );
  }
}
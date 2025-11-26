import 'package:king_of_table_tennis/model/game_stats.dart';

class UserGameRecordsStatsResponse {
  final String nickName;
  final String profileImage;
  final GameStats totalStats;
  final GameStats recentStats;

  UserGameRecordsStatsResponse({
    required this.nickName,
    required this.profileImage,
    required this.totalStats,
    required this.recentStats
  });

  factory UserGameRecordsStatsResponse.fromJson(Map<String, dynamic> json) {
    return UserGameRecordsStatsResponse(
      nickName: json['nickName'],
      profileImage: json['profileImage'],
      totalStats: GameStats.fromJson(json['totalStats']),
      recentStats: GameStats.fromJson(json['recentStats'])
    );
  }
}
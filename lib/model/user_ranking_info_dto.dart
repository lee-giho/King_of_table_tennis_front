import 'package:king_of_table_tennis/enum/friend_status.dart';

class UserRankingInfoDto {
  // 기본 정보
  final String id;
  final String nickName;
  final String profileImage;

  // 탁구 정보
  final String racketType;
  final String userLevel;

  // 랭킹 정보
  final int rating;
  final double winRate;
  final int totalGames;
  final int winCount;
  final int defeatCount;
  final int ranking;

  final FriendStatus friendStatus;

  UserRankingInfoDto({
    required this.id,
    required this.nickName,
    required this.profileImage,

    required this.racketType,
    required this.userLevel,

    required this.rating,
    required this.winRate,
    required this.totalGames,
    required this.winCount,
    required this.defeatCount,
    required this.ranking,

    required this.friendStatus
  });

  factory UserRankingInfoDto.fromJson(Map<String, dynamic> json) {
    return UserRankingInfoDto(
      id: json['id'],
      nickName: json['nickName'],
      profileImage: json['profileImage'],

      racketType: json['racketType'],
      userLevel: json['userLevel'],

      rating: json['rating'],
      winRate: json['winRate'],
      totalGames: json['totalGames'],
      winCount: json['winCount'],
      defeatCount: json['defeatCount'],
      ranking: json['ranking'],

      friendStatus: json['friendStatus'] != null
        ? FriendStatusExtension.fromString(json['friendStatus'])
        : FriendStatus.NOTHING
    );
  }

  factory UserRankingInfoDto.empty() {
    return UserRankingInfoDto(
      id: '',
      nickName: '',
      profileImage: '',

      racketType: '',
      userLevel: '',

      rating: 0,
      winRate: 0,
      totalGames: 0,
      winCount: 0,
      defeatCount: 0,
      ranking: 0,

      friendStatus: FriendStatus.NOTHING
    );
  }
}
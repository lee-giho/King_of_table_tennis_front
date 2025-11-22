import 'package:king_of_table_tennis/enum/friend_status.dart';

class UserInfoDTO {
  // 기본 정보
  final String id;
  final String name;
  final String nickName;
  final String email;
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
  final DateTime? lastGameAt;

  final FriendStatus friendStatus;

  UserInfoDTO({
    required this.id,
    required this.name,
    required this.nickName,
    required this.email,
    required this.profileImage,

    required this.racketType,
    required this.userLevel,

    required this.rating,
    required this.winRate,
    required this.totalGames,
    required this.winCount,
    required this.defeatCount,
    required this.lastGameAt,

    required this.friendStatus
  });

  factory UserInfoDTO.fromJson(Map<String, dynamic> json) {
    return UserInfoDTO(
      id: json['id'],
      name: json['name'],
      nickName: json['nickName'],
      email: json['email'],
      profileImage: json['profileImage'],

      racketType: json['racketType'],
      userLevel: json['userLevel'],

      rating: json['rating'],
      winRate: json['winRate'],
      totalGames: json['totalGames'],
      winCount: json['winCount'],
      defeatCount: json['defeatCount'],
      lastGameAt: json['lastGameAt'] != null
        ? DateTime.parse(json['lastGameAt'])
        : null,

      friendStatus: json['friendStatus'] != null
        ? FriendStatusExtension.fromString(json['friendStatus'])
        : FriendStatus.NOTHING
    );
  }

  factory UserInfoDTO.empty() {
    return UserInfoDTO(
      id: '',
      name: '',
      nickName: '',
      email: '',
      profileImage: '',

      racketType: '',
      userLevel: '',

      rating: 0,
      winRate: 0,
      totalGames: 0,
      winCount: 0,
      defeatCount: 0,
      lastGameAt: null,

      friendStatus: FriendStatus.NOTHING
    );
  }
}
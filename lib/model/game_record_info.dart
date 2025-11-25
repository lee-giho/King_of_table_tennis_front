import 'package:king_of_table_tennis/model/gameUserInfo.dart';

class GameRecordInfo {
  final GameUserInfo myInfo;
  final GameUserInfo opponentInfo;

  final String gameInfoId;
  final DateTime gameDate;
  final String place;

  final bool isWin;

  GameRecordInfo({
    required this.myInfo,
    required this.opponentInfo,
    required this.gameInfoId,
    required this.gameDate,
    required this.place,
    required this.isWin
  });

  factory GameRecordInfo.fromJson(Map<String, dynamic> json) {
    return GameRecordInfo(
      myInfo: GameUserInfo.fromJson(json['myInfo']),
      opponentInfo: GameUserInfo.fromJson(json['opponentInfo']),
      gameInfoId: json['gameInfoId'],
      gameDate: DateTime.parse(json['gameDate']),
      place: json['place'],
      isWin: json['win']
    );
  }
}
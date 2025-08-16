import 'package:king_of_table_tennis/model/gameUserInfo.dart';

class BroadcastRoomInfo {
  final String gameInfoId;
  final String roomName;
  final GameUserInfo defender;
  final GameUserInfo challenger;
  final DateTime createdAt;

  BroadcastRoomInfo({
    required this.gameInfoId,
    required this.roomName,
    required this.defender,
    required this.challenger,
    required this.createdAt
  });

  factory BroadcastRoomInfo.fromJson(Map<String, dynamic> json) {
    return BroadcastRoomInfo(
      gameInfoId: json['gameInfoId'],
      roomName: json['roomName'],
      defender: json['defender'] != null
        ? GameUserInfo.fromJson(json['defender'])
        : GameUserInfo.empty(),
      challenger: json['challenger'] != null
        ? GameUserInfo.fromJson(json['challenger'])
        : GameUserInfo.empty(),
      createdAt: DateTime.parse(json['createdAt'])
    );
  }
}
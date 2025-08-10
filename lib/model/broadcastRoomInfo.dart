import 'package:king_of_table_tennis/model/gameUserInfo.dart';

class BroadcastRoomInfo {
  final String roomId;
  final String roomName;
  final String gameInfoId;
  final GameUserInfo defender;
  final GameUserInfo challenger;
  final DateTime createdAt;

  BroadcastRoomInfo({
    required this.roomId,
    required this.roomName,
    required this.gameInfoId,
    required this.defender,
    required this.challenger,
    required this.createdAt
  });

  factory BroadcastRoomInfo.fromJson(Map<String, dynamic> json) {
    return BroadcastRoomInfo(
      roomId: json['roomId'],
      roomName: json['roomName'],
      gameInfoId: json['gameInfoId'],
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
import 'package:king_of_table_tennis/model/user_info_dto.dart';

class PreChatRoom {
  final String id;

  final UserInfoDTO friend;

  final DateTime createdAt;

  final String? lastMessage;
  final DateTime? lastSentAt;

  final int unreadCount;

  PreChatRoom({
    required this.id,
    required this.friend,
    required this.createdAt,
    this.lastMessage,
    this.lastSentAt,
    this.unreadCount = 0
  });

  factory PreChatRoom.fromJson(Map<String, dynamic> json) {
    return PreChatRoom(
      id: json['id'],
      friend: json['friend'] != null
        ? UserInfoDTO.fromJson(json['friend'])
        : UserInfoDTO.empty(),
      createdAt: DateTime.parse(json['createdAt']),
      lastMessage: json['lastMessage'],
      lastSentAt: json['lastSentAt'] != null
        ? DateTime.parse(json['lastSentAt'])
        : null,
      unreadCount: json['unreadCount'] ?? 0
    );
  }
}
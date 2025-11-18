class ChatMessage {
  final int id;
  
  final String roomId;
  final String senderId;

  final String content;

  final DateTime sentAt;
  
  final int unreadCount;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.unreadCount
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      roomId: json['roomId'],
      senderId: json['senderId'],
      content: json['content'],
      sentAt: DateTime.parse(json['sentAt']),
      unreadCount: json['unreadCount']
    );
  }

  ChatMessage copywith({
    int? unreadCount
  }) {
    return ChatMessage(
      id: id,
      roomId: roomId,
      senderId: senderId,
      content: content,
      sentAt: sentAt,
      unreadCount: unreadCount ?? this.unreadCount
    );
  }
}
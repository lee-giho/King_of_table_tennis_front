class ChatMessage {
  final int id;
  
  final String roomId;
  final String senderId;

  final String content;

  final DateTime sentAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.sentAt
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      roomId: json['roomId'],
      senderId: json['senderId'],
      content: json['content'],
      sentAt: DateTime.parse(json['sentAt'])
    );
  }
}
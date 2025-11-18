class ReadMessageEvent {
  final String roomId;
  final String readerId;
  final int? lastReadMessageId;
  final DateTime? lastReadAt;

  ReadMessageEvent({
    required this.roomId,
    required this.readerId,
    required this.lastReadMessageId,
    required this.lastReadAt
  });

  factory ReadMessageEvent.fromJson(Map<String, dynamic> json) {
    return ReadMessageEvent(
      roomId: json['roomId'],
      readerId: json['readerId'],
      lastReadMessageId: json['lastReadMessageId'],
      lastReadAt: json['lastReadAt'] != null
        ? DateTime.parse(json['lastReadAt'])
        : null
    );
  }
}
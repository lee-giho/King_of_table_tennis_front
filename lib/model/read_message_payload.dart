class ReadMessagePayload {
  final String roomId;
  final int lastReadMessageId;

  ReadMessagePayload({
    required this.roomId,
    required this.lastReadMessageId
  });

  factory ReadMessagePayload.fromJson(Map<String, dynamic> json) {
    return ReadMessagePayload(
      roomId: json['roomId'],
      lastReadMessageId: json['lastReadMessageId']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "roomId": roomId,
      "lastReadMessageId": lastReadMessageId
    };
  }
}
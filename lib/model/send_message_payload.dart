class SendMessagePayload {
  final String roomId;
  final String content;

  SendMessagePayload({
    required this.roomId,
    required this.content
  });

  factory SendMessagePayload.fromJson(Map<String, dynamic> json) {
    return SendMessagePayload(
      roomId: json['roomId'],
      content: json['content']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "roomId": roomId,
      "content": content
    };
  }
}
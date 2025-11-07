class FriendRequest {
  final String? receiverId;

  FriendRequest({
    this.receiverId
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      receiverId: json['receiverId']
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (receiverId != null) data['receiverId'] = receiverId;
    return data;
  }
}
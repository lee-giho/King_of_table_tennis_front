class RegisterCommentRequest {
  final String? content;

  RegisterCommentRequest({
    this.content
  });

  factory RegisterCommentRequest.fromJson(Map<String, dynamic> json) {
    return RegisterCommentRequest(
      content: json['content']
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (content != null) data['content'] = content;
    return data;
  }
}
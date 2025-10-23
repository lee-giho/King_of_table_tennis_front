class RegisterPostRequest {
  final String? title;
  final String? category;
  final String? content;

  RegisterPostRequest({
    this.title,
    this.category,
    this.content
  });

  factory RegisterPostRequest.fromJson(Map<String, dynamic> json) {
    return RegisterPostRequest(
      title: json['title'],
      category: json['category'],
      content: json['content']
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (category != null) data['category'] = category;
    if (content != null) data['content'] = content;
    return data;
  }
}
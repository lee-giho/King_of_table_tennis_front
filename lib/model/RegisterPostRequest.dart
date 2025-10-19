class RegisterPostRequest {
  final String title;
  final String category;
  final String content;

  RegisterPostRequest({
    required this.title,
    required this.category,
    required this.content
  });

  factory RegisterPostRequest.fromJson(Map<String, dynamic> json) {
    return RegisterPostRequest(
      title: json['title'],
      category: json['category'],
      content: json['content']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "category": category,
      "content": content
    };
  }
}
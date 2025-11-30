class RandomGameTitleResponse {
  final String randomTitle;

  RandomGameTitleResponse({
    required this.randomTitle
  });

  factory RandomGameTitleResponse.fromJson(Map<String, dynamic> json) {
    return RandomGameTitleResponse(
      randomTitle: json['randomTitle']
    );
  }
}
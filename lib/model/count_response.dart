class CountResponse {
  final int count;

  CountResponse({
    required this.count
  });

  factory CountResponse.fromJson(Map<String, dynamic> json) {
    return CountResponse(
      count: json['count']
    );
  }
}
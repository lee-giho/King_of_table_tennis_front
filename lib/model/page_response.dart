class PageResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int pageNumber;
  final int pageSize;

  PageResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.pageNumber,
    required this.pageSize
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT
  ) {
    return PageResponse<T>(
      content: (json['content'] as List<dynamic>)
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList(),
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize']
    );
  }
}
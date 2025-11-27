class VideoInfo {
  final String id;
  final String title;


  VideoInfo({
    required this.id,
    required this.title
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id'],
      title: json['title']
    );
  }
}
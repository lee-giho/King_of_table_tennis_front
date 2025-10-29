import 'package:king_of_table_tennis/model/user_info_dto.dart';

class Comment {
  final String id;
  final UserInfoDTO writer;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isMine;

  Comment({
    required this.id,
    required this.writer,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.isMine
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      writer: json['writer'] != null
        ? UserInfoDTO.fromJson(json['writer'])
        : UserInfoDTO.empty(),
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
      isMine: json['mine']
    );
  }
}
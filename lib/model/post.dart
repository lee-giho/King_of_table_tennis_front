import 'package:king_of_table_tennis/enum/post_type.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';

class Post {
  final String id;
  final UserInfoDTO writer;
  
  final String title;
  final PostType category;

  final String content;

  final DateTime writeAt;


  Post({
    required this.id,
    required this.writer,
    required this.title,
    required this.category,
    required this.content,
    required this.writeAt
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      writer: json['writer'] != null
        ? UserInfoDTO.fromJson(json['writer'])
        : UserInfoDTO.empty(),
      title: json['title'],
      category: PostTypeExtension.fromString(json['category']),
      content: json['content'],
      writeAt: DateTime.parse(json['writeAt']),
    );
  }
}
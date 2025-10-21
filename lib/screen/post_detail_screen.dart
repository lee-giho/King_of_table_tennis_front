import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/enum/post_type.dart';
import 'package:king_of_table_tennis/model/post.dart';
import 'package:king_of_table_tennis/util/intl.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({
    super.key,
    required this.post
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container( // 전체화면
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  widget.post.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.black
                      ),
                      borderRadius: BorderRadius.circular(15),
                      color: widget.post.category.color
                    ),
                    child: Text(
                      widget.post.category.label,
                      style: TextStyle(
                        fontSize: 12
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container( // 본문
                  width: double.infinity,
                  child: Text(
                    widget.post.content
                  ),
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipOval( // 프로필 사진
                        child: widget.post.writer.profileImage == "default"
                            ? Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1
                                  ),
                                  shape: BoxShape.circle
                                ),
                                child: const Icon(
                                    Icons.person,
                                    size: 20
                                  ),
                            )
                            : Image(
                                width: 26,
                                height: 26,
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  "${dotenv.env["API_ADDRESS"]}/image/profile/${widget.post.writer.profileImage}"
                                )
                              )
                      ),
                      SizedBox(width: 5),
                      Text(
                        widget.post.writer.nickName,
                        style: TextStyle(
                          fontSize: 20
                        ),
                      )
                    ],
                  ),
                  Text(
                    formatDateTime(widget.post.writeAt)
                  )
                ],
              )
            ],
          )
        )
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/api/post_api.dart';
import 'package:king_of_table_tennis/enum/post_type.dart';
import 'package:king_of_table_tennis/model/post.dart';
import 'package:king_of_table_tennis/screen/post_update_screen.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/intl.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final VoidCallback? onUpdatePost;
  const PostDetailScreen({
    super.key,
    required this.postId,
    this.onUpdatePost
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {

  Post? post;

  @override
  void initState() {
    super.initState();

    handleGetPostById(widget.postId);
  }

  void handleGetPostById(String postId) async {
    final response = await apiRequest(() => getPostById(postId), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final postResponse = Post.fromJson(data);

      setState(() {
        post = postResponse;
      });
    } else {
      ToastMessage.show("게시글을 가져오는 중 오류가 발생했습니다.");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    void handleDeletePost(String postId) async {
      final response = await apiRequest(() => deleteMyPost(postId), context);

      if (response.statusCode == 204) {
        ToastMessage.show("게시글이 삭제되었습니다.");

        Navigator.pop(context, true);
      } else {
        ToastMessage.show("게시글이 삭제되지 않았습니다.");
      }
    }

    Widget buildPostMoreMenu({
      required BuildContext context,
      required VoidCallback onEdit,
      required VoidCallback onDelete
    }) {
      return PopupMenuButton<String> (
        icon: const Icon(
          Icons.more_horiz
        ),
        offset: const Offset(0, 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
        ),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: "edit",
            height: 40,
            child: Row (
              children: [
                Icon(
                  Icons.edit,
                  size: 18,
                  color: AppColors.tableBlue,
                ),
                SizedBox(width: 8),
                Text(
                  "게시글 수정하기",
                  style: TextStyle(
                    color: AppColors.tableBlue
                  ),
                )
              ],
            )
          ),
          const PopupMenuItem(
            value: "delete",
            height: 40,
            child: Row (
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.racketRed,
                ),
                SizedBox(
                  width: 8
                ),
                Text(
                  "게시글 삭제하기",
                  style: TextStyle(
                    color: AppColors.racketRed
                  ),
                )
              ]
            )
          )
        ],
        onSelected: (value) async {
          if (value == "edit") {
            onEdit();
          } else if (value == "delete") {
            final confirm = await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text(
                  "게시글 삭제"
                ),
                content: const Text(
                  "정말로 이 게시글를 삭제하시겠습니까?"
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx, false);
                    },
                    child: const Text(
                      "닫기"
                    )
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx, true);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.racketRed
                    ),
                    child: const Text(
                      "삭제하기"
                    )
                  )
                ],
              )
            );
            if (confirm == true) {
              onDelete();
            }
          }
        }
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          buildPostMoreMenu(
            context: context,
            onEdit: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostUpdateScreen(
                    post: post!
                  )
                )
              );

              if (updated == true) {
                handleGetPostById(widget.postId);
                widget.onUpdatePost?.call();
              }
            },
            onDelete: () {
              handleDeletePost(post!.id);
            }
          ),
        ],
      ),
      body: SafeArea(
        child: post == null
        ? const CircularProgressIndicator()
        : Container( // 전체화면
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  post!.title,
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
                      color: post!.category.color
                    ),
                    child: Text(
                      post!.category.label,
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
                    post!.content
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
                        child: post!.writer.profileImage == "default"
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
                                  "${dotenv.env["API_ADDRESS"]}/image/profile/${post!.writer.profileImage}"
                                )
                              )
                      ),
                      SizedBox(width: 5),
                      Text(
                        post!.writer.nickName,
                        style: TextStyle(
                          fontSize: 20
                        ),
                      )
                    ],
                  ),
                  Text(
                    formatDateTime(post!.writeAt)
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
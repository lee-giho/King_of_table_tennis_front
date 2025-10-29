import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/model/comment.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/intl.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onDelete;

  const CommentTile({
    super.key,
    required this.comment,
    this.onDelete
  });

  @override
  Widget build(BuildContext context) {

    Widget buildCommentMoreMenu({
      required BuildContext context,
      required VoidCallback onEdit,
      required VoidCallback onDelete
    }) {
      return PopupMenuButton<String> (
        icon: const Icon(
          Icons.more_horiz,
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
                  "댓글 수정하기",
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
                  "댓글 삭제하기",
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
                  "댓글 삭제"
                ),
                content: const Text(
                  "정말로 이 댓글을 삭제하시겠습니까?"
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

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval( // 프로필 사진
              child: comment.writer.profileImage == "default"
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
                        "${dotenv.env["API_ADDRESS"]}/image/profile/${comment.writer.profileImage}"
                      )
                    )
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        comment.writer.nickName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      comment.content
                    ),
                  )
                ]
              )
            ),
            if (onDelete != null)
              buildCommentMoreMenu(
                context: context,
                onEdit: () async {
                  
                },
                onDelete: () {
                  
                }
              )
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            formatDateTime(comment.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey
            ),
          ),
        )
      ],
    );
  }
}
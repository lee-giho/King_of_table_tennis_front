import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/api/comment_api.dart';
import 'package:king_of_table_tennis/model/RegisterCommentRequest.dart';
import 'package:king_of_table_tennis/model/comment.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/intl.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;
  final VoidCallback? onDelete;
  final VoidCallback reloadComment;

  const CommentTile({
    super.key,
    required this.comment,
    this.onDelete,
    required this.reloadComment
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile>{

  bool isUpdateMode = false;

  var commentController = TextEditingController();
  FocusNode commentFocus = FocusNode();

  @override
  void dispose() {
    commentController.dispose();
    commentFocus.dispose();

    super.dispose();
  }

  Future<bool> handlePatchComment(String commentId, RegisterCommentRequest registerCommentRequest) async {
    final response = await apiRequest(() => patchMyComment(commentId, registerCommentRequest), context);

    if (response.statusCode == 204) {
      ToastMessage.show("댓글이 수정되었습니다.");
      return true;
    } else {
      ToastMessage.show("댓글이 수정되지 않았습니다.");
      return false;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval( // 프로필 사진
              child: widget.comment.writer.profileImage == "default"
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
                        "${dotenv.env["API_ADDRESS"]}/image/profile/${widget.comment.writer.profileImage}"
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
                        widget.comment.writer.nickName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      widget.comment.content
                    ),
                  )
                ]
              )
            ),
            if (widget.onDelete != null)
              buildCommentMoreMenu(
                context: context,
                onEdit: () async {
                  setState(() {
                    commentController.text = widget.comment.content;
                    isUpdateMode = true;
                  });
                },
                onDelete: () {
                  widget.onDelete?.call();
                }
              )
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            formatDateTime(widget.comment.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey
            ),
          ),
        ),
        if (widget.comment.updatedAt != null)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${formatDateTime(widget.comment.updatedAt!)}(수정)",
              style: TextStyle(
                fontSize: 12,
                color: const Color.fromARGB(255, 51, 118, 53)
              ),
            ),
          ),
        if (isUpdateMode)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: commentController,
                  focusNode: commentFocus,
                  textInputAction: TextInputAction.send,
                  maxLength: 400,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "댓글을 입력하세요.",
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                    )
                  ),
                  onSubmitted: (_) async {
                    // if (commentController.text.trim().isNotEmpty) {
                    //   final result = await handleRegisterComment(
                    //     post!.id,
                    //     RegisterCommentRequest(
                    //       content: commentController.text
                    //     )
                    //   );
                      
                    //   if (result) {
                    //     handleGetComment(widget.postId, commentPage, commentPageSize, selectedSort, showMyComment);
                    //   }
                    // } else {
                    //   ToastMessage.show("댓글을 작성해주세요.");
                    // }
                    ToastMessage.show("댓글 수정");
                  }
                )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton( // 수정 취소
                    onPressed: () {
                      setState(() {
                        commentController.clear();
                        isUpdateMode = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.racketRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      side: BorderSide(
                        width: 0.5
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                    ),
                    child: Text(
                      "취소",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    )
                  ),
                  OutlinedButton( // 수정하기
                    onPressed: () async {
                      if (commentController.text != widget.comment.content) {
                        if (commentController.text.trim().isNotEmpty) {
                          bool response = await handlePatchComment(
                            widget.comment.id,
                            RegisterCommentRequest(
                              content: commentController.text
                            )
                          );

                          if (response) {
                            setState(() {
                              isUpdateMode = false;
                              commentController.clear();
                            });
                            widget.reloadComment.call();
                          }
                        } else {
                          ToastMessage.show("댓글을 작성해주세요.");
                        }
                      } else {
                        ToastMessage.show("댓글을 수정해주세요.");
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.tableBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      side: BorderSide(
                        width: 0.5
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                    ),
                    child: Text(
                      "수정",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    )
                  ),
                ]
              )
            ]
          )
      ]
    );
  }
}
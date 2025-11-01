import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/api/post_api.dart';
import 'package:king_of_table_tennis/enum/comment_sort_option.dart';
import 'package:king_of_table_tennis/enum/post_type.dart';
import 'package:king_of_table_tennis/model/RegisterCommentRequest.dart';
import 'package:king_of_table_tennis/model/comment.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/post.dart';
import 'package:king_of_table_tennis/screen/post_update_screen.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/intl.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/commentTile.dart';
import 'package:king_of_table_tennis/widget/customDivider.dart';
import 'package:king_of_table_tennis/widget/customStringPicker.dart';
import 'package:king_of_table_tennis/widget/paginationBar.dart';

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

  // 댓글
  var commentController = TextEditingController();
  FocusNode commentFocus = FocusNode();
  
  int commentPage = 0;
  int commentPageSize = 10;
  int commentTotalPages = 0;
  int commentTotalElements = 0;

  CommentSortOption selectedSort = CommentSortOption.CREATED_DESC;

  List<Comment> comments = [];

  bool commentLoading = false;
  bool sending = false;

  @override
  void initState() {
    super.initState();

    handleGetPostById(widget.postId);
    handleGetComment(widget.postId, commentPage, commentPageSize, selectedSort);
  }

  @override
  void dispose() {
    commentController.dispose();
    commentFocus.dispose();

    super.dispose();
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

  void handleGetComment(String postId, int page, int size, CommentSortOption sort) async {
    
    setState(() {
      commentLoading = true;
    });

    final response = await apiRequest(() => getComments(postId, page, size, sort), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pageResponse = PageResponse<Comment>.fromJson(
        data,
        (json) => Comment.fromJson(json)
      );

      final int totalPages = pageResponse.totalPages;

      if (pageResponse.content.isEmpty && totalPages > 0 && page >= totalPages) {
        final int lastPage = totalPages - 1;
        if (lastPage != page) {
          if (!mounted) return;
          setState(() {
            commentPage = lastPage;
            comments = [];
            commentTotalPages = pageResponse.totalPages;
          });
          handleGetComment(postId, page, size, sort);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        comments = pageResponse.content;
        commentTotalPages = totalPages;
        commentTotalElements = pageResponse.totalElements;
        commentPage = page;
      });
    } else {
      log("댓글 가져오기 실패");
    }

    setState(() {
      commentLoading = false;
    });
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

    Future<bool> handleRegisterComment(String postId, RegisterCommentRequest registerCommentRequest) async {
      setState(() {
        sending = true;
      });

      final response = await apiRequest(() => registerComment(postId, registerCommentRequest), context);

      setState(() {
        sending = false;
      });

      if (response.statusCode == 201) {
        commentController.clear();
        ToastMessage.show("댓글이 등록되었습니다.");
        return true;
      } else {
        ToastMessage.show("댓글이 등록되지 않았습니다.");
        return false;
      }
    }

    Future<void> refreshComments() async {
      commentPage = 0;
      selectedSort = CommentSortOption.CREATED_DESC;
      handleGetComment(widget.postId, commentPage, commentPageSize, selectedSort);
    }

    Future<void> selectSortOption() async {
      final result = await showCustomStringPicker(
        context: context,
        options: CommentSortOptionExtension.labels,
        initialValue: selectedSort.label
      );

      if (result != null) {
        setState(() {
          selectedSort = CommentSortOption.values.firstWhere(
            (e) => e.label == result,
            orElse: () => selectedSort
          );
          commentPage = 0;
        });
        handleGetComment(widget.postId, commentPage, commentPageSize, selectedSort);
      }
    }

    void goToPage(int page) {
      if (page < 0 || page >= commentTotalPages) return;
      setState(() {
        commentPage = page;
      });
      handleGetComment(widget.postId, commentPage, commentPageSize, selectedSort);
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (post?.isMine == true)
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
                if (post != null)
                  handleDeletePost(post!.id);
              }
            )
        ]
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final FocusScopeNode currentscope = FocusScope.of(context);
          if (!currentscope.hasPrimaryFocus && currentscope.hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: SafeArea(
          child: post == null
          ? const CircularProgressIndicator()
          : RefreshIndicator(
            onRefresh: refreshComments,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding( // 제목
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            post!.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Container( // 카테고리
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
                        CustomDivider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Container( // 본문
                            width: double.infinity,
                            child: Text(
                              post!.content
                            ),
                          ),
                        ),
                        CustomDivider(),
                        Row( // 게시글 정보
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
                                Text( // 작성자 닉네임
                                  post!.writer.nickName,
                                  style: TextStyle(
                                    fontSize: 20
                                  ),
                                )
                              ],
                            ),
                            Column( // 게시글 작성일 or 수정일
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatDateTime(post!.createdAt),
                                ),
                                if (post!.updatedAt != null)
                                  Text(
                                    "${formatDateTime(post!.updatedAt!)}(수정)",
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 51, 118, 53)
                                    )
                                  )
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 60),
                        CustomDivider(opacity: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "댓글 $commentTotalElements",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            OutlinedButton( // 정렬방식 선택
                              onPressed: () {
                                selectSortOption();
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.tableBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                side: BorderSide(
                                  width: 0.5
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sort,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  Text(
                                    selectedSort.label,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black
                                    ),
                                  ),
                                ],
                              )
                            )
                          ]
                        ),
                        SizedBox(height: 20)
                      ],
                    ),
                  ),
                ),
                comments.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Center(
                          child: Text(
                            post!.isMine == false
                              ? "첫 댓글을 남겨보세요"
                              : "댓글이 아직 없습니다."
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (commentLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final comment = comments[index];
                            return Column(
                              children: [
                                CommentTile(
                                  comment: comment,
                                  onDelete: comment.isMine
                                    ? () async {
        
                                      }
                                    : null
                                ),
                                const CustomDivider()
                              ],
                            );
                          },
                          childCount: comments.length + (commentLoading ? 1 : 0)
                        )
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Visibility(
                        visible: commentTotalPages > 1,
                        child: PaginationBar(
                          currentPage: commentPage,
                          totalPages: commentTotalPages,
                          window: 5,
                          onPageChanged: (p) => goToPage(p)
                        ),
                      ),
                    )
              ]
            ),
          )
        ),
      ),
      bottomNavigationBar: post != null && post!.isMine == false
        ? AnimatedContainer(
            duration: Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      focusNode: commentFocus,
                      textInputAction: TextInputAction.send,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "댓글을 입력하세요.",
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)
                        )
                      ),
                      onSubmitted: sending
                        ? null
                        : (_) async {
                            if (commentController.text.trim().isNotEmpty) {
                              final result = await handleRegisterComment(
                                post!.id,
                                RegisterCommentRequest(
                                  content: commentController.text
                                )
                              );
                              
                              if (result) {
                                handleGetComment(widget.postId, commentPage, commentPageSize, selectedSort);
                              }
                            } else {
                              ToastMessage.show("댓글을 작성해주세요.");
                            }
                          },
                    )
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: sending
                      ? null
                      : () async {
                          if (commentController.text.trim().isNotEmpty) {
                            final result = await handleRegisterComment(
                                post!.id,
                                RegisterCommentRequest(
                                  content: commentController.text
                                )
                              );
                              
                              if (result) {
                                handleGetComment(widget.postId, commentPage, commentPageSize, selectedSort);
                              }
                          } else {
                            ToastMessage.show("댓글을 작성해주세요.");
                          }
                        },
                    icon: sending
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator()
                        )
                      : Icon(
                        Icons.send
                      )
                  )
                ],
              )
            ),
          )
        : null
    );
  }
}
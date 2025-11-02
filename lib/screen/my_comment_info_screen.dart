import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/comment_api.dart';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/enum/comment_sort_option.dart';
import 'package:king_of_table_tennis/model/comment.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/screen/post_detail_screen.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/commentTile.dart';
import 'package:king_of_table_tennis/widget/customDivider.dart';
import 'package:king_of_table_tennis/widget/customStringPicker.dart';
import 'package:king_of_table_tennis/widget/paginationBar.dart';

class MyCommentInfoScreen extends StatefulWidget {
  const MyCommentInfoScreen({super.key});

  @override
  State<MyCommentInfoScreen> createState() => _MyCommentInfoScreenState();
}

class _MyCommentInfoScreenState extends State<MyCommentInfoScreen> {

  int commentPage = 0;
  int commentPageSize = 10;
  int commentTotalPages = 0;
  int commentTotalElements = 0;

  CommentSortOption selectedSort = CommentSortOption.CREATED_DESC;

  List<Comment> comments = [];

  bool commentLoading = false;

  @override
  void initState() {
    super.initState();

    handleGetComment(commentPage, commentPageSize, selectedSort);
  }

  void handleGetComment(int page, int pageSize, CommentSortOption selectedSort) async {
    
    setState(() {
      commentLoading = true;
    });
    
    final response = await apiRequest(() => getMyComments(page, pageSize, selectedSort), context);

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
          handleGetComment(page, pageSize, selectedSort);
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

  void handleDeleteComment(String commentId) async {
    final response = await apiRequest(() => deleteMyComment(commentId), context);

    if (response.statusCode == 204) {
      ToastMessage.show("댓글이 삭제되었습니다.");

      handleGetComment(commentPage, commentPageSize, selectedSort);
    } else {
      ToastMessage.show("댓글이 삭제되지 않았습니다.");
    }
  }

  void goToPage(int page) {
    if (page < 0 || page >= commentTotalPages) return;
    setState(() {
      commentPage = page;
    });
    handleGetComment(page, commentPageSize, selectedSort);
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
      handleGetComment(commentPage, commentPageSize, selectedSort);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: comments.isEmpty
            ? const Center(
                child: Text(
                  "작성한 댓글이 없습니다."
                ),
              )
            : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton( // 정렬방식 선택
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
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final comment = comments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          child: InkWell(
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailScreen(
                                    postId: comment.postId,
                                    showMyComment: true,
                                  )
                                )
                              );
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: Column(
                              children: [
                                CommentTile(
                                  comment: comment,
                                  onDelete: () {
                                    handleDeleteComment(comment.id);
                                  },
                                ),
                                const CustomDivider()
                              ],
                            )
                          ),
                        ),
                      );
                    },
                    childCount: comments.length
                  )
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: PaginationBar(
                      currentPage: commentPage,
                      totalPages: commentTotalPages,
                      window: 5,
                      onPageChanged: (p) => goToPage(p)
                    )
                  ),
                )
              ],
            )
        )
      ),
    );
  }
}
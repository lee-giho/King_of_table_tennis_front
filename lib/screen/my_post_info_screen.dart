import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/post.dart';
import 'package:king_of_table_tennis/screen/post_detail_screen.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/paginationBar.dart';
import 'package:king_of_table_tennis/widget/postPreviewTile.dart';

class MyPostInfoScreen extends StatefulWidget {
  const MyPostInfoScreen({super.key});

  @override
  State<MyPostInfoScreen> createState() => _MyPostInfoScreenState();
}

class _MyPostInfoScreenState extends State<MyPostInfoScreen> {

  int postPage = 0;
  int postPageSize = 10;
  int postTotalPages = 0;

  List<Post> posts = [];

  @override
  void initState() {
    super.initState();

    handleGetPost(postPage, postPageSize);
  }

  void handleGetPost(int page, int pageSize) async {
    final response = await apiRequest(() => getMyPost(page, pageSize), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pageResponse = PageResponse<Post>.fromJson(
        data,
        (json) => Post.fromJson(json)
      );

      final int totalPages = pageResponse.totalPages;

      if (pageResponse.content.isEmpty && totalPages > 0 && page >= totalPages) {
        final int lastPage = totalPages - 1;
        if (lastPage != page) {
          if (!mounted) return;
          setState(() {
            postPage = lastPage;
            posts = [];
            postTotalPages = pageResponse.totalPages;
          });
          handleGetPost(lastPage, pageSize);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        posts = pageResponse.content;
        postTotalPages = totalPages;
        postPage = page;
      });
    } else {
      ToastMessage.show("내가 작성한 게시글 가져오기 실패");
    }
  }

  void goToPage(int page) {
    if (page < 0 || page >= postTotalPages) return;
    setState(() {
      postPage = page;
    });
    handleGetPost(page, postPageSize);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "작성한 게시글",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: posts.isEmpty
            ? const Center(
                child: Text(
                  "작성한 게시글이 없습니다."
                ),
              )
            : CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = posts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          child: InkWell(
                            onTap: () async {
                              final deleted = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailScreen(
                                    postId: post.id,
                                    onUpdatePost: () {
                                      handleGetPost(postPage, postPageSize);
                                    },
                                  )
                                )
                              );

                              if (deleted == true) {  
                                final bool lastItemOnThisPage = posts.length == 1;
                                final int nextPage = (lastItemOnThisPage && postPage > 0) ? postPage - 1 : postPage;

                                if (!mounted) return;
                                setState(() {
                                  postPage = nextPage;
                                });

                                handleGetPost(postPage, postPageSize);
                              }
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: PostPreviewTile(
                              post: post
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: posts.length
                  )
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: PaginationBar(
                      currentPage: postPage,
                      totalPages: postTotalPages,
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
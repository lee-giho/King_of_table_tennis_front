import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/post_api.dart';
import 'package:king_of_table_tennis/enum/post_sort_option.dart';
import 'package:king_of_table_tennis/enum/post_type.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/post.dart';
import 'package:king_of_table_tennis/screen/post_detail_screen.dart';
import 'package:king_of_table_tennis/screen/post_registration_screen.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/widget/paginationBar.dart';
import 'package:king_of_table_tennis/widget/customStringPicker.dart';
import 'package:king_of_table_tennis/widget/postPreviewTile.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  bool loading = false;

  var searchKeywordController = TextEditingController();

  FocusNode searchKeywordFocus = FocusNode();

  int postPage = 0;
  int postPageSize = 5;
  int postTotalPages = 0;

  List<PostType> selectedCategories = [
    PostType.GENERAL,
    PostType.SKILL,
    PostType.EQUIPMENT
  ];

  PostSortOption selectedSort = PostSortOption.CREATED_DESC;

  List<Post> posts = [];

  @override
  void initState() {
    super.initState();

    handleGetPost(
      page: postPage,
      size: postPageSize,
      categories: selectedCategories,
      sort: selectedSort
    );
  }

  @override
  void dispose() {
    searchKeywordController.dispose();
    searchKeywordFocus.dispose();

    super.dispose();
  }

  void handleGetPost({
    required int page,
    required int size,
    required List<PostType> categories,
    required PostSortOption sort,
    String? keyword
  }) async {
    setState(() {
      loading = true;
    });
    final response = await apiRequest(
      () => getPost(
          page: page,
          size: size,
          categories: categories,
          sort:  sort,
          keyword: keyword
        ),
        context
    );

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
          handleGetPost(
            page: postPage,
            size: postPageSize,
            categories: selectedCategories,
            sort: selectedSort
          );
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
      log("게시글 가져오기 실패");
    }

    setState(() {
      loading = false;
    });
  }

  String? currentKeywordOrNull() {
    final s = searchKeywordController.text.trim();
    return s.isEmpty ? null : s;
  }

  Future<void> selectSortOption() async {
    final result = await showCustomStringPicker(
      context: context,
      options: PostSortOptionExtension.labels,
      initialValue: selectedSort.label
    );

    if (result != null) {
      setState(() {
        selectedSort = PostSortOption.values.firstWhere(
          (e) => e.label == result,
          orElse: () => selectedSort
        );
        postPage = 0;
      });
      handleGetPost(
        page: postPage,
        size: postPageSize,
        categories: selectedCategories,
        sort: selectedSort,
        keyword: currentKeywordOrNull()
      );
    }
  }

  void goToPage(int page) {
    if (page < 0 || page >= postTotalPages) return;
    setState(() {
      postPage = page;
    });
    handleGetPost(
      page: postPage,
      size: postPageSize,
      categories: selectedCategories,
      sort: selectedSort,
      keyword: currentKeywordOrNull()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "게시글",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onVerticalDragStart: (_) {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Container( // 전체 화면
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row( // 검색바
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchKeywordController,
                                focusNode: searchKeywordFocus,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  hintText: "게시글을 검색해보세요.",
                                  hintStyle: TextStyle(fontSize: 15),
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(121, 55, 64, 0)
                                    )
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color:Color.fromRGBO(122, 11, 11, 0)
                                    )
                                  )
                                ),
                                onChanged:(value) {
                                  setState(() {});
                                },
                                onSubmitted: (_) {
                                  FocusScope.of(context).unfocus();
                                  print(searchKeywordController.text);
                                  setState(() {
                                    postPage = 0;
                                  });
                                  handleGetPost(
                                    page: postPage,
                                    size: postPageSize,
                                    categories: selectedCategories,
                                    sort: selectedSort,
                                    keyword: searchKeywordController.text
                                  );
                                },
                              ),
                            ),
                            if (searchKeywordController.text.isNotEmpty)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  searchKeywordController.clear();
                                  setState(() {
                                    postPage = 0;
                                  });
                                  handleGetPost(
                                    page: postPage,
                                    size: postPageSize,
                                    categories: selectedCategories,
                                    sort: selectedSort
                                  );
                                },
                                icon: const Icon(
                                  Icons.clear,
                                  size: 20,
                                )
                              )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          print(searchKeywordController.text);
                          setState(() {
                            postPage = 0;
                          });
                          handleGetPost(
                            page: postPage,
                            size: postPageSize,
                            categories: selectedCategories,
                            sort: selectedSort,
                            keyword: searchKeywordController.text
                          );
                        },
                        icon: Icon(
                          Icons.search,
                          color: Colors.black,
                        )
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12),
                Row( // 카테고리 및 정렬 방식 선택
                  children: [
                    Expanded( // 카테고리 선택
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: PostType.values.map((option) {
                          final isSelected = selectedCategories.contains(option);
                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                isSelected
                                  ? selectedCategories.remove(option)
                                  : selectedCategories.add(option);
                                postPage = 0;
                              });
                              handleGetPost(
                                page: postPage,
                                size: postPageSize,
                                categories: selectedCategories,
                                sort: selectedSort,
                                keyword: currentKeywordOrNull()
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (_) {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      isSelected
                                        ? selectedCategories.remove(option)
                                        : selectedCategories.add(option);
                                      postPage = 0;
                                    });
                                    handleGetPost(
                                      page: postPage,
                                      size: postPageSize,
                                      categories: selectedCategories,
                                      sort: selectedSort,
                                      keyword: currentKeywordOrNull()
                                    );
                                  },
                                  activeColor: AppColors.tableBlue,
                                ),
                                SizedBox(width: 4),
                                Text(option.label)
                              ],
                            ),
                          );
                        }).toList()
                      )
                    ),
                    SizedBox(width: 10),
                    OutlinedButton( // 정렬방식 선택
                      onPressed: () {
                        FocusScope.of(context).unfocus();
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
                Divider(),
                SizedBox(height: 6),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      final offsetTween = Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero
                      );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: animation.drive(offsetTween),
                          child: child,
                        ),
                      );
                    },
                    child: loading
                      ? Center(
                          child: CircularProgressIndicator()
                        )
                      : posts.isEmpty
                        ? const Center(
                            child: Text(
                              "작성된 게시글이 없습니다."
                            ),
                          )
                        : CustomScrollView(
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                            FocusScope.of(context).unfocus();
                                            final deleted = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PostDetailScreen(
                                                  postId: post.id,
                                                  onUpdatePost: () {
                                                    handleGetPost(
                                                      page: postPage,
                                                      size: postPageSize,
                                                      categories: selectedCategories,
                                                      sort: selectedSort,
                                                      keyword: currentKeywordOrNull()
                                                    );
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
                              
                                              handleGetPost(
                                                page: postPage,
                                                size: postPageSize,
                                                categories: selectedCategories,
                                                sort: selectedSort,
                                                keyword: currentKeywordOrNull()
                                              );
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
                          ),
                  )
                )
              ],
            ),
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.tableBlue,
        onPressed: () {
          FocusScope.of(context).unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostRegistrationScreen()
            )
          ).then((_) {
            handleGetPost(
              page: postPage,
              size: postPageSize,
              categories: selectedCategories,
              sort: selectedSort,
              keyword: currentKeywordOrNull()
            );
          });
        },
        child: Icon(
          Icons.add,
          size: 40,
        ),
      ),
    );
  }
}
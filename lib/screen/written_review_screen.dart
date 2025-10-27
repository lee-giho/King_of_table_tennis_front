import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/review_api.dart';
import 'package:king_of_table_tennis/enum/review_type.dart';
import 'package:king_of_table_tennis/model/game_review.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/paginationBar.dart';
import 'package:king_of_table_tennis/widget/gameReviewTile.dart';

class WrittenReviewScreen extends StatefulWidget {
  const WrittenReviewScreen({super.key});

  @override
  State<WrittenReviewScreen> createState() => _WrittenReviewScreenState();
}

class _WrittenReviewScreenState extends State<WrittenReviewScreen> {

  int gameReviewPage = 0;
  int gameReviewPageSize = 5;
  int gameReviewTotalPages = 0;

  List<GameReview> gameReviews = [];

  @override
  void initState() {
    super.initState();

    handleGetGameReview(gameReviewPage, gameReviewPageSize, ReviewType.WRITTEN.name);
  }

  void handleGetGameReview(int page, int pageSize, String type) async {
    final response = await apiRequest(() => getGameReview(page, pageSize, type), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pageResponse = PageResponse<GameReview>.fromJson(
        data,
        (json) => GameReview.fromJson(json)
      );

      final int totalPages = pageResponse.totalPages;

      if (pageResponse.content.isEmpty && totalPages > 0 && page >= totalPages) {
        final int lastPage = totalPages - 1;
        if (lastPage != page) {
          if (!mounted) return;
          setState(() {
            gameReviewPage = lastPage;
            gameReviews = [];
            gameReviewTotalPages = pageResponse.totalPages;
          });
          handleGetGameReview(lastPage, pageSize, type);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        gameReviews = pageResponse.content;
        gameReviewTotalPages = totalPages;
        gameReviewPage = page;
      });

    } else {
      ToastMessage.show("내가 작성한 리뷰 가져오기 실패");
    }
  }

  void handleDeleteGameReview(String gameReviewId) async {
    final response = await apiRequest(() => deleteGameReview(gameReviewId), context);

    if (response.statusCode == 204) {
      ToastMessage.show("리뷰가 삭제되었습니다.");

      final bool lastItemOnThisPage = gameReviews.length == 1;
      final int nextPage = (lastItemOnThisPage && gameReviewPage > 0) ? gameReviewPage - 1 : gameReviewPage;

      if (!mounted) return;
      setState(() {
        gameReviewPage = nextPage;
      });

      handleGetGameReview(gameReviewPage, gameReviewPageSize, ReviewType.WRITTEN.name);
    } else {
      ToastMessage.show("리뷰가 삭제되지 않았습니다.");
    }
  }

  void goToPage(int page) {
    if (page < 0 || page >= gameReviewTotalPages) return;
    setState(() {
      gameReviewPage = page;
    });
    handleGetGameReview(page, gameReviewPageSize, ReviewType.WRITTEN.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: gameReviews.isEmpty
            ? const Center(
                child: Text(
                  "작성한 리뷰가 없습니다."
                ),
              )
            : CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final gameReview = gameReviews[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          child: InkWell(
                            onTap: () {
                              
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: GameReviewTile(
                              gameReview: gameReview,
                              isWritten: true,
                              onUpdateReview: () {
                                handleGetGameReview(gameReviewPage, gameReviewPageSize, ReviewType.WRITTEN.name);
                              },
                              onDeleteReview: () {
                                handleDeleteGameReview(gameReview.id);
                              },
                            )
                          ),
                        ),
                      );
                    },
                    childCount: gameReviews.length
                  )
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: PaginationBar(
                      currentPage: gameReviewPage,
                      totalPages: gameReviewTotalPages,
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
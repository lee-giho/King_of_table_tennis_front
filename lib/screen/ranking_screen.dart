import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/user_ranking_api.dart';
import 'package:king_of_table_tennis/enum/ranking_sort_option.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/user_ranking_info_dto.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/secure_storage.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/customStringPicker.dart';
import 'package:king_of_table_tennis/widget/myRankCard.dart';
import 'package:king_of_table_tennis/widget/rankingTile.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {

  List<RankingSortOption> sortOptions = [
    RankingSortOption.WIN_RATE,
    RankingSortOption.WIN_COUNT
  ];

  RankingSortOption selectedRankingSortOption = RankingSortOption.WIN_RATE;

  int rankingPage = 0;
  int rankingPageSize = 20;
  int rankingTotalPages = 0;
  int rankingTotalElements = 0;

  bool isLoading = false;
  List<UserRankingInfoDto> userRankings = [];
  UserRankingInfoDto? myRanking;

  @override
  void initState() {
    super.initState();

    handleGetRanking();
  }

  void handleGetRanking() async {
    setState(() {
      isLoading = true;
    });

    await handleGetMyRanking(selectedRankingSortOption);
    await handleGetUserRankings(rankingPage, rankingPageSize, selectedRankingSortOption);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> handleGetUserRankings(int page, int size, RankingSortOption sort) async {
    final response = await apiRequest(() => getUserRankings(page, size, sort), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pageResponse = PageResponse<UserRankingInfoDto>.fromJson(
        data,
        (json) => UserRankingInfoDto.fromJson(json)
      );

      final int totalPages = pageResponse.totalPages;

      if (pageResponse.content.isEmpty && totalPages > 0 && page >= totalPages) {
        final int lastPage = totalPages - 1;
        if (lastPage != page) {
          if (!mounted) return;
          setState(() {
            rankingPage = lastPage;
            userRankings = [];
            rankingTotalPages = pageResponse.totalPages;
          });
          handleGetUserRankings(lastPage, size, sort);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        userRankings = pageResponse.content;
        rankingTotalPages = totalPages;
        rankingPage = page;
        rankingTotalElements = pageResponse.totalElements;
      });
    } else {
      ToastMessage.show("사용자 랭킹 가져오기 실패");
    }
  }

  Future<void> handleGetMyRanking(RankingSortOption sort) async {
    String? myId = await SecureStorage.getId();

    final response = await apiRequest(() => getUserRanking(myId!, sort), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final myRankingResponse = UserRankingInfoDto.fromJson(data);

      setState(() {
        myRanking = myRankingResponse;
      });
    } else {
      ToastMessage.show("내 랭킹을 가져오는 중 오류가 발생했습니다.");
    }
  }

  Future<void> selectSortOption() async {
    final result = await showCustomStringPicker(
      context: context,
      options: RankingSortOptionExtension.labels,
      initialValue: selectedRankingSortOption.label
    );

    if (result != null) {
      setState(() {
        selectedRankingSortOption = RankingSortOption.values.firstWhere(
          (e) => e.label == result,
          orElse: () => selectedRankingSortOption
        );
        rankingPage = 0;
      });

      handleGetRanking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "랭킹",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container( // 전체 화면
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              if (myRanking != null)
                MyRankCard(
                  myRankingInfo: myRanking!,
                  totalUsers: rankingTotalElements
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton( // 정렬방식 선택
                      onPressed: isLoading
                        ? null
                        : () {
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
                            selectedRankingSortOption.label,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black
                            ),
                          ),
                        ],
                      )
                    ),
                ],
              ),
              const SizedBox(height: 8),

              Expanded(
                child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator()
                    )
                  : userRankings.isEmpty
                    ? const Center(
                        child: Text(
                          "랭킹 정보가 없습니다."
                        ),
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final userRanking = userRankings[index];
                                return Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                  child: InkWell(
                                    onTap: () async {
                                
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    child: RankingTile(
                                      userRankingInfo: userRanking
                                    ),
                                  ),
                                );
                              },
                              childCount: userRankings.length
                            )
                          )
                        ],
                      )
              )
            ],
          ),
        )
      ),
    );
  }
}
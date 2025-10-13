import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/recruiting_game_dto.dart';
import 'package:king_of_table_tennis/screen/game_registration_screen.dart';
import 'package:king_of_table_tennis/screen/table_tennis_game_info_detail_screen.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/recruitingGameTile.dart';

class TableTennisCourtDetailRegisteredGameScreen extends StatefulWidget {
  final String tableTennisCourtId;
  final String tableTennisCourtName;
  const TableTennisCourtDetailRegisteredGameScreen({
    super.key,
    required this.tableTennisCourtId,
    required this.tableTennisCourtName
  });

  @override
  State<TableTennisCourtDetailRegisteredGameScreen> createState() => _TableTennisCourtDetailRegisteredGameScreenState();
}

class _TableTennisCourtDetailRegisteredGameScreenState extends State<TableTennisCourtDetailRegisteredGameScreen> {

  int recruitingGamePage = 0;
  int recruitingGamePageSize = 10;
  int recruitingGameTotalPages = 0;
  String type = "REGISTERED";

  List<RecruitingGameDTO> recruitingGames = [];

  @override
  void initState() {
    super.initState();

    handleGetRecruitingGameList(widget.tableTennisCourtId, type, recruitingGamePage, recruitingGamePageSize);
  }

  void handleGetRecruitingGameList(String tableTennisCourtId, String type, int page, int pageSize) async {
    final response = await apiRequest(() => getRecruitingGameList(tableTennisCourtId, type, page, pageSize), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pageResponse = PageResponse<RecruitingGameDTO>.fromJson(
        data,
        (json) => RecruitingGameDTO.fromJson(json)
      );

      final int totalPages = pageResponse.totalPages;

      if (pageResponse.content.isEmpty && totalPages > 0 && page >= totalPages) {
        final int lastPage = totalPages - 1;
        if (lastPage != page) {
          if (!mounted) return;
          setState(() {
            recruitingGamePage = lastPage;
            recruitingGames = [];
            recruitingGameTotalPages = pageResponse.totalPages;
          });
          handleGetRecruitingGameList(tableTennisCourtId, type, page, pageSize);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        recruitingGames = pageResponse.content;
        recruitingGameTotalPages = pageResponse.totalPages;
        recruitingGamePage = page;
      });
    } else {
      ToastMessage.show("등록된 경기 가져오기 실패");
    }
  }

  void goToPage(int page) {
    if (page < 0 || page >= recruitingGameTotalPages) return;
    setState(() {
      page = page;
    });
    handleGetRecruitingGameList(widget.tableTennisCourtId, type, page, recruitingGamePageSize);
  }

  List<int> visiblePages({
    required int current,
    required int total,
    int window = 5
  }) {
    if (total <= 0) return const [];

    int start = current;
    final int remain = total - start;
    if (remain < window) {
      start = (total - window).clamp(0, total - 1);
    }
    final end = (start + window).clamp(0, total);
    return [for (int i = start; i < end; i++) i];
  }

  Widget navButton(String label, {required VoidCallback onTap}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        label == "<"
          ? Icons.arrow_back_ios
          : Icons.arrow_forward_ios,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: recruitingGames.isEmpty
            ? const Center(
                child: Text(
                  "등록된 경기가 없습니다."
                )
              )
            : Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final recruitingGame = recruitingGames[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TableTennisGameInfoDetailScreen(
                                          gameInfoId: recruitingGame.gameInfo.id,
                                          isMine: recruitingGame.isMine
                                        )
                                      )
                                    ).then((_) {
                                      handleGetRecruitingGameList(widget.tableTennisCourtId, type, recruitingGamePage, recruitingGamePageSize);
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(15),
                                  child: RecruitingGameTile(
                                    recruitingGameDTO: recruitingGame,
                                    onApplyComplete: () {
                                      handleGetRecruitingGameList(widget.tableTennisCourtId, type, recruitingGamePage, recruitingGamePageSize);
                                    }
                                  )
                                ),
                              ),
                            );
                          },
                          childCount: recruitingGames.length
                        )
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (recruitingGamePage > 0)
                                navButton("<", onTap: () => goToPage(recruitingGamePage - 1)),
                              ...visiblePages(current: recruitingGamePage, total: recruitingGameTotalPages).map((p) {
                                final isActive = p == recruitingGamePage;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: OutlinedButton(
                                    onPressed: isActive
                                      ? null
                                      : () => goToPage(p),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(40, 36),
                                      side: BorderSide(
                                        color: isActive
                                          ? Colors.black
                                          : Colors.grey
                                      ),
                                      backgroundColor: isActive
                                        ? const Color.fromARGB(50, 30, 77, 135)
                                        : null,
                                      foregroundColor: isActive
                                        ? Colors.white
                                        : Colors.black
                                    ),
                                    child: Text(
                                      "${p + 1}",
                                      style: TextStyle(
                                        fontWeight: isActive
                                          ? FontWeight.bold
                                          : FontWeight.normal
                                      ),
                                    )
                                  ),
                                );
                              }),
                              if (recruitingGamePage < recruitingGameTotalPages - 1)
                                navButton(">", onTap: () => goToPage(recruitingGamePage + 1)),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                )
              ],
            )
        )
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.tableBlue,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameRegistrationScreen(
                  tableTennisCourtId: widget.tableTennisCourtId,
                  tableTennisCourtName: widget.tableTennisCourtName,
                  onApplyComplete: () {
                    if (!mounted) return;
                    handleGetRecruitingGameList(widget.tableTennisCourtId, type, recruitingGamePage, recruitingGamePageSize);
                  }
                )
              )
            ).then((_) {
              if (!mounted) return;
              handleGetRecruitingGameList(widget.tableTennisCourtId, type, recruitingGamePage, recruitingGamePageSize);
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
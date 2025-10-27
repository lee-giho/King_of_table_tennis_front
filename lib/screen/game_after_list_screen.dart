import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/model/game_detail_info_by_user_dto.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/screen/table_tennis_game_info_detail_screen.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/widget/paginationBar.dart';
import 'package:king_of_table_tennis/widget/gameAfterInfoTile.dart';

class GameAfterListScreen extends StatefulWidget {
  const GameAfterListScreen({super.key});

  @override
  State<GameAfterListScreen> createState() => _GameAfterListScreenState();
}

class _GameAfterListScreenState extends State<GameAfterListScreen> {

  int gamePage = 0;
  int gamePageSize = 5;
  int gameTotalPages = 0;

  List<GameDetailInfoByUserDTO> gameDetailInfoByUserDTOs = [];

  @override
  void initState() {
    super.initState();

    handleGetGameDetailInfoByUser(gamePage, gamePageSize, "after");
  }

  void handleGetGameDetailInfoByUser(int page, int size, String type) async {
    final response = await apiRequest(() => getGameDetailInfoByUser(page, size, type), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pageResponse = PageResponse<GameDetailInfoByUserDTO>.fromJson(
        data,
        (json) => GameDetailInfoByUserDTO.fromJson(json)
      );

      if (pageResponse.content.isEmpty) {
        setState(() {
          gameDetailInfoByUserDTOs = [];
          gameTotalPages = pageResponse.totalPages;
        });

        return;
      }

      setState(() {
        gameDetailInfoByUserDTOs = pageResponse.content;
        gameTotalPages = pageResponse.totalPages;
      });

      print(data);
      print(gameDetailInfoByUserDTOs);
    } else {
      log("내 경기 정보 가져오기 실패 ${response.body}");
    }
  }

  void goToPage(int page) {
    if (page < 0 || page >= gameTotalPages) return;
    setState(() {
      gamePage = page;
    });
    handleGetGameDetailInfoByUser(page, gamePageSize, "before");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: gameDetailInfoByUserDTOs.isEmpty
          ? const Center(
              child: Text(
                "완료한 경기가 없습니다."
              ),
            )
          : CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = gameDetailInfoByUserDTOs[index];
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
                                  gameInfoId: game.gameInfo.id,
                                  isMine: game.isMine
                                )
                              )
                            );
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: GameAfterInfoTile(
                            gameDetailInfoByUserDTO: game,
                            refreshScreen:() => handleGetGameDetailInfoByUser(gamePage, gamePageSize, "after")
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: gameDetailInfoByUserDTOs.length
                )
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: PaginationBar(
                    currentPage: gamePage,
                    totalPages: gameTotalPages,
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
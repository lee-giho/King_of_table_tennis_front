import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/recruiting_game_dto.dart';
import 'package:king_of_table_tennis/screen/game_registration_screen.dart';
import 'package:king_of_table_tennis/screen/table_tennis_game_info_detail_screen.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/paginationBar.dart';
import 'package:king_of_table_tennis/widget/recruitingGameTile.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

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

  StompClient? stompClient;
  bool wsConnected = false;
  final Map<String, StompUnsubscribe> stateSubs = {};

  @override
  void initState() {
    super.initState();

    connectWs();
    handleGetRecruitingGameList(widget.tableTennisCourtId, type, recruitingGamePage, recruitingGamePageSize);
  }

  @override
  void dispose() {
    stateSubs.forEach((_, unsub) => unsub());
    stateSubs.clear();
    stompClient?.deactivate();
    super.dispose();
  }

  void connectWs() {
    final wsAddress = dotenv.get("WS_ADDRESS");

    stompClient = StompClient(
      config: StompConfig(
        url: "$wsAddress/ws",
        onConnect: (StompFrame frame) {
          debugPrint("Ws 연결 성공");
          wsConnected = true;
          resubscribeGameStates();
        },
        onStompError: (f) => debugPrint("STOMP error: ${f.body}"),
        onWebSocketError: (e) => debugPrint("WS error: $e")
      )
    );

    stompClient!.activate();
  }

  void resubscribeGameStates() {
    if (!wsConnected || stompClient == null) return;

    // 기존 구독 정리
    stateSubs.forEach((_, unsub) => unsub());
    stateSubs.clear();

    for (final game in recruitingGames) {
      final gameId = game.gameInfo.id;

      final unsub = stompClient!.subscribe(
        destination: "/topic/game/state/$gameId",
        callback: (frame) {
          final body = frame.body;
          if (body == null) return;

          final decoded = jsonDecode(body);
          print("게임 $gameId 상태 변경: $decoded");

          handleGetRecruitingGameList(
            widget.tableTennisCourtId,
            type,
            recruitingGamePage,
            recruitingGamePageSize
          );
        }
      );

      stateSubs[gameId] = unsub;
    }
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
          handleGetRecruitingGameList(tableTennisCourtId, type, lastPage, pageSize);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        recruitingGames = pageResponse.content;
        recruitingGameTotalPages = pageResponse.totalPages;
        recruitingGamePage = page;
      });

      // 리스트 바뀔 때마다 현재 페이지 게임들로 다시 웹소켓 구독
      resubscribeGameStates();
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
                          child: PaginationBar(
                            currentPage: recruitingGamePage,
                            totalPages: recruitingGameTotalPages,
                            window: 5,
                            onPageChanged: (p) => goToPage(p)
                          )
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
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/model/game_detail_info_by_page_dto.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/screen/search_table_tennis_court_screen.dart';
import 'package:king_of_table_tennis/screen/table_tennis_game_info_detail_screen.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/widget/gamePreviewTile.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  var searchKeywordController = TextEditingController();

  FocusNode searchKeywordFocus = FocusNode();

  int gamePage = 0;
  int gamePageSize = 1;
  int gameTotalPages = 0;

  GameDetailInfoByPageDTO? gameDetailInfoByPageDTO;

  StompClient? stompClient;
  String? subscribedGameId;

  @override
  void initState() {
    super.initState();

    handleGetGameDetailInfoByPage(gamePage, gamePageSize);
  }

  @override
  void dispose() {
    stompClient?.deactivate();

    super.dispose();
  }

  void handleGetGameDetailInfoByPage(int page, int size) async {
    final response = await apiRequest(() => getGameDetailInfoByPage(page, size), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pageResponse = PageResponse<GameDetailInfoByPageDTO>.fromJson(
        data,
        (json) => GameDetailInfoByPageDTO.fromJson(json)
      );

      if (pageResponse.content.isEmpty) {
        setState(() {
          gameDetailInfoByPageDTO = null;
          gameTotalPages = pageResponse.totalPages;
        });
        
        return;
      }

      setState(() {
        gameDetailInfoByPageDTO = pageResponse.content[0];
        gameTotalPages = pageResponse.totalPages;
      });

      print(gameTotalPages);

      wsConnect();
    } else {
      log("경기 정보 가져오기 실패");
    }
  }

  void wsConnect() {
    final currentId = gameDetailInfoByPageDTO?.gameInfo.id;
    if (gameDetailInfoByPageDTO == null) return;

    // 같은 게임이면 재구독 불필요
    if (subscribedGameId == currentId && stompClient?.connected == true) return;

    // 기존 연결 정리
    stompClient?.deactivate();

    final wsAddress = dotenv.get("WS_ADDRESS");

    stompClient = StompClient(
      config: StompConfig(
        url: "$wsAddress/ws",
        onConnect: (StompFrame frame) {
          print("연결 성공");
          stompClient!.subscribe(
            destination: "/topic/game/state/$currentId",
            callback: (frame) {
              final body = frame.body;
              if (body != null) {
                final decodedData = jsonDecode(body);
                print("응답 데이터: $decodedData");
                handleGetGameDetailInfoByPage(gamePage, gamePageSize);
              }
            }
          );
        },
        onStompError: (f) => debugPrint("STOMP error: ${f.body}"),
        onWebSocketError: (e) => debugPrint("WS error: $e")
      )
    );

    stompClient!.activate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Container( // 전체 화면
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Center(child: Text("홈 화면")),
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
                                  hintText: "체육관을 검색해보세요.",
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
                              ),
                            ),
                            if (searchKeywordController.text.isNotEmpty)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  searchKeywordController.clear();
                                  setState(() {});
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
                          print("keyword: ${searchKeywordController.text}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchTableTennisCourtScreen(
                                keyword: searchKeywordController.text
                              )
                            )
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
                SizedBox(height: 30),
                Row(
                  children: [
                    IconButton(
                      onPressed: gamePage == 0
                        ? null
                        : () {
                            handleGetGameDetailInfoByPage(--gamePage, gamePageSize);
                          },
                      icon: Icon(
                        Icons.arrow_back_ios
                      )
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TableTennisGameInfoDetailScreen(
                                gameInfoId: gameDetailInfoByPageDTO!.gameInfo.id,
                                isMine: gameDetailInfoByPageDTO!.isMine
                              )
                            )
                          );
                        },
                        child: GamePreviewTile(
                          gameDetailInfoByPageDTO: gameDetailInfoByPageDTO
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: gamePage+1 == gameTotalPages
                        ? null
                        : () {
                            handleGetGameDetailInfoByPage(++gamePage, gamePageSize);
                          },
                      icon: Icon(
                        Icons.arrow_forward_ios
                      )
                    )
                  ],
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}
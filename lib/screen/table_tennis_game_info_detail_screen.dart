import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/enum/game_state.dart';
import 'package:king_of_table_tennis/model/game_detail_info_dto.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/intl.dart';
import 'package:king_of_table_tennis/widget/gameInfoDetailUserTile.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class TableTennisGameInfoDetailScreen extends StatefulWidget {
  final String gameInfoId;
  const TableTennisGameInfoDetailScreen({
    super.key,
    required this.gameInfoId
  });

  @override
  State<TableTennisGameInfoDetailScreen> createState() => _TableTennisGameInfoDetailScreenState();
}

class _TableTennisGameInfoDetailScreenState extends State<TableTennisGameInfoDetailScreen> {

  GameDetailInfoDTO? gameDetailInfo;

  late StompClient stompClient;

  GameState gameState = GameState.RECRUITING;

  @override
  void initState() {
    super.initState();

    wsConnect();
    handleGetGameDetailInfo(widget.gameInfoId);
  }

  @override
  void dispose() {
    stompClient.deactivate();

    super.dispose();
  }

  void handleGetGameDetailInfo(String gameInfoId) async {
    final response = await apiRequest(() => getGameDetailInfo(gameInfoId), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        gameDetailInfo = GameDetailInfoDTO.fromJson(data);
        gameState = gameDetailInfo!.gameState.state;
      });
    } else {
      log("탁구장 경기 리스트 가져오기 실패");
    }
  }

  void wsConnect() {
    final wsAddress = dotenv.get("WS_ADDRESS");

    stompClient = StompClient(
      config: StompConfig(
        url: "$wsAddress/ws",
        onConnect: (StompFrame frame) {
          print("연결 성공");
          stompClient.subscribe(
            destination: "/topic/game/state/${widget.gameInfoId}",
            callback: (frame) {
              final body = frame.body;
              if (body != null) {
                final decodedData = jsonDecode(body);
                print("응답 데이터: $decodedData");
              }
            }
          );
        }
      )
    );

    stompClient.activate();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "경기 정보"
          ),
        ),
      ),
      body: SafeArea(
        child: Container( // 전체화면
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: gameDetailInfo == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GameInfoDetailUserTile(
                          userInfo: gameDetailInfo!.defenderInfo
                        ),
                        Text(
                          "VS",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        GameInfoDetailUserTile(
                          userInfo: gameDetailInfo!.challengerInfo
                        )
                      ],
                    ),
                  ),
                  Column( // 경기 정보 부분
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "상세 정보",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1
                          ),
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "경기 날짜",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                Text(
                                  formatDateTime(gameDetailInfo!.gameInfo.gameDate),
                                  style: TextStyle(
                                    fontSize: 16
                                  )
                                )
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "점수",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                Row(
                                  children: [
                                    Text(
                                      gameDetailInfo!.gameInfo.gameScore.toString(),
                                      style: TextStyle(
                                        fontSize: 16
                                      )
                                    ),
                                    Text(
                                      "점 ",
                                      style: TextStyle(
                                        fontSize: 16
                                      )
                                    ),
                                    Text(
                                      gameDetailInfo!.gameInfo.gameSet.toString(),
                                      style: TextStyle(
                                        fontSize: 16
                                      )
                                    ),
                                    Text(
                                      "세트",
                                      style: TextStyle(
                                        fontSize: 16
                                      )
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "수락 타입",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                Text(
                                  gameDetailInfo!.gameInfo.acceptanceType == "FCFS"
                                  ? "선착순"
                                  : "선택",
                                  style: TextStyle(
                                    fontSize: 16
                                  )
                                )
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "경기 상태",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                Text(
                                  gameDetailInfo!.gameState.state.toKorean,
                                  style: TextStyle(
                                    fontSize: 16
                                  )
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  if (gameState == GameState.RECRUITING)
                    Text(
                      gameState.toKorean
                    )
                ],
              )
        )
      ),
    );
  }
}
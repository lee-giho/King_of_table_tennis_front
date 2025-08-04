import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/enum/game_state.dart';
import 'package:king_of_table_tennis/model/game_detail_info_dto.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/intl.dart';

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

  @override
  void initState() {
    super.initState();

    handleGetGameDetailInfo(widget.gameInfoId);
  }

  void handleGetGameDetailInfo(String gameInfoId) async {
    final response = await apiRequest(() => getGameDetailInfo(gameInfoId), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        gameDetailInfo = GameDetailInfoDTO.fromJson(data);
      });
    } else {
      log("탁구장 경기 리스트 가져오기 실패");
    }
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
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                height: 1,
                                width: double.infinity,
                                color: Colors.black,
                              ),
                            ),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                height: 1,
                                width: double.infinity,
                                color: Colors.black,
                              ),
                            ),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                height: 1,
                                width: double.infinity,
                                color: Colors.black,
                              ),
                            ),
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
                  )
                ],
              )
        )
      ),
    );
  }
}
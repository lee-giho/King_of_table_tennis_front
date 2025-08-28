import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/enum/game_state.dart';
import 'package:king_of_table_tennis/model/game_detail_info_dto.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/intl.dart';

class GamePreviewTile extends StatefulWidget {
  final GameDetailInfoDTO? gameDetailInfoDTO;
  const GamePreviewTile({
    super.key,
    this.gameDetailInfoDTO
  });

  @override
  State<GamePreviewTile> createState() => _GamePreviewTileState();
}

class _GamePreviewTileState extends State<GamePreviewTile> {

  GameDetailInfoDTO? gameDetailInfo;
  
  void handleGetGameDetailInfo(String gameInfoId) async {
    final response = await apiRequest(() => getGameDetailInfo(gameInfoId), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        gameDetailInfo = GameDetailInfoDTO.fromJson(data);
      });
      print(gameDetailInfo!.gameState.state.toKorean);
    } else {
      log("경기 정보 가져오기 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.gameDetailInfoDTO != null
      ? Expanded(
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    widget.gameDetailInfoDTO!.gameState.state == GameState.DOING
                      ? Icons.cell_tower
                      : null,                      
                    color: Colors.red,
                  ),
                  SizedBox(width: 5),
                  Text(
                    widget.gameDetailInfoDTO!.gameState.state == GameState.DOING
                      ? "LIVE"
                      : "",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.gameDetailInfoDTO!.defenderInfo.nickName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "VS",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.gameDetailInfoDTO!.challengerInfo.nickName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.date_range
                      ),
                      Text(
                        formatDateTime(widget.gameDetailInfoDTO!.gameInfo.gameDate)
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on
                      ),
                      Text(
                        widget.gameDetailInfoDTO!.gameInfo.place
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      )
    : Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(15)
        ),
        height: 150,
        child: Center(
          child: Text(
            "게임 준비중",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}
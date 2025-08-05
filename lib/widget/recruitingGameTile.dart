import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/model/game_info_dto.dart';
import 'package:king_of_table_tennis/model/recruiting_game_dto.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/intl.dart';

class RecruitingGameTile extends StatefulWidget {
  final RecruitingGameDTO recruitingGameDTO;
  final VoidCallback onApplyComplete;
  const RecruitingGameTile({
    super.key,
    required this.recruitingGameDTO,
    required this.onApplyComplete
  });

  @override
  State<RecruitingGameTile> createState() => _RecruitingGameTileState();
}

class _RecruitingGameTileState extends State<RecruitingGameTile> {

  void handleGameParticipation(String gameInfoId) async {
    final response = await apiRequest(() => gameParticipation(gameInfoId), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      bool success = data["success"];

      if (success) {
        log("탁구 경기 신청 성공");
        ScaffoldMessenger.of(context) .showSnackBar(
          SnackBar(content: Text("탁구 경기 신청 성공"))
        );
        widget.onApplyComplete.call();
      } else {
        log("탁구 경기 신청 실패");  
      }
    } else {
      log("탁구 경기 신청 실패: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {

    final GameInfoDTO gameInfo = widget.recruitingGameDTO.gameInfo;
    final String creatorId = widget.recruitingGameDTO.creatorId;
    final String gameState = widget.recruitingGameDTO.gameState;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.black
        ),
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creatorId,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month
                    ),
                    Text(
                      formatDateTime(gameInfo.gameDate),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    if(gameState == "RECRUITING")
                      Icon(
                        Icons.info
                      ),
                    Text(
                      gameState == "RECRUITING"
                        ? "모집중"
                        : "",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (gameState == "RECRUITING" && !widget.recruitingGameDTO.isMine)
            Container(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  handleGameParticipation(gameInfo.id);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  side: BorderSide(
                    width: 0.2,
                    color: Colors.black
                  ),
                  foregroundColor: AppColors.tableBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                  )
                ),
                child: Text(
                  gameInfo.acceptanceType == "FCFS"
                    ? "참가"
                    : "신청",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black
                  ),
                )
              ),
            )
        ],
      ),
    );
  }
}
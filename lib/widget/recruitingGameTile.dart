import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/model/game_info.dart';
import 'package:king_of_table_tennis/model/recruiting_game_dto.dart';
import 'package:king_of_table_tennis/util/intl.dart';

class RecruitingGameTile extends StatefulWidget {
  final RecruitingGameDTO recruitingGameDTO;
  const RecruitingGameTile({
    super.key,
    required this.recruitingGameDTO
  });

  @override
  State<RecruitingGameTile> createState() => _RecruitingGameTileState();
}

class _RecruitingGameTileState extends State<RecruitingGameTile> {

  @override
  Widget build(BuildContext context) {

    final GameInfo gameInfo = widget.recruitingGameDTO.gameInfo;
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
    );
  }
}
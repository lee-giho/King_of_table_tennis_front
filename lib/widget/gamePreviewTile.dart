import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/enum/game_state.dart';
import 'package:king_of_table_tennis/model/game_detail_info_by_page_dto.dart';
import 'package:king_of_table_tennis/util/intl.dart';

class GamePreviewTile extends StatefulWidget {
  final GameDetailInfoByPageDTO? gameDetailInfoByPageDTO;
  const GamePreviewTile({
    super.key,
    this.gameDetailInfoByPageDTO
  });

  @override
  State<GamePreviewTile> createState() => _GamePreviewTileState();
}

class _GamePreviewTileState extends State<GamePreviewTile> {

  GameDetailInfoByPageDTO? gameDetailInfoByPageDTO;

  @override
  Widget build(BuildContext context) {
    return widget.gameDetailInfoByPageDTO != null
      ? Container(
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
                  widget.gameDetailInfoByPageDTO!.gameState.state == GameState.DOING
                    ? Icons.cell_tower
                    : null,                      
                  color: Colors.red,
                ),
                SizedBox(width: 5),
                Text(
                  widget.gameDetailInfoByPageDTO!.gameState.state == GameState.DOING
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
                        widget.gameDetailInfoByPageDTO!.defenderInfo.nickName,
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
                        widget.gameDetailInfoByPageDTO!.challengerInfo.nickName,
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
                      formatDateTime(widget.gameDetailInfoByPageDTO!.gameInfo.gameDate)
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on
                    ),
                    Text(
                      widget.gameDetailInfoByPageDTO!.gameInfo.place
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      )
    : Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(15)
      ),
      height: 150,
      child: Center(
        child: Text(
          "경기 준비중",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}
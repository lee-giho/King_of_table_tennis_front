import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/model/game_record_info.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/intl.dart';
import 'package:king_of_table_tennis/widget/expandableWidget.dart';
import 'package:king_of_table_tennis/widget/profileImageCircle.dart';

class GameRecordTile extends StatelessWidget {
  final GameRecordInfo gameRecordInfo;
  const GameRecordTile({
    super.key,
    required this.gameRecordInfo
  });

  @override
  Widget build(BuildContext context) {
    print(gameRecordInfo.isWin);
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.black
        ),
        color: gameRecordInfo.isWin
          ? AppColors.tableBlue.withAlpha(600)
          : AppColors.racketRed.withAlpha(600),
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        children: [
          Row( // 사용자 두명
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column( // 내 프로필
                  children: [
                    ProfileImageCircle(
                      profileImage: gameRecordInfo.myInfo.profileImage,
                      profileImageSize: 60,
                    ),
                    Text(
                      gameRecordInfo.myInfo.nickName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                      overflow: TextOverflow.ellipsis
                    ),
                    Text(
                      gameRecordInfo.myInfo.racketType
                    )
                  ],
                ),
              ),
              Text(
                "${gameRecordInfo.myInfo.setScore}  :  ${gameRecordInfo.opponentInfo.setScore}",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),
              Expanded(
                child: Column( // 상대 프로필
                  children: [
                    ProfileImageCircle(
                      profileImage: gameRecordInfo.opponentInfo.profileImage,
                      profileImageSize: 60,
                    ),
                    Text(
                      gameRecordInfo.opponentInfo.nickName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                      overflow: TextOverflow.ellipsis
                    ),
                    Text(
                      gameRecordInfo.opponentInfo.racketType
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          ExpandableWidget(
            widget: Column(
              children: [
                Row(
                  children: [
                    Icon(
                        Icons.date_range
                      ),
                      Text(
                        formatDateTime(gameRecordInfo.gameDate)
                      )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on
                    ),
                    Text(
                      gameRecordInfo.place
                    )
                  ],
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}
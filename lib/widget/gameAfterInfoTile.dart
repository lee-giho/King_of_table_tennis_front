import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/model/game_detail_info_by_user_dto.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';
import 'package:king_of_table_tennis/screen/game_review_registration_screen.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/intl.dart';
import 'package:king_of_table_tennis/widget/expandableTitle.dart';

class GameAfterInfoTile extends StatefulWidget {
  final GameDetailInfoByUserDTO gameDetailInfoByUserDTO;
  final VoidCallback refreshScreen;
  const GameAfterInfoTile({
    super.key,
    required this.gameDetailInfoByUserDTO,
    required this.refreshScreen
  });

  @override
  State<GameAfterInfoTile> createState() => _GameAfterInfoTileState();
}

class _GameAfterInfoTileState extends State<GameAfterInfoTile> {

  @override
  Widget build(BuildContext context) {

    UserInfoDTO otherPerson = widget.gameDetailInfoByUserDTO.isMine
      ? widget.gameDetailInfoByUserDTO.challengerInfo
      : widget.gameDetailInfoByUserDTO.defenderInfo;

    String mySide = widget.gameDetailInfoByUserDTO.isMine
      ? "defender"
      : "challenger";

    bool isWin = widget.gameDetailInfoByUserDTO.gameState.defenderScore > widget.gameDetailInfoByUserDTO.gameState.challengerScore
      ? mySide == "defender"
          ? true
          : false
      : mySide == "challenger"
          ? true
          : false;

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ExpandableTitle(
                  text: widget.gameDetailInfoByUserDTO.gameInfo.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.racketRed.withAlpha(200),
                  disabledBackgroundColor: AppColors.tableBlue.withAlpha(200),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: Colors.black,
                      width: 0.4
                    )
                  )
                  
                ),
                onPressed: widget.gameDetailInfoByUserDTO.hasReviewed
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameReviewRegistrationScreen(
                            gameInfoId: widget.gameDetailInfoByUserDTO.gameInfo.id,
                            revieweeId: otherPerson.id
                          )
                        )
                      ).then((_) {
                        widget.refreshScreen();
                      });
                    },
                child: Text(
                  widget.gameDetailInfoByUserDTO.hasReviewed
                    ? "리뷰 작성 완료"
                    : "리뷰 작성하기",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                )
              )
            ]
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black
                  ),
                  borderRadius: BorderRadius.circular(15),
                  color: isWin
                    ? const Color.fromARGB(50, 30, 77, 135)
                    : const Color.fromARGB(50, 186, 63, 65)
                ),
                child: Text(
                  isWin
                    ? "승리"
                    : "패배",
                  style: TextStyle(
                    fontSize: 12
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.scoreboard
                              ),
                              SizedBox(width: 5),
                              Text(
                                "${widget.gameDetailInfoByUserDTO.gameInfo.gameScore}점 ${widget.gameDetailInfoByUserDTO.gameInfo.gameSet}세트",
                                style: TextStyle(
                                  fontSize: 12
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.date_range
                              ),
                              SizedBox(width: 5),
                              Text(
                                formatDateTime(widget.gameDetailInfoByUserDTO.gameInfo.gameDate),
                                style: TextStyle(
                                  fontSize: 12
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on
                              ),
                              SizedBox(width: 5),
                              Text(
                                widget.gameDetailInfoByUserDTO.gameInfo.place,
                                style: TextStyle(
                                  fontSize: 12
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              ClipOval( // 프로필 사진
                child: otherPerson.id == ""
                  ? Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1
                        ),
                        shape: BoxShape.circle
                      ),
                      child: const Icon(
                        Icons.question_mark,
                        size: 50
                      )
                  )
                : otherPerson.profileImage == "default"
                    ? Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1
                          ),
                          shape: BoxShape.circle
                        ),
                        child: const Icon(
                            Icons.person,
                            size: 50
                          ),
                    )
                    : Image(
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          "${dotenv.env["API_ADDRESS"]}/image/profile/${otherPerson.profileImage}"
                        )
                      )
              ),
            ],
          ),
        ],
      ),
    );
  }
}
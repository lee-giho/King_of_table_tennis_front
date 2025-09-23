import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/enum/game_state.dart';
import 'package:king_of_table_tennis/model/game_detail_info_by_user_dto.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';
import 'package:king_of_table_tennis/util/intl.dart';

class GameBeforeInfoTile extends StatefulWidget {
  final GameDetailInfoByUserDTO gameDetailInfoByUserDTO;
  const GameBeforeInfoTile({
    super.key,
    required this.gameDetailInfoByUserDTO
  });

  @override
  State<GameBeforeInfoTile> createState() => _GameBeforeInfoTileState();
}

class _GameBeforeInfoTileState extends State<GameBeforeInfoTile> {

  @override
  Widget build(BuildContext context) {

    UserInfoDTO otherPerson = widget.gameDetailInfoByUserDTO.isMine
      ? widget.gameDetailInfoByUserDTO.challengerInfo
      : widget.gameDetailInfoByUserDTO.defenderInfo;

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
                      color: widget.gameDetailInfoByUserDTO.gameState.state == GameState.RECRUITING
                        ? const Color.fromARGB(50, 186, 63, 65)
                        : const Color.fromARGB(50, 30, 77, 135)
                    ),
                    child: Text(
                      widget.gameDetailInfoByUserDTO.gameState.state == GameState.RECRUITING
                        ? "상대 모집 중"
                        : "경기 대기 중",
                      style: TextStyle(
                        fontSize: 12
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  if (widget.gameDetailInfoByUserDTO.gameState.state == GameState.RECRUITING)
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.black
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "신청자: ${widget.gameDetailInfoByUserDTO.applicationCount}명",
                        style: TextStyle(
                          fontSize: 12
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: () {

                },
                icon: Icon(
                  Icons.more_horiz
                )
              ),
            ],
          ),
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
                                Icons.check
                              ),
                              SizedBox(width: 5),
                              Text(
                                widget.gameDetailInfoByUserDTO.gameInfo.acceptanceType == "FCFS"
                                  ? "선착순"
                                  : "선택",
                                style: TextStyle(
                                  fontSize: 12
                                ),
                              ),
                            ],
                          ),
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
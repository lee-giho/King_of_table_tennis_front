import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/model/gameUserInfo.dart';

class ScoreBoard extends StatefulWidget {
  final GameUserInfo defender;
  final GameUserInfo challenger;
  final bool leftIsDefender;
  final VoidCallback onChangeSeats;
  const ScoreBoard({
    super.key,
    required this.defender,
    required this.challenger,
    required this.leftIsDefender,
    required this.onChangeSeats
  });

  @override
  State<ScoreBoard> createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {
  @override
  Widget build(BuildContext context) {

    GameUserInfo leftUser = widget.leftIsDefender
      ? widget.defender
      : widget.challenger;
    GameUserInfo rightUser = widget.leftIsDefender
      ? widget.challenger
      : widget.defender;

    return Container(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row( // 왼쪽 사용자
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: leftUser.profileImage == "default"
                        ? Container(   
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1
                              ),
                              borderRadius: BorderRadius.circular(100)
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 60
                            ),
                          )
                        : Image(
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              "${dotenv.env["API_ADDRESS"]}/image/profile/${leftUser.profileImage}"
                            )
                          )
                    ),
                  ),
                  Text(
                    "가나다",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
              Row( // 점수판
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row( // 왼쪽 사용자 점수판
                  crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container( // 왼쪽 사용자 점수
                        decoration: BoxDecoration(
                          color: Colors.black
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Center(
                            child: Text(
                              leftUser.score.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 60
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding( // 왼쪽 사용자 세트 점수
                        padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Center(
                              child: Text(
                                leftUser.setScore.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      widget.onChangeSeats.call();
                    },
                    icon: Icon(
                      Icons.autorenew,
                      size: 40,
                    )
                  ),
                  Row( // 오른쪽 사용자 점수판
                  crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding( // 오른쪽 사용자 세트 점수
                        padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Center(
                              child: Text(
                                rightUser.setScore.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container( // 오른쪽 사용자 점수
                        decoration: BoxDecoration(
                          color: Colors.black
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Center(
                            child: Text(
                              rightUser.score.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 60
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              Row( // 오른쪽 사용자
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: rightUser.profileImage == "default"
                        ? Container(   
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1
                              ),
                              borderRadius: BorderRadius.circular(100)
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 60
                            ),
                          )
                        : Image(
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              "${dotenv.env["API_ADDRESS"]}/image/profile/${rightUser.profileImage}"
                            )
                          )
                    ),
                  ),
                  Text(
                    "가나다",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}
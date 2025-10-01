import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/review_api.dart';
import 'package:king_of_table_tennis/model/RegisterReviewRequest.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/scoreSlider.dart';

class GameReviewRegistrationScreen extends StatefulWidget {
  final String gameInfoId;
  final String revieweeId;
  const GameReviewRegistrationScreen({
    super.key,
    required this.gameInfoId,
    required this.revieweeId
  });

  @override
  State<GameReviewRegistrationScreen> createState() => _GameReviewRegistrationScreenState();
}

class _GameReviewRegistrationScreenState extends State<GameReviewRegistrationScreen> {

  int score_serve = 3;
  int score_receive = 3;
  int score_rally = 3;
  int score_strokes = 3;
  int score_strategy = 3;

  int score_manner = 3;
  int score_punctuality = 3;
  int score_community = 3;
  int score_politeness = 3;
  int score_rematch = 3;

  String comment = "";

  void handleRegisterReview(String gameInfoId, RegisterReviewRequest registerReviewRequest) async {
    final response = await apiRequest(() => registerReview(gameInfoId, registerReviewRequest), context);

    if (response.statusCode == 201) {
      ToastMessage.show("리뷰가 등록되었습니다.");
      Navigator.pop(context);
    } else {
      ToastMessage.show("리뷰가 등록되지 않았습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "탁구 경기 리뷰 작성",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "경기 리뷰",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Container( // 경기에 대해
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1
                                ),
                                borderRadius: BorderRadius.circular(15)
                              ),
                              child: Column(
                                children: [
                                  ScoreSlider(
                                    label: "서브 정확도",
                                    onChanged: (value) {
                                      score_serve = value;
                                      print(score_serve);
                                    }
                                  ),
                                  ScoreSlider(
                                    label: "리시브 안정성",
                                    onChanged: (value) {
                                      score_receive = value;
                                      print(score_receive);
                                    }
                                  ),
                                  ScoreSlider(
                                    label: "랠리 능력",
                                    onChanged: (value) {
                                      score_rally = value;
                                      print(score_rally);
                                    }
                                  ),
                                  ScoreSlider(
                                    label: "포/백핸드 구사력",
                                    onChanged: (value) {
                                      score_strokes = value;
                                      print(score_strokes);
                                    }
                                  ),
                                  ScoreSlider(
                                    label: "전술 활용 능력",
                                    onChanged: (value) {
                                      score_strategy = value;
                                      print(score_strategy);
                                    }
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "상대방 리뷰",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Container( // 경기에 대해
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1
                                ),
                                borderRadius: BorderRadius.circular(15)
                              ),
                              child: Column(
                                children: [
                                  ScoreSlider(
                                    label: "경기 매너",
                                    onChanged: (value) {
                                      score_manner = value;
                                      print(score_manner);
                                    }
                                  ),
                                  ScoreSlider(
                                    label: "시간 약속 및 준비성",
                                    onChanged: (value) {
                                      score_punctuality = value;
                                      print(score_punctuality);
                                    }
                                  ),
                                  ScoreSlider(
                                    label: "협동 및 소통",
                                    onChanged: (value) {
                                      score_community = value;
                                      print(score_community);
                                    }
                                  ),
                                  ScoreSlider(
                                    label: "친절함/예의",
                                    onChanged: (value) {
                                      score_politeness = value;
                                      print(score_politeness);
                                    }
                                  ),
                                  ScoreSlider(
                                    label: "재경기 의향",
                                    onChanged: (value) {
                                      score_rematch = value;
                                      print(score_rematch);
                                    }
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "추가 코멘트",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1
                                ),
                                borderRadius: BorderRadius.circular(15)
                              ),
                              child: TextField(
                                maxLength: 250,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  hintText: "자유롭게 리뷰를 작성해주세요.",
                                  border: InputBorder.none
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    comment = val;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20)
                      ],
                    ),
                  )
                ),
                ElevatedButton(
                  onPressed: () {
                    handleRegisterReview(
                      widget.gameInfoId,
                      RegisterReviewRequest(
                        revieweeId: widget.revieweeId,
                        scoreServe: score_serve,
                        scoreReceive: score_receive,
                        scoreRally: score_rally,
                        scoreStrokes: score_strokes,
                        scoreStrategy: score_strategy,
                        scoreManner: score_manner,
                        scorePunctuality: score_punctuality,
                        scoreCommunity: score_community,
                        scorePoliteness: score_politeness,
                        scoreRematch: score_rematch,
                        comment: comment
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: BorderSide(
                      width: 0.2,
                      color: Colors.black
                    ),
                    backgroundColor: AppColors.racketRed,
                    foregroundColor: AppColors.tableBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                    )
                  ),
                  child: const Text(
                    "등록하기",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  )
                )
              ],
            ),
          )
        ),
      )
    );
  }
}
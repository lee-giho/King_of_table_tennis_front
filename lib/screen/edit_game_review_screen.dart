import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/review_api.dart';
import 'package:king_of_table_tennis/model/RegisterReviewRequest.dart';
import 'package:king_of_table_tennis/model/game_review.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/scoreSlider.dart';

class EditGameReviewScreen extends StatefulWidget {
  final GameReview gameReview;
  const EditGameReviewScreen({
    super.key,
    required this.gameReview
  });

  @override
  State<EditGameReviewScreen> createState() => _EditGameReviewScreenState();
}

class _EditGameReviewScreenState extends State<EditGameReviewScreen> {

  late int score_serve;
  late int score_receive;
  late int score_rally;
  late int score_strokes;
  late int score_strategy;

  late int score_manner;
  late int score_punctuality;
  late int score_community;
  late int score_politeness;
  late int score_rematch;

  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();

    score_serve = widget.gameReview.scoreServe;
    score_receive = widget.gameReview.scoreReceive;
    score_rally = widget.gameReview.scoreRally;
    score_strokes = widget.gameReview.scoreStrokes;
    score_strategy = widget.gameReview.scoreStrategy;
    score_manner = widget.gameReview.scoreManner;
    score_punctuality = widget.gameReview.scorePunctuality;
    score_community = widget.gameReview.scoreCommunity;
    score_politeness = widget.gameReview.scorePoliteness;
    score_rematch = widget.gameReview.scoreRematch;
    commentController = TextEditingController(
      text: widget.gameReview.comment
    );
  }

  void handlePatchGameReview(String gameReviewId, RegisterReviewRequest registerReviewRequest) async {
    final response = await apiRequest(() => patchGameReview(gameReviewId, registerReviewRequest), context);

    if (response.statusCode == 204) {
      ToastMessage.show("리뷰가 수정되었습니다.");
      Navigator.pop(context);
    } else {
      ToastMessage.show("리뷰가 수정되지 않았습니다.");
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
                                    },
                                    initialValue: score_serve
                                  ),
                                  ScoreSlider(
                                    label: "리시브 안정성",
                                    onChanged: (value) {
                                      score_receive = value;
                                      print(score_receive);
                                    },
                                    initialValue: score_receive
                                  ),
                                  ScoreSlider(
                                    label: "랠리 능력",
                                    onChanged: (value) {
                                      score_rally = value;
                                      print(score_rally);
                                    },
                                    initialValue: score_rally
                                  ),
                                  ScoreSlider(
                                    label: "포/백핸드 구사력",
                                    onChanged: (value) {
                                      score_strokes = value;
                                      print(score_strokes);
                                    },
                                    initialValue: score_strokes
                                  ),
                                  ScoreSlider(
                                    label: "전술 활용 능력",
                                    onChanged: (value) {
                                      score_strategy = value;
                                      print(score_strategy);
                                    },
                                    initialValue: score_strategy
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
                                    },
                                    initialValue: score_manner
                                  ),
                                  ScoreSlider(
                                    label: "시간 약속 및 준비성",
                                    onChanged: (value) {
                                      score_punctuality = value;
                                      print(score_punctuality);
                                    },
                                    initialValue: score_punctuality
                                  ),
                                  ScoreSlider(
                                    label: "협동 및 소통",
                                    onChanged: (value) {
                                      score_community = value;
                                      print(score_community);
                                    },
                                    initialValue: score_community
                                  ),
                                  ScoreSlider(
                                    label: "친절함/예의",
                                    onChanged: (value) {
                                      score_politeness = value;
                                      print(score_politeness);
                                    },
                                    initialValue: score_politeness
                                  ),
                                  ScoreSlider(
                                    label: "재경기 의향",
                                    onChanged: (value) {
                                      score_rematch = value;
                                      print(score_rematch);
                                    },
                                    initialValue: score_rematch
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
                                controller: commentController,
                                maxLength: 250,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  hintText: "자유롭게 리뷰를 작성해주세요.",
                                  border: InputBorder.none
                                )
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
                    handlePatchGameReview(
                      widget.gameReview.id,
                      RegisterReviewRequest(
                        revieweeId: widget.gameReview.reviewee.id,
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
                        comment: commentController.text
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
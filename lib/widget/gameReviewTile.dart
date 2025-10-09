import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/model/game_review.dart';
import 'package:king_of_table_tennis/screen/edit_game_review_screen.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/intl.dart';
import 'package:king_of_table_tennis/widget/expandableText.dart';

class GameReviewTile extends StatefulWidget {
  final GameReview gameReview;
  final bool isWritten;
  final VoidCallback onUpdateReview;
  const GameReviewTile({
    super.key,
    required this.gameReview,
    required this.isWritten,
    required this.onUpdateReview
  });

  @override
  State<GameReviewTile> createState() => _GameReviewTileState();
}

class _GameReviewTileState extends State<GameReviewTile> {

  String getScoreAvg(GameReview gameReview) {
    return ((gameReview.scoreServe + gameReview.scoreReceive + gameReview.scoreRally + gameReview.scoreStrokes + gameReview.scoreStrategy + gameReview.scoreManner + gameReview.scorePunctuality + gameReview.scoreCommunity + gameReview.scorePoliteness + gameReview.scoreRematch).toDouble() / 10).toStringAsFixed(1);
  }

  Widget buildReviewMoreMenu({
    required BuildContext context,
    required VoidCallback onEdit,
    required VoidCallback onDelete
  }) {
    return PopupMenuButton<String> (
      icon: const Icon(
        Icons.more_horiz
      ),
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: "edit",
          height: 40,
          child: Row (
            children: [
              Icon(
                Icons.edit,
                size: 18
              ),
              SizedBox(width: 8),
              Text(
                "리뷰 수정하기"
              )
            ],
          )
        ),
        const PopupMenuItem(
          value: "delete",
          height: 40,
          child: Row (
            children: [
              Icon(
                Icons.delete_outline,
                size: 18
              ),
              SizedBox(
                width: 8
              ),
              Text(
                "리뷰 삭제하기"
              )
            ]
          )
        )
      ],
      onSelected: (value) async {
        if (value == "edit") {
          onEdit();
        } else if (value == "delete") {
          final confirm = await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text(
                "리뷰 삭제"
              ),
              content: const Text(
                "정말로 이 리뷰를 삭제하시겠습니까?"
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx, false);
                  },
                  child: const Text(
                    "취소"
                  )
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx, true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.racketRed
                  ),
                  child: const Text(
                    "삭제"
                  )
                )
              ],
            )
          );
          if (confirm == true) {
            onDelete();
          };
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
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
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black
                  ),
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(50, 186, 63, 65)
                ),
                child: Text(
                  "승리",
                  style: TextStyle(
                    fontSize: 12
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    formatDateTime(widget.gameReview.writeDate),
                    style: TextStyle(
                      color: Colors.grey[800]
                    ),
                  ),
                  if (widget.isWritten)
                    buildReviewMoreMenu(
                      context: context,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditGameReviewScreen(
                              gameReview: widget.gameReview
                            )
                          )
                        ).then((_) {
                          widget.onUpdateReview.call();
                        });
                      },
                      onDelete: () async {

                      }
                    )
                ]
              )
            ]
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star
                        ),
                        Text(
                          getScoreAvg(widget.gameReview)
                        )
                      ]
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.date_range
                        ),
                        SizedBox(width: 5),
                        Text(
                          formatDateTime(widget.gameReview.gameInfo.gameDate),
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
                          widget.gameReview.gameInfo.place,
                          style: TextStyle(
                            fontSize: 12
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ExpandableText(
                      text: widget.gameReview.comment,
                      trimLines: 2,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              ),
              ClipOval( // 프로필 사진
                child: widget.gameReview.reviewee.profileImage == "default"
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
                          "${dotenv.env["API_ADDRESS"]}/image/profile/${widget.gameReview.reviewee.profileImage}"
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
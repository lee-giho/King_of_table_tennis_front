import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/model/user_ranking_info_dto.dart';
import 'package:king_of_table_tennis/widget/profileImageCircle.dart';

class RankingTile extends StatelessWidget {
  final UserRankingInfoDto userRankingInfo;

  const RankingTile({
    super.key,
    required this.userRankingInfo
  });

  Color getBackgroundColorByRank(int rank) {
    if (rank == 1) {
      return const Color.fromARGB(255, 233, 216, 140);
    } else if (rank == 2) {
      return const Color.fromARGB(255, 199, 201, 207);
    } else if (rank == 3) {
      return const Color.fromARGB(255, 189, 166, 138);
    } else {
      return Colors.transparent;
    }
  }

  Widget buildCrownIcon(int rank) {
    if (rank < 4) {
      return Icon(
        Icons.workspace_premium,
        size: 30,
        color: getBackgroundColorByRank(rank),
      );
    } else {
      return Text(
        "$rank위",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = getBackgroundColorByRank(userRankingInfo.ranking);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          width: 6,
          color: rankColor
        ),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: [
          // 순위 및 메달
          SizedBox(
            width: 40,
            child: Center(
              child: buildCrownIcon(userRankingInfo.ranking),
            )
          ),
          const SizedBox(width: 8),

          // 프로필 사진
          ProfileImageCircle(
            profileImage: userRankingInfo.profileImage,
            profileImageSize: 40,
          ),

          SizedBox(width: 10),

          // 닉네임 및 전적
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userRankingInfo.nickName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                  overflow: TextOverflow.ellipsis
                ),
                const SizedBox(height: 2),
                Text(
                  "${userRankingInfo.winCount}승 ${userRankingInfo.defeatCount}패",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700]
                  )
                )
              ]
            )
          ),

          // 승률 뱃지
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "${(userRankingInfo.winRate * 100).round()}%",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12
              )
            )
          )
        ]
      )
    );
  }
}
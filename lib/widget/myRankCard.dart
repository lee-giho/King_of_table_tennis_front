import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/model/user_ranking_info_dto.dart';
import 'package:king_of_table_tennis/widget/profileImageCircle.dart';

class MyRankCard extends StatelessWidget {
  final UserRankingInfoDto myRankingInfo;
  final int totalUsers;

  const MyRankCard({
    super.key,
    required this.myRankingInfo,
    required this.totalUsers
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black,
            offset: Offset(0, 2)
          )
        ]
      ),
      child: Row(
        children: [
          ProfileImageCircle(
            profileImage: myRankingInfo.profileImage,
            profileImageSize: 50,
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "내 랭킹: ${myRankingInfo.ranking}위 / $totalUsers명",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "전적: ${myRankingInfo.winCount}승 ${myRankingInfo.defeatCount}패 (승률 ${(myRankingInfo.winRate * 100).round()}%)",
                style: const TextStyle(
                  fontSize: 14
                ),
              )
            ]
          ),
        ],
      )
    );
  }
}
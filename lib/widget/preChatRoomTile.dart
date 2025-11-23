import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/model/pre_chat_room.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/intl.dart';
import 'package:king_of_table_tennis/widget/profileImageCircle.dart';

class PreChatRoomTile extends StatelessWidget {
  final PreChatRoom preChatRoom;
  final double profileImageSize;
  final double fontSize;

  const PreChatRoomTile({
    super.key,
    required this.preChatRoom,
    this.profileImageSize = 40,
    this.fontSize = 16
  });

  String formatChatListTime(DateTime dt) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dt.year, dt.month, dt.day);

    final difference = today.difference(targetDate).inDays;

    if (difference == 0) {
      return formatSimpleDateTime(dt);
    } else if (difference == 1) {
      return "어제";
    } else {
      final year = dt.year;
      final month = dt.month.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');

      if (year == now.year) {
        return "$month월 $day일";
      } else {
        return "$year. $month. $day.";
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final UserInfoDTO friend = preChatRoom.friend;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          ProfileImageCircle(
            profileImage: friend.profileImage,
            profileImageSize: profileImageSize,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        friend.nickName,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (preChatRoom.lastSentAt != null)
                      Text(
                        formatChatListTime(preChatRoom.lastSentAt!),
                        style: TextStyle(
                          fontSize: 11
                        ),
                      )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        preChatRoom.lastMessage ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (preChatRoom.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.racketRed,
                          borderRadius: BorderRadius.circular(99)
                        ),
                        child: Text(
                          preChatRoom.unreadCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                  ],
                )
              ],
            )
          )
        ]
      )
    );
  }
}
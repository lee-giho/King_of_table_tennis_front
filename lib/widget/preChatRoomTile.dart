import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/model/pre_chat_room.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';

class PreChatRoomTile extends StatefulWidget {
  final PreChatRoom preChatRoom;
  final double profileImageSize;
  final double fontSize;
  const PreChatRoomTile({
    super.key,
    required this.preChatRoom,
    this.profileImageSize = 40,
    this.fontSize = 16
  });

  @override
  State<PreChatRoomTile> createState() => _PreChatRoomTileState();
}

class _PreChatRoomTileState extends State<PreChatRoomTile> {
  @override
  Widget build(BuildContext context) {

    final UserInfoDTO friend = widget.preChatRoom.friend;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          ClipOval( // 프로필 사진
            child: friend.profileImage == "default"
              ? Container(
                  width: widget.profileImageSize,
                  height: widget.profileImageSize,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1
                    ),
                    shape: BoxShape.circle
                  ),
                  child: Icon(
                      Icons.person,
                      size: widget.profileImageSize * 0.73
                    ),
              )
              : Image(
                  width: widget.profileImageSize,
                  height: widget.profileImageSize,
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    "${dotenv.env["API_ADDRESS"]}/image/profile/${friend.profileImage}"
                  )
                )
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.nickName,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Text(
                  widget.preChatRoom.lastMessage ?? "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              ],
            )
          )
        ],
      ),
    );
  }
}
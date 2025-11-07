import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';

class UserTile extends StatefulWidget {
  final UserInfoDTO userInfoDTO;
  final double profileImageSize;
  final double fontSize;
  const UserTile({
    super.key,
    required this.userInfoDTO,
    this.profileImageSize = 22,
    this.fontSize = 16
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval( // 프로필 사진
            child: widget.userInfoDTO.profileImage == "default"
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
                    "${dotenv.env["API_ADDRESS"]}/image/profile/${widget.userInfoDTO.profileImage}"
                  )
                )
          ),
          SizedBox(width: 5),
          Text(
            widget.userInfoDTO.nickName,
            style: TextStyle(
              fontSize: widget.fontSize
            ),
          ),
        ],
      ),
    );
  }
}
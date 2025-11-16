import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';

class ProfileImageCircle extends StatelessWidget {
  final UserInfoDTO userInfoDTO;
  final double profileImageSize;
  const ProfileImageCircle({
    super.key,
    required this.userInfoDTO,
    this.profileImageSize = 25
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval( // 프로필 사진
      child: userInfoDTO.profileImage == "default"
        ? Container(
            width: profileImageSize,
            height: profileImageSize,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1
              ),
              shape: BoxShape.circle
            ),
            child: Icon(
                Icons.person,
                size: profileImageSize * 0.73
              ),
        )
        : Image(
            width: profileImageSize,
            height: profileImageSize,
            fit: BoxFit.cover,
            image: NetworkImage(
              "${dotenv.env["API_ADDRESS"]}/image/profile/${userInfoDTO.profileImage}"
            )
          )
    );
  }
}
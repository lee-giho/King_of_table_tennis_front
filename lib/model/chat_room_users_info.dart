import 'package:king_of_table_tennis/model/user_info_dto.dart';

class ChatRoomUsersInfo {
  final UserInfoDTO myInfo;
  final UserInfoDTO friendInfo;

  ChatRoomUsersInfo({
    required this.myInfo,
    required this.friendInfo,
  });

  factory ChatRoomUsersInfo.fromJson(Map<String, dynamic> json) {
    return ChatRoomUsersInfo(
      myInfo: json['myInfo'] != null
        ? UserInfoDTO.fromJson(json['myInfo'])
        : UserInfoDTO.empty(),
      friendInfo: json['friendInfo'] != null
        ? UserInfoDTO.fromJson(json['friendInfo'])
        : UserInfoDTO.empty()
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String? gameInfoId;
  const UserProfileScreen({
    super.key,
    required this.userId,
    this.gameInfoId
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  UserInfoDTO? userInfo;

  @override
  void initState() {
    super.initState();

    handleGetUserInfo(widget.userId);
  }

  void handleGetUserInfo(String userId) async {
    final response = await apiRequest(() => getUserInfo(userId), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final info = UserInfoDTO.fromJson(data);
      setState(() {
        userInfo = info;
      });
    }
  }

  void handleAcceptApplicant(String gameInfoId, String applicantId) async {
    print("gameInfoId: $gameInfoId / applicantId: $applicantId");
    final response = await apiRequest(() => acceptApplicant(gameInfoId, applicantId), context);

    if (response.statusCode == 204) {
      ToastMessage.show("${userInfo!.nickName}님을 수락하였습니다.");
      Navigator.pop(context);
    } else {
      ToastMessage.show("${userInfo!.nickName}님을 수락하지 못했습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.topLeft,
          child: Text(
            userInfo == null
              ? ""
              : userInfo!.nickName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: userInfo == null
        ? const CircularProgressIndicator(color: Colors.white)
        : Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: ClipOval( // 프로필 사진
                            child: userInfo == null || userInfo!.profileImage == "default"
                              ? Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1
                                    ),
                                    shape: BoxShape.circle
                                  ),
                                  child: const Icon(
                                      Icons.person,
                                      size: 80
                                    ),
                              )
                              : Image(
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    "${dotenv.env["API_ADDRESS"]}/image/profile/${userInfo!.profileImage}"
                                  )
                                )
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "아이디",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    userInfo!.id,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700]
                                    )
                                  )
                                ],
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "이름",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    userInfo!.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700]
                                    )
                                  )
                                ],
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "닉네임",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    userInfo!.nickName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700]
                                    )
                                  )
                                ],
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "이메일",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    userInfo!.email,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700]
                                    )
                                  )
                                ],
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "라켓",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    userInfo!.racketType,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700]
                                    )
                                  )
                                ],
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "레벨",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    userInfo!.userLevel,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700]
                                    )
                                  )
                                ],
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "전적",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${userInfo!.winCount + userInfo!.defeatCount}전",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[700]
                                        )
                                      ),
                                      Text(
                                        " ${userInfo!.winCount}승",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[700]
                                        )
                                      ),
                                      Text(
                                        " ${userInfo!.defeatCount}패",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[700]
                                        )
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ]
                        )
                      )
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  handleAcceptApplicant(widget.gameInfoId!, widget.userId);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.racketRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                  )
                ),
                child: const Text(
                  "수락하기",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                )
              )
            ],
          ),
        )
      ),
    );
  }
}
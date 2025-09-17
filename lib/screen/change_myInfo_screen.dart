import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';
import 'package:king_of_table_tennis/screen/change_nickName_screen.dart';
import 'package:king_of_table_tennis/screen/change_password_screen.dart';
import 'package:king_of_table_tennis/screen/change_racketType_screen.dart';
import 'package:king_of_table_tennis/screen/login_screen.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/secure_storage.dart';

class ChangeMyInfoScreen extends StatefulWidget {
  const ChangeMyInfoScreen({super.key});

  @override
  State<ChangeMyInfoScreen> createState() => _ChangeMyInfoScreenState();
}

class _ChangeMyInfoScreenState extends State<ChangeMyInfoScreen> {

  UserInfoDTO? myInfo;

  @override
  void initState() {
    super.initState();

    handleMyInfo();
  }

  void handleMyInfo() async {
    final response = await apiRequest(() => getMyInfo(), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final info = UserInfoDTO.fromJson(data);
      setState(() {
        myInfo = info;
      });
    }
  }

  void handleLogout() async {
    await SecureStorage.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen()
      ),
      (route) => false // 스택에 남는 페이지 없이 전체 초기화
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "내 정보 변경",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: myInfo == null
        ? const CircularProgressIndicator(color: Colors.white)
        : SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: ClipOval( // 프로필 사진
                      child: myInfo == null
                        ? Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1
                              ),
                              borderRadius: BorderRadius.circular(100)
                            ),
                            child: const Icon(
                                Icons.question_mark,
                                size: 80
                              ),
                        )
                        : Image(
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              "${dotenv.env["API_ADDRESS"]}/image/profile/${myInfo!.profileImage}"
                            )
                          )
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
                                myInfo!.id,
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
                                myInfo!.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700]
                                )
                              )
                            ],
                          ),
                        ),
                        Divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeNickNameScreen(
                                  fetchMyInfo: handleMyInfo,
                                )
                              )
                            );
                          },
                          child: Padding(
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
                                Row(
                                  children: [
                                    Text(
                                      myInfo!.nickName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[700]
                                      )
                                    ),
                                    SizedBox(
                                      width: 5
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                    )
                                  ],
                                )
                              ],
                            ),
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
                                myInfo!.email,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700]
                                )
                              )
                            ],
                          ),
                        ),
                        Divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeRacketTypeScreen(
                                  racketType: myInfo!.racketType,
                                  fetchMyInfo: handleMyInfo,
                                )
                              )
                            );
                          },
                          child: Padding(
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
                                Row(
                                  children: [
                                    Text(
                                      myInfo!.racketType,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[700]
                                      )
                                    ),
                                    SizedBox(
                                      width: 5
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                    )
                                  ],
                                )
                              ],
                            ),
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
                                myInfo!.userLevel,
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
                                    "${myInfo!.winCount + myInfo!.defeatCount}전",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700]
                                    )
                                  ),
                                  Text(
                                    " ${myInfo!.winCount}승",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700]
                                    )
                                  ),
                                  Text(
                                    " ${myInfo!.defeatCount}패",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700]
                                    )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePasswordScreen()
                              )
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "비밀번호 변경하기",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.tableBlue
                        ),
                        onPressed: () {
                          handleLogout();
                        },
                        child: Text(
                          "로그아웃",
                          style: TextStyle(
                            color: AppColors.tableBlue
                          ),
                        )
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.racketRed
                        ),
                        onPressed: () {

                        },
                        child: Text(
                          "회원탈퇴",
                          style: TextStyle(
                            color: AppColors.racketRed
                          ),
                        )
                      )
                    ],
                  )
                ],
              ),
            ),
          )
      ),
    );
  }
}
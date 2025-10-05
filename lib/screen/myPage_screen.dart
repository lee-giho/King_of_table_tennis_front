import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/screen/change_myInfo_screen.dart';
import 'package:king_of_table_tennis/screen/my_review_info_screen.dart';
import 'package:king_of_table_tennis/screen/my_tableTennis_info_screen.dart';
import 'package:king_of_table_tennis/widget/userInfoInMyPage.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/model/mySimpleInfo.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {

  MySimpleInfo? mySimpleInfo;

  @override
  void initState() {
    super.initState();

    handleMySimpleInfo();
  }

  void handleMySimpleInfo() async {
    final response = await apiRequest(() => getMySimpleInfo(), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final info = MySimpleInfo.fromJson(data);
      print(data);
      setState(() {
        mySimpleInfo = info;
      });

    } else {
      log("간단한 내 정보 가져오기 실패");
    }
  }

  Widget buildMenuItem(IconData icon, String label, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => screen
            )
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 28,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18
                    )
                  )
                ]
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 25,
            )
          ]
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "마이페이지",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: mySimpleInfo == null
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeMyInfoScreen(
                                fetchMySimpleInfo: () {
                                  handleMySimpleInfo();
                                },
                              )
                            )
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: UserInfoInMyPage(
                          mySimpleInfo: mySimpleInfo!
                        )
                      ),
                    )
                  ),
                  buildMenuItem(Icons.sports_tennis, "탁구 경기 내역", MyTableTennisInfoScreen()),
                  buildMenuItem(Icons.rate_review, "경기 리뷰 내역", MyReviewInfoScreen())
                ],
              ),
        )
      ),
    );
  }
}
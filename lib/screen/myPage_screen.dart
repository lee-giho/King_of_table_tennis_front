import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/screen/change_myInfo_screen.dart';
import 'package:king_of_table_tennis/widget/userInfoInMyPage.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
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
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeMyInfoScreen()
                      )
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: UserInfoInMyPage()
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}
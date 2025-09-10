import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/model/mySimpleInfo.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';

class UserInfoInMyPage extends StatefulWidget {
  const UserInfoInMyPage({super.key});

  @override
  State<UserInfoInMyPage> createState() => _UserInfoInMyPageState();
}

class _UserInfoInMyPageState extends State<UserInfoInMyPage> {

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

  @override
  Widget build(BuildContext context) {
    return mySimpleInfo == null
    ? const CircularProgressIndicator(color: Colors.white)
    : Container(
        width: double.infinity,
        height: 120,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20)
        ),
        child: Row(
          children: [
            // Container(
            //   width: 100,
            //   height: 100,
            //   decoration: BoxDecoration(
            //     border: Border.all(
            //       width: 1
            //     ),
            //     borderRadius: BorderRadius.circular(50)
            //   ),
            // ),
            ClipOval(
              child: mySimpleInfo == null
                ? Container(
                    width: 100,
                    height: 100,
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
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      "${dotenv.env["API_ADDRESS"]}/image/profile/${mySimpleInfo!.profileImage}"
                    )
                  )
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mySimpleInfo!.nickName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mySimpleInfo!.racketType,
                      ),
                      Text(
                        "${mySimpleInfo!.winCount + mySimpleInfo!.defeatCount}전 ${mySimpleInfo!.winCount}승 ${mySimpleInfo!.defeatCount}패"
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios
            )
          ],
        ),
      );
  }
}
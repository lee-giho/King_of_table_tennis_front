import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/model/mySimpleInfo.dart';

class UserInfoInMyPage extends StatefulWidget {
  final MySimpleInfo mySimpleInfo;
  const UserInfoInMyPage({
    super.key,
    required this.mySimpleInfo
  });

  @override
  State<UserInfoInMyPage> createState() => _UserInfoInMyPageState();
}

class _UserInfoInMyPageState extends State<UserInfoInMyPage> {

  @override
  Widget build(BuildContext context) {
    return widget.mySimpleInfo.nickName.isEmpty
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
            ClipOval(
              child: widget.mySimpleInfo.nickName.isEmpty || widget.mySimpleInfo.profileImage == "default"
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
                        Icons.person,
                        size: 80
                      ),
                )
                : Image(
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      "${dotenv.env["API_ADDRESS"]}/image/profile/${widget.mySimpleInfo.profileImage}"
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
                    widget.mySimpleInfo.nickName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mySimpleInfo.racketType,
                      ),
                      Text(
                        "${widget.mySimpleInfo.winCount + widget.mySimpleInfo.defeatCount}전 ${widget.mySimpleInfo.winCount}승 ${widget.mySimpleInfo.defeatCount}패"
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
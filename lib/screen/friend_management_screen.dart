import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/screen/blocked_friend_list_screen.dart';
import 'package:king_of_table_tennis/screen/received_friend_request_list_screen.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';

class FriendManagementScreen extends StatefulWidget {
  final VoidCallback refreshRequestCount;
  const FriendManagementScreen({
    super.key,
    required this.refreshRequestCount
  });

  @override
  State<FriendManagementScreen> createState() => _FriendManagementScreenState();
}

class _FriendManagementScreenState extends State<FriendManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              "친구 관리",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.tableBlue,
            overlayColor: MaterialStateProperty.all(const Color.fromARGB(39, 30, 77, 135)),
            tabs: [
              Tab(
                child: Text(
                  "친구 요청",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "차단한 친구",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ]
          ),
        ),
        body: TabBarView(
          children: [
            ReceivedFriendRequestListScreen(
              refreshRequestCount: widget.refreshRequestCount
            ),
            BlockedFriendListScreen()
          ]
        ),
      )
    );
  }
}
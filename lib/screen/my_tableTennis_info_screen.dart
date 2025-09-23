import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/screen/game_after_list_screen.dart';
import 'package:king_of_table_tennis/screen/game_before_list_screen.dart';
import 'package:king_of_table_tennis/util/appColors.dart';

class MyTableTennisInfoScreen extends StatefulWidget {
  const MyTableTennisInfoScreen({super.key});

  @override
  State<MyTableTennisInfoScreen> createState() => _MyTableTennisInfoScreenState();
}

class _MyTableTennisInfoScreenState extends State<MyTableTennisInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              "탁구 경기 내역",
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
                  "경기 전",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "경기 후",
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
            GameBeforeListScreen(),
            GameAfterListScreen()
          ]
        )
      )
    );
  }
}
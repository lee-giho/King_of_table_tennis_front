import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/screen/chatting_screen.dart';
import 'package:king_of_table_tennis/screen/game_history_screen.dart';
import 'package:king_of_table_tennis/screen/home_screen.dart';
import 'package:king_of_table_tennis/screen/myPage_screen.dart';
import 'package:king_of_table_tennis/screen/ranking_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  // 현재 화면 인덱스
  int selectedIndex = 2;

  // 화면 리스트
  final List<Widget> screenList = <Widget>[
    const GameHistoryScreen(),
    const RankingScreen(),
    const HomeScreen(),
    const ChattingScreen(),
    const MyPageScreen()
  ];

  // 네비게이션바 아이콘 클릭 이벤트
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screenList[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history
            ),
            label: "전적"
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.leaderboard
            ),
            label: "랭킹"
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home
            ),
            label: "홈"
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat
            ),
            label: "채팅"
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person
            ),
            label: "마이페이지"
          )
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        selectedItemColor: Color.fromRGBO(138, 50, 50, 1),
        unselectedItemColor: Color.fromRGBO(31, 31, 31, 1),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
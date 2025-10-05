import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/screen/received_review_screen.dart';
import 'package:king_of_table_tennis/screen/written_review_screen.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';

class MyReviewInfoScreen extends StatefulWidget {
  const MyReviewInfoScreen({super.key});

  @override
  State<MyReviewInfoScreen> createState() => _MyReviewInfoScreenState();
}

class _MyReviewInfoScreenState extends State<MyReviewInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              "경기 리뷰 내역",
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
                  "작성한 리뷰",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "받은 리뷰",
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
            WrittenReviewScreen(),
            ReceivedReviewScreen()
          ]
        ),
      )
    );
  }
}
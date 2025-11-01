import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/screen/my_comment_info_screen.dart';
import 'package:king_of_table_tennis/screen/my_post_info_screen.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';

class PostAndCommentScreen extends StatefulWidget {
  const PostAndCommentScreen({super.key});

  @override
  State<PostAndCommentScreen> createState() => _PostAndCommentScreenState();
}

class _PostAndCommentScreenState extends State<PostAndCommentScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              "게시글 및 댓글 내역",
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
                  "게시글",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "댓글",
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
            MyPostInfoScreen(),
            MyCommentInfoScreen()
          ]
        ),
      )
    );
  }
}
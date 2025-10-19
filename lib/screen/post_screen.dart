import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/screen/post_registration_screen.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "커뮤니티",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Center(child: Text("커뮤니티 화면"))
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.tableBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostRegistrationScreen()
            )
          );
        },
        child: Icon(
          Icons.add,
          size: 40,
        ),
      ),
    );
  }
}
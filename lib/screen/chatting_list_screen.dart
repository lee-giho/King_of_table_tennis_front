import 'package:flutter/material.dart';

class ChattingListScreen extends StatefulWidget {
  const ChattingListScreen({super.key});

  @override
  State<ChattingListScreen> createState() => _ChattingListScreenState();
}

class _ChattingListScreenState extends State<ChattingListScreen> {
  @override
  Widget build(BuildContext context) {
    return Text(
      "채팅 목록"
    );
  }
}
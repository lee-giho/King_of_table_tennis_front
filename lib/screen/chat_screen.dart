import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  var messageController = TextEditingController();
  FocusNode messageFocus = FocusNode();

  bool sending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "닉네임",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            )
          )
        )
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
            child: Container( // 전체화면
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
          )
        )
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  focusNode: messageFocus,
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                    )
                  ),
                  onSubmitted: sending
                    ? null
                    : (_) async {
                        if (messageController.text.trim().isNotEmpty) {
                          // 메시지 전송 함수
                        }
                      },
                )
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: sending
                  ? null
                  : () async {
                      if (messageController.text.trim().isNotEmpty) {
                        // 메시지 전송 함수
                      }
                    },
                icon: sending
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator()
                    )
                  : Icon(
                    Icons.send
                  )
              )
            ],
          )
        ),
      )
    );
  }
}
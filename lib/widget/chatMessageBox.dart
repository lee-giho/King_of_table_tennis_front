import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/model/chat_message.dart';
import 'package:king_of_table_tennis/util/intl.dart';

class ChatMessageBox extends StatefulWidget {
  final ChatMessage chatMessage;
  final bool isMine;
  final bool showTime;
  final int unreadCount;

  const ChatMessageBox({
    super.key,
    required this.chatMessage,
    required this.isMine,
    required this.showTime,
    this.unreadCount = 0
  });

  @override
  State<ChatMessageBox> createState() => _ChatMessageBoxState();
}

class _ChatMessageBoxState extends State<ChatMessageBox> {

  Widget buildTimeText() {
    return Text(
      formatSimpleDateTime(widget.chatMessage.sentAt),
      style: TextStyle(
        fontSize: 10
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    final double maxBubbleWidth = MediaQuery.of(context).size.width * 0.6;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.isMine && widget.unreadCount != 0)
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 2),
                  child: Text(
                    widget.unreadCount.toString(),
                    style: TextStyle(
                      fontSize: 11
                    ),
                  ),
                ),
              if (widget.isMine && widget.showTime)
                buildTimeText(),
            ]
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxBubbleWidth
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.isMine
                ? const Color.fromARGB(255, 176, 255, 179)
                : const Color.fromARGB(255, 255, 231, 159),
              borderRadius: BorderRadius.circular(5)
            ),
            child: Text(
              widget.chatMessage.content,
              style: TextStyle(
                fontSize: 16
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        if (!widget.isMine && widget.showTime)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: buildTimeText(),
          )
      ]
    );
  }
}
import 'package:flutter/material.dart';

class ExpandableWidget extends StatefulWidget {
  final Widget widget;

  const ExpandableWidget({
    Key? key,
    required this.widget,
  }) : super(key: key);

  @override
  State<ExpandableWidget> createState() => _ExpandableTextSWidget();
}

class _ExpandableTextSWidget extends State<ExpandableWidget>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isExpanded 
                        ? "접기"
                        : "더보기",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down
                    )
                  ],
                ),
              ),
            ),
            if (isExpanded)
              AnimatedSize(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.widget
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

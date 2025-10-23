import 'package:flutter/material.dart';

class ExpandableTitle extends StatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle? style;

  const ExpandableTitle({
    Key? key,
    required this.text,
    this.trimLines = 1,
    this.style,
  }) : super(key: key);

  @override
  State<ExpandableTitle> createState() => _ExpandableTitleState();
}

class _ExpandableTitleState extends State<ExpandableTitle>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  bool shouldTrim = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 텍스트 오버플로우 체크
        final textPainter = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: widget.style ?? DefaultTextStyle.of(context).style,
          ),
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);
        shouldTrim = textPainter.didExceedMaxLines;

        return GestureDetector(
          onTap: shouldTrim
          ? () {
              setState(() {
                isExpanded = !isExpanded;
              });
            }
          : null,
          child: AnimatedSize(
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style: widget.style,
                  maxLines: isExpanded
                    ? null
                    : widget.trimLines,
                  overflow: isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                  textAlign: TextAlign.left
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

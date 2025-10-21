import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/enum/post_type.dart';
import 'package:king_of_table_tennis/model/post.dart';
import 'package:king_of_table_tennis/util/intl.dart';
import 'package:king_of_table_tennis/widget/expandableTitle.dart';

class PostPreviewTile extends StatefulWidget {
  final Post post;
  const PostPreviewTile({
    super.key,
    required this.post
  });

  @override
  State<PostPreviewTile> createState() => _PostPreviewTileState();
}

class _PostPreviewTileState extends State<PostPreviewTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.black
        ),
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        children: [
          ExpandableTitle( 
            text: widget.post.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            )
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black
                  ),
                  borderRadius: BorderRadius.circular(15),
                  color: widget.post.category.color
                ),
                child: Text(
                  widget.post.category.label,
                  style: TextStyle(
                    fontSize: 12
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "작성자: "
                  ),
                  Text(
                    widget.post.writer.nickName
                  )
                ],
              ),
              Text( // 작성 날짜
                formatDateTime(widget.post.writeAt)
              )
            ],
          )
        ],
      ),
    );
  }
}
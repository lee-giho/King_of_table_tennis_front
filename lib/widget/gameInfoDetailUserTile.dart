import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';

class GameInfoDetailUserTile extends StatefulWidget {
  final UserInfoDTO userInfo;
  const GameInfoDetailUserTile({
    super.key,
    required this.userInfo
  });

  @override
  State<GameInfoDetailUserTile> createState() => _GameInfoDetailUserTileState();
}

class _GameInfoDetailUserTileState extends State<GameInfoDetailUserTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.black
        ),
        borderRadius: BorderRadius.circular(15)
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              ClipOval(
                child: widget.userInfo.id.isEmpty || widget.userInfo.profileImage == "default"
                  ? Container(
                      width: constraints.maxWidth,
                      height: constraints.maxWidth,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1
                        ),
                        borderRadius: BorderRadius.circular(100)
                      ),
                      child: const Icon(
                          Icons.person,
                          size: 80
                        ),
                  )
                  : Image(
                      width: constraints.maxWidth,
                      height: constraints.maxWidth,
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        "${dotenv.env["API_ADDRESS"]}/image/profile/${widget.userInfo.profileImage}"
                      )
                    )
              ),
              Text(
                widget.userInfo.id.isEmpty
                  ? "모집중"
                  : widget.userInfo.nickName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.userInfo.id.isEmpty
                      ? ""
                      : "라켓:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    widget.userInfo.id.isEmpty
                      ? ""
                      : widget.userInfo.racketType,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.userInfo.id.isEmpty
                      ? ""
                      : "실력:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    widget.userInfo.id.isEmpty
                      ? ""
                      : widget.userInfo.userLevel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ],
              ),
              Row( // 추가해야함
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.userInfo.id.isEmpty
                      ? ""
                      : "전적:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        widget.userInfo.id.isEmpty
                          ? ""
                          : "${widget.userInfo.totalGames}전",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                      Text(
                        widget.userInfo.id.isEmpty
                          ? ""
                          : "${widget.userInfo.winCount}승",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                      Text(
                        widget.userInfo.id.isEmpty
                          ? ""
                          : "${widget.userInfo.defeatCount}패",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
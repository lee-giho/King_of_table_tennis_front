import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/api/post_api.dart';
import 'package:king_of_table_tennis/enum/post_sort_option.dart';
import 'package:king_of_table_tennis/enum/post_type.dart';
import 'package:king_of_table_tennis/model/game_detail_info_by_page_dto.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/post.dart';
import 'package:king_of_table_tennis/screen/post_detail_screen.dart';
import 'package:king_of_table_tennis/screen/post_screen.dart';
import 'package:king_of_table_tennis/screen/search_table_tennis_court_screen.dart';
import 'package:king_of_table_tennis/screen/table_tennis_game_info_detail_screen.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/widget/gamePreviewTile.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  var searchKeywordController = TextEditingController();

  FocusNode searchKeywordFocus = FocusNode();

  int gamePage = 0;
  int gamePageSize = 1;
  int gameTotalPages = 0;

  GameDetailInfoByPageDTO? gameDetailInfoByPageDTO;

  int postPage = 0;
  int postPageSize = 3;
  List<PostType> categories = [PostType.GENERAL, PostType.SKILL, PostType.EQUIPMENT];

  List<Post>? posts;

  StompClient? stompClient;
  String? subscribedGameId;

  @override
  void initState() {
    super.initState();

    handleGetGameDetailInfoByPage(gamePage, gamePageSize);
    handleGetPost(postPage, postPageSize, categories);
  }

  @override
  void dispose() {
    stompClient?.deactivate();

    super.dispose();
  }

  void handleGetGameDetailInfoByPage(int page, int size) async {
    final response = await apiRequest(() => getGameDetailInfoByPage(page, size), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pageResponse = PageResponse<GameDetailInfoByPageDTO>.fromJson(
        data,
        (json) => GameDetailInfoByPageDTO.fromJson(json)
      );

      if (pageResponse.content.isEmpty) {
        setState(() {
          gameDetailInfoByPageDTO = null;
          gameTotalPages = pageResponse.totalPages;
        });
        
        return;
      }

      setState(() {
        gameDetailInfoByPageDTO = pageResponse.content[0];
        gameTotalPages = pageResponse.totalPages;
      });

      print(gameTotalPages);

      wsConnect();
    } else {
      log("경기 정보 가져오기 실패");
    }
  }

  void handleGetPost(int page, int size, List<PostType> categories) async {
    final response = await apiRequest(() => getPostByCategory(page, size, categories, PostSortOption.CREATED_DESC), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pageResponse = PageResponse<Post>.fromJson(
        data,
        (json) => Post.fromJson(json)
      );

      if (pageResponse.content.isEmpty) {
        setState(() {
          posts = null;
        });

        return;
      }

      setState(() {
        posts = pageResponse.content;
      });
    } else {
      log("게시글 가져오기 실패");
    }
  }

  void wsConnect() {
    final currentId = gameDetailInfoByPageDTO?.gameInfo.id;
    if (gameDetailInfoByPageDTO == null) return;

    // 같은 게임이면 재구독 불필요
    if (subscribedGameId == currentId && stompClient?.connected == true) return;

    // 기존 연결 정리
    stompClient?.deactivate();

    final wsAddress = dotenv.get("WS_ADDRESS");

    stompClient = StompClient(
      config: StompConfig(
        url: "$wsAddress/ws",
        onConnect: (StompFrame frame) {
          print("연결 성공");
          stompClient!.subscribe(
            destination: "/topic/game/state/$currentId",
            callback: (frame) {
              final body = frame.body;
              if (body != null) {
                final decodedData = jsonDecode(body);
                print("응답 데이터: $decodedData");
                handleGetGameDetailInfoByPage(gamePage, gamePageSize);
              }
            }
          );
        },
        onStompError: (f) => debugPrint("STOMP error: ${f.body}"),
        onWebSocketError: (e) => debugPrint("WS error: $e")
      )
    );

    stompClient!.activate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Container( // 전체 화면
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Center(child: Text("홈 화면")),
                Row( // 검색바
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchKeywordController,
                                focusNode: searchKeywordFocus,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  hintText: "체육관을 검색해보세요.",
                                  hintStyle: TextStyle(fontSize: 15),
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(121, 55, 64, 0)
                                    )
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color:Color.fromRGBO(122, 11, 11, 0)
                                    )
                                  )
                                ),
                                onChanged:(value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            if (searchKeywordController.text.isNotEmpty)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  searchKeywordController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.clear,
                                  size: 20,
                                )
                              )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: IconButton(
                        onPressed: () {
                          print("keyword: ${searchKeywordController.text}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchTableTennisCourtScreen(
                                keyword: searchKeywordController.text
                              )
                            )
                          );
                        },
                        icon: Icon(
                          Icons.search,
                          color: Colors.black,
                        )
                      ),
                    )
                  ],
                ),
                SizedBox(height: 30),
                Row( // 경기 미리보기
                  children: [
                    IconButton(
                      onPressed: gamePage == 0
                        ? null
                        : () {
                            handleGetGameDetailInfoByPage(--gamePage, gamePageSize);
                          },
                      icon: Icon(
                        Icons.arrow_back_ios
                      )
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TableTennisGameInfoDetailScreen(
                                  gameInfoId: gameDetailInfoByPageDTO!.gameInfo.id,
                                  isMine: gameDetailInfoByPageDTO!.isMine
                                )
                              )
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: GamePreviewTile(
                            gameDetailInfoByPageDTO: gameDetailInfoByPageDTO
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: gamePage+1 == gameTotalPages
                        ? null
                        : () {
                            handleGetGameDetailInfoByPage(++gamePage, gamePageSize);
                          },
                      icon: Icon(
                        Icons.arrow_forward_ios
                      )
                    )
                  ],
                ),
                SizedBox(height: 30),
                Column( // 게시글
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "게시글",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostScreen()
                              )
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "더보기",
                                style: TextStyle(
                                  fontSize: 16
                                ),
                              ),
                              Icon(
                                Icons.add
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: posts == null
                        ? const Text(
                            "등록된 게시글이 없습니다."
                          )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: posts!.map((p) => InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailScreen(
                                    postId: p.id,
                                    
                                  )
                                )
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          ClipOval( // 프로필 사진
                                            child: p.writer.profileImage == "default"
                                              ? Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 1
                                                    ),
                                                    shape: BoxShape.circle
                                                  ),
                                                  child: const Icon(
                                                      Icons.person,
                                                      size: 16
                                                    ),
                                              )
                                              : Image(
                                                  width: 22,
                                                  height: 22,
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                    "${dotenv.env["API_ADDRESS"]}/image/profile/${p.writer.profileImage}"
                                                  )
                                                )
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            p.writer.nickName,
                                            style: TextStyle(
                                              fontSize: 16
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.black
                                          ),
                                          borderRadius: BorderRadius.circular(15),
                                          color: p.category.color
                                        ),
                                        child: Text(
                                          p.category.label,
                                          style: TextStyle(
                                            fontSize: 10
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                          ).toList()
                        )
                    )
                  ],
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}
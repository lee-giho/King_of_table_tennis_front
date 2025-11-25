import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/model/game_record_info.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/user_game_records_stats_response.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/secure_storage.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/gameRecordTile.dart';
import 'package:king_of_table_tennis/widget/profileImageCircle.dart';

class GameHistoryScreen extends StatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {

  var searchKeywordController = TextEditingController();
  FocusNode searchKeywordFocus = FocusNode();
  String searchKeyword = "";

  int searchUserPage = 0;
  int searchUserPageSize = 10;
  int searchUserTotalPages = 0;

  bool isSearch = false;

  List<UserInfoDTO> searchUsers = [];

  int gameRecordPage = 0;
  int gameRecordPageSize = 20;
  int gameRecordTotalPages = 0;

  List<GameRecordInfo> gameRecords = [];

  UserGameRecordsStatsResponse? userGameRecordsStats;

  @override
  void initState() {
    super.initState();

    handleGetMyGameRecords(gameRecordPage, gameRecordPageSize);
  }

  void handleGetMyGameRecords(int page, int size) async {
    String? myId = await SecureStorage.getId();

    handleGetUserGameRecordsStats(myId!);
    handleGetGameRecords(myId!, page, size);
  }

  void handleGetUserGameRecordsStats(String userId) async {
    final response = await apiRequest(() => getUserGameRecordsStats(userId), context);
log(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final stats = UserGameRecordsStatsResponse.fromJson(data);

      setState(() {
        userGameRecordsStats = stats;
      });
    } else {
      ToastMessage.show("$userId의 스탯을 가져오는데 실패했습니다.");
    }
  }

  void handleGetGameRecords(String userId, int page, int size) async {
    final response = await apiRequest(() => getGameRecords(userId, page, size), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pageResponse = PageResponse<GameRecordInfo>.fromJson(
        data,
        (json) => GameRecordInfo.fromJson(json)
      );

      final int totalPages = pageResponse.totalPages;

      if (pageResponse.content.isEmpty && totalPages > 0 && page >= totalPages) {
        final int lastPage = totalPages - 1;
        if (lastPage != page) {
          if (!mounted) return;
          setState(() {
            gameRecordPage = lastPage;
            gameRecords = [];
            gameRecordTotalPages = pageResponse.totalPages;
          });
          handleGetGameRecords(userId, lastPage, size);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        gameRecords = pageResponse.content;
        gameRecordTotalPages = totalPages;
        gameRecordPage = page;
      });
    } else {
      ToastMessage.show("$userId의 전적 가져오기 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final FocusScopeNode currentscope = FocusScope.of(context);
          if (!currentscope.hasPrimaryFocus && currentscope.hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Center(child: Text("경기내역 화면")),
                Padding( // 검색바
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
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
                                    hintText: "친구를 검색해보세요.",
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
                                  onSubmitted: (_) {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      searchUserPage = 0;
                                    });
                                    // handleSearchUsers(searchKeywordController.text, onlyFriend, searchUserPage, searchUserPageSize);
                                  },
                                ),
                              ),
                              if (searchKeywordController.text.isNotEmpty)
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    searchKeywordController.clear();
                                    setState(() {
                                      searchKeyword = "";
                                      searchUserPage = 0;
                                      searchUsers = [];
                                      isSearch = false;
                                    });
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
                            FocusScope.of(context).unfocus();
                            setState(() {
                              searchUserPage = 0;
                            });
                            // handleSearchUsers(searchKeywordController.text, onlyFriend, searchUserPage, searchUserPageSize);
                          },
                          icon: Icon(
                            Icons.search,
                            color: Colors.black,
                          )
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: gameRecords.isEmpty
                    ? const Center(
                        child: Text(
                          "경기 정보가 없습니다."
                        ),
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final gameRecord = gameRecords[index];
                                return Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                  child: InkWell(
                                    onTap: () {
                                      
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    child: GameRecordTile(
                                      gameRecordInfo: gameRecord
                                    ),
                                  ),
                                );
                              },
                              childCount: gameRecords.length
                            )
                          )
                        ],
                      )
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}
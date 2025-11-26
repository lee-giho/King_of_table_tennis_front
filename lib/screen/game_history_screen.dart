import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/enum/friend_status.dart';
import 'package:king_of_table_tennis/model/game_record_info.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/user_game_records_stats_response.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/secure_storage.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/customDivider.dart';
import 'package:king_of_table_tennis/widget/gameRecordTile.dart';
import 'package:king_of_table_tennis/widget/profileImageCircle.dart';
import 'package:king_of_table_tennis/widget/userTile.dart';

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
  bool isViewingOtherUser = false;

  bool isSearchUserLoading = false;

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

    setState(() {
      isViewingOtherUser = false;
    });

    handleGetUserGameRecordsStats(myId!);
    handleGetGameRecords(myId, page, size);
  }

  void handleGetUserGameRecords(String userId, int page, int size) async {
    handleGetUserGameRecordsStats(userId);
    handleGetGameRecords(userId, page, size);
  }

  void handleGetUserGameRecordsStats(String userId) async {
    final response = await apiRequest(() => getUserGameRecordsStats(userId), context);

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

  void handleSearchUsers(String keyword, bool onlyFriend, int page, int size, {bool append = false}) async {
    if (isSearchUserLoading) return;
    
    setState(() {
      isSearchUserLoading = true;
    });

    final response = await apiRequest(() => searchUser(keyword, onlyFriend, page, size), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pageResponse = PageResponse<UserInfoDTO>.fromJson(
        data,
        (json) => UserInfoDTO.fromJson(json)
      );

      final int totalPages = pageResponse.totalPages;

      if (pageResponse.content.isEmpty && totalPages > 0 && page >= totalPages) {
        final int lastPage = totalPages - 1;
        if (lastPage != page) {
          if (!mounted) return;
          setState(() {
            searchUserPage = lastPage;
            searchUsers = [];
            searchUserTotalPages = pageResponse.totalPages;
          });
          handleSearchUsers(keyword, onlyFriend, lastPage, size, append: append);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        searchKeyword = keyword;
        searchUserTotalPages = totalPages;
        searchUserPage = page;
        isSearch = true;

        if (append) {
          searchUsers.addAll(pageResponse.content);
        } else {
          searchUsers = pageResponse.content;
        }
      });
    } else {
      ToastMessage.show("사용자 검색 실패");
    }

    if (mounted) {
      setState(() {
        isSearchUserLoading = false;
      });
    }
  }

  Widget buildUserGameRecords() {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.black
              ),
              borderRadius: BorderRadius.circular(15)
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                  child: Column( // 프로필
                    children: [
                      ProfileImageCircle(
                        profileImage: userGameRecordsStats!.profileImage,
                        profileImageSize: 50,
                      ),
                      Text(
                        userGameRecordsStats!.nickName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                ),
                Column( // 전적
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "최근 10경기: "
                        ),
                        Text(
                          "${userGameRecordsStats!.recentStats.totalGames}전 ${userGameRecordsStats!.recentStats.winCount}승 ${userGameRecordsStats!.recentStats.winCount}패 (승률: ${(userGameRecordsStats!.recentStats.winRate! * 100).round()}%)"
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "전체 경기: "
                        ),
                        Text(
                          "${userGameRecordsStats!.totalStats.totalGames}전 ${userGameRecordsStats!.totalStats.winCount}승 ${userGameRecordsStats!.totalStats.defeatCount}패 (승률: ${(userGameRecordsStats!.totalStats.winRate! * 100).round()}%)"
                        )
                      ],
                    )
                  ],
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
    );
  }

  Widget buildSearchUserResults() {
    return Expanded(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          final offsetTween = Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero
          );
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(offsetTween),
              child: child,
            ),
          );
        },
        child: searchUsers.isEmpty
          ? Center(
              child: Text(
                "${searchKeyword}에 해당하는 사용자가 없습니다."
              ),
            )
          : NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100 &&
                  !isSearchUserLoading &&
                  searchUserPage + 1 < searchUserTotalPages) {
                    final nextPage = searchUserPage + 1;
                    handleSearchUsers(searchKeyword, false, nextPage, searchUserPageSize, append: true);
                  }
              return false;
            },
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = searchUsers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          gameRecordPage = 0;
                                          gameRecordTotalPages = 0;
                                          isSearch = false;
                                          isViewingOtherUser = true;
                                        });
                                        handleGetUserGameRecords(user.id, gameRecordPage, gameRecordPageSize);
                                      },
                                      borderRadius: BorderRadius.circular(15),
                                      child: UserTile(
                                        userInfoDTO: user,
                                        profileImageSize: 45,
                                        fontSize: 18
                                      )
                                    ),
                                  ),
                                  if (user.friendStatus == FriendStatus.FRIEND)
                                    Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    )
                                ],
                              ),
                              CustomDivider()
                            ],
                          )
                        )
                      );
                    },
                    childCount: searchUsers.length
                  )
                ),
              ],
            ),
          ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "전적",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
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
                                    hintText: "다른 사용자의 전적을 검색해보세요.",
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
                                    handleSearchUsers(searchKeywordController.text, false, searchUserPage, searchUserPageSize);
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
                      SizedBox(width: 5),
                      if (isViewingOtherUser)
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isSearch = false;
                                  isViewingOtherUser = false;
                                  searchKeyword = "";
                                  searchUserPage = 0;
                                  searchKeywordController.clear();
                                  searchUsers = [];
                                });
                                handleGetMyGameRecords(gameRecordPage, gameRecordPageSize);
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.racketRed,
                                foregroundColor: Colors.white
                              ),
                              icon: Icon(
                                Icons.refresh
                              )
                            ),
                            SizedBox(width: 5)
                          ]
                        ),
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
                            handleSearchUsers(searchKeywordController.text, false, searchUserPage, searchUserPageSize);
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
                isSearch
                  ? buildSearchUserResults()
                  : userGameRecordsStats != null
                    ? buildUserGameRecords()
                    : const SizedBox()
              ],
            ),
          )
        ),
      ),
    );
  }
}
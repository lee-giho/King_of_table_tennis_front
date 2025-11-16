import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:king_of_table_tennis/api/chat_room_api.dart';
import 'package:king_of_table_tennis/api/friend_api.dart';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/api/user_block_api.dart';
import 'package:king_of_table_tennis/enum/friend_request_answer_type.dart';
import 'package:king_of_table_tennis/enum/friend_status.dart';
import 'package:king_of_table_tennis/enum/search_user_range.dart';
import 'package:king_of_table_tennis/model/count_response.dart';
import 'package:king_of_table_tennis/model/friend_request.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';
import 'package:king_of_table_tennis/screen/chat_screen.dart';
import 'package:king_of_table_tennis/screen/friend_management_screen.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/customDivider.dart';
import 'package:king_of_table_tennis/widget/customStringPicker.dart';
import 'package:king_of_table_tennis/widget/paginationBar.dart';
import 'package:king_of_table_tennis/widget/userTile.dart';

class ChattingFriendListScreen extends StatefulWidget {
  const ChattingFriendListScreen({super.key});

  @override
  State<ChattingFriendListScreen> createState() => _ChattingFriendListScreenState();
}

class _ChattingFriendListScreenState extends State<ChattingFriendListScreen> {

  var searchKeywordController = TextEditingController();
  FocusNode searchKeywordFocus = FocusNode();
  String searchKeyword = "";

  bool onlyFriend = true;

  int searchUserPage = 0;
  int searchUserPageSize = 10;
  int searchUserTotalPages = 0;

  SearchUserRange selectedSearchUserRange = SearchUserRange.FRIEND;

  bool isSearch = false;

  List<UserInfoDTO> searchUsers = [];
  

  int friendUserPage = 0;
  int friendUserPageSize = 20;
  int friendUserTotalPages = 0;
  int friendUserTotalElements = 0;

  List<UserInfoDTO> friendUsers = [];

  int receivedFriendRequestCount = 0;

  int blockUserCount = 0;

  @override
  void initState() {
    super.initState();

    handleGetFriendRequestCountByFriendStatus(FriendStatus.RECEIVED);
    handleGetBlockedFriendCount();
    handleGetMyFriend(friendUserPage, friendUserPageSize);
  }

  @override
  void dispose() {
    searchKeywordController.dispose();
    searchKeywordFocus.dispose();

    super.dispose();
  }

  void handleSearchUsers(String keyword, bool onlyFriend, int page, int size) async {
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
          handleSearchUsers(keyword, onlyFriend, page, size);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        searchKeyword = searchKeywordController.text;
        searchUsers = pageResponse.content;
        searchUserTotalPages = totalPages;
        searchUserPage = page;
        isSearch = true;
      });
    } else {
      log("사용자 검색 실패");
    }
  }

  void handleGetFriendRequestCountByFriendStatus(FriendStatus friendStatus) async {
    final response = await apiRequest(() => getFriendRequestCountByFriendStatus(friendStatus), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final countResponse = CountResponse.fromJson(data);

      setState(() {
        receivedFriendRequestCount = countResponse.count;
      });
      
    } else {
      log("$friendStatus에 해당하는 개수 가져오기 실패");
    }
  }

  void handleGetBlockedFriendCount() async {
    final response = await apiRequest(() => getBlockedFriendCount(), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final countResponse = CountResponse.fromJson(data);

      setState(() {
        blockUserCount = countResponse.count;
      });
      
    } else {
      log("차단한 친구 수 가져오기 실패");
    }
  }

  void handleResponseFriendRequest(String targetUserId, FriendRequestAnswerType friendRequestAnswerType) async {
    final response = await apiRequest(() => responseFriendRequest(targetUserId, friendRequestAnswerType), context);

    if (response.statusCode == 204) {
      if (friendRequestAnswerType == FriendRequestAnswerType.ACCEPT) {
        ToastMessage.show("친구 요청을 수락했습니다.");
      } else {
        ToastMessage.show("친구 요청을 거절했습니다.");
      }

      handleSearchUsers(searchKeyword, onlyFriend, searchUserPage, searchUserPageSize);
    } else {
      ToastMessage.show("친구 요청 응답에 실패했습니다.");
    }
  }

  void goToPage(int page) {
    if (page < 0 || page >= searchUserTotalPages) return;
    setState(() {
      searchUserPage = page;
    });
    handleSearchUsers(searchKeyword, onlyFriend, page, searchUserPageSize);
  }

  Future<void> selectSortOption() async {
    final result = await showCustomStringPicker(
      context: context,
      options: SearchUserRangeExtension.labels,
      initialValue: selectedSearchUserRange.label
    );

    if (result != null) {
      setState(() {
        selectedSearchUserRange = SearchUserRange.values.firstWhere(
          (e) => e.label == result,
          orElse: () => selectedSearchUserRange
        );

        onlyFriend = selectedSearchUserRange == SearchUserRange.FRIEND;
        searchUserPage = 0;
        isSearch = false;
        searchUsers = [];
        searchKeyword = "";
        searchKeywordController.clear();
      });
      // handleSearchUsers(searchKeyword, searchUserPageSize, searchUserPageSize);
    }
  }

  Future<bool> handleRequestFriend(FriendRequest friendRequest) async {
    final response = await apiRequest(() => requestFriend(friendRequest), context);

    if (response.statusCode == 201) {
      ToastMessage.show("친구 요청을 보냈습니다");
      handleSearchUsers(searchKeyword, onlyFriend, searchUserPage, searchUserPageSize);
      return true;
    } else {
      ToastMessage.show("친구 요청을 실패했습니다.");
      return false;
    }
  }

  void handleGetMyFriend(int page, int size) async {
    final response = await apiRequest(() => getMyFriend(page, size, false), context);

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
            friendUserPage = lastPage;
            friendUsers = [];
            friendUserTotalPages = pageResponse.totalPages;
            friendUserTotalElements = pageResponse.totalElements;
          });
          handleGetMyFriend(page, size);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        friendUsers = pageResponse.content;
        friendUserTotalPages = totalPages;
        friendUserPage = page;
        friendUserTotalElements = pageResponse.totalElements;
      });
    } else {
      log("친구 조회 실패");
    }
  }

  void handleCreateOrGetChatRoom(String targetUserId) async {
    final response = await apiRequest(() => createOrGetChatRoom(targetUserId), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String chatRoomId = data["chatRoomId"];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: chatRoomId,            
          )
        )
      );
    } else {
      ToastMessage.show("채팅방을 만들거나 찾지 못했습니다.");
    }
  }

  void handleDeleteMyFriend(String targetUserId) async {
    final response = await apiRequest(() => deleteMyFriend(targetUserId), context);

    if (response.statusCode == 204) {
      ToastMessage.show("친구가 삭제되었습니다.");
    } else {
      ToastMessage.show("친구가 삭제되지 않았습니다.");
    }

    handleGetMyFriend(friendUserPage, friendUserPageSize);
  }

  void handleBlockUser(UserInfoDTO user) async {
    final response = await apiRequest(() => blockUser(user.id), context);

    if (response.statusCode == 204) {
      ToastMessage.show("${user.nickName}이(가) 차단되었습니다.");
    } else {
      ToastMessage.show("${user.nickName}이(가) 차단되지 않았습니다.");
    }

    handleGetMyFriend(friendUserPage, friendUserPageSize);
    handleGetBlockedFriendCount();
  }

  Widget buildButton(FriendStatus friendStatus, String receiverId) {
    switch (friendStatus) {
      case FriendStatus.NOTHING:
        return IconButton(
          onPressed: () {
            handleRequestFriend(
              FriendRequest(
                receiverId: receiverId
              )
            );
          },
          icon: Icon(
            Icons.add,
            color: Colors.black
          )
        );
      case FriendStatus.REQUESTED:
        return IconButton(
          icon: Icon(
            Icons.check,
            color: Colors.green
          ),
          onPressed: null
        );
      case FriendStatus.RECEIVED:
        return Row(
          children: [
            TextButton( // 수락 버튼
              onPressed: () {
                handleResponseFriendRequest(receiverId, FriendRequestAnswerType.ACCEPT);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                )
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 24,
                  ),
                  Text(
                    "수락",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12
                    ),
                  )
                ],
              )
            ),
            TextButton( // 거절 버튼
              onPressed: () {
                handleResponseFriendRequest(receiverId, FriendRequestAnswerType.REJECT);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                )
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 24,
                  ),
                  Text(
                    "거절",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12
                    ),
                  )
                ],
              )
            )
          ],
        );
      case FriendStatus.FRIEND:
        return IconButton(
          onPressed: null,
          icon: Icon(
            Icons.favorite,
            color: Colors.red
          )
        );
      case FriendStatus.BLOCKED:
        return TextButton( // 수락 버튼
          onPressed: () {
            
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            )
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.block,
                color: Colors.red,
                size: 24,
              ),
              Text(
                "차단중",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12
                ),
              )
            ],
          )
        );
      case FriendStatus.BANED:
        return IconButton(
          onPressed: null,
          icon: Icon(
            Icons.block,
            color: Colors.red
          ),
        );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                    OutlinedButton( // 검색 범위 선택
                      onPressed: () {
                        selectSortOption();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.tableBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)
                        ),
                        side: BorderSide(
                          width: 0.5
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sort,
                            color: Colors.black,
                            size: 20,
                          ),
                          Text(
                            selectedSearchUserRange.label,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black
                            ),
                          ),
                        ],
                      )
                    ),
                    SizedBox(width: 20),
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
                                  print(searchKeywordController.text);
                                  setState(() {
                                    searchUserPage = 0;
                                  });
                                  handleSearchUsers(searchKeywordController.text, onlyFriend, searchUserPage, searchUserPageSize);
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
                                    if (isSearch) {
                                      selectedSearchUserRange = SearchUserRange.FRIEND;
                                    }
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
                          handleSearchUsers(searchKeywordController.text, onlyFriend, searchUserPage, searchUserPageSize);
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
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendManagementScreen(
                        refreshScreen: () {
                          handleGetFriendRequestCountByFriendStatus(FriendStatus.RECEIVED);
                          handleGetBlockedFriendCount();
                          handleGetMyFriend(friendUserPage, friendUserPageSize);
                        }
                      )
                    )
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "친구 관리",
                      style: TextStyle(
                        fontSize: 16
                      ),
                    ),
                    Row(
                      children: [
                        if (receivedFriendRequestCount > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.person_add
                              ),
                              Text(
                                receivedFriendRequestCount.toString()
                              ),
                            ],
                          ),
                        if (blockUserCount > 0)
                          Row(
                            children: [
                              SizedBox(width: 10),
                              Icon(
                                Icons.block
                              ),
                              Text(
                                blockUserCount.toString()
                              ),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              CustomDivider(),
              if (isSearch)
                Expanded(
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
                            "$searchKeyword에 해당하는 사용자가 없습니다."
                          ),
                        )
                      : CustomScrollView(
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
                                                                  
                                                },
                                                borderRadius: BorderRadius.circular(15),
                                                child: UserTile(
                                                  userInfoDTO: user,
                                                  profileImageSize: 45,
                                                  fontSize: 18
                                                )
                                              ),
                                            ),
                                            buildButton(user.friendStatus, user.id)
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
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: PaginationBar(
                                currentPage: searchUserPage,
                                totalPages: searchUserTotalPages,
                                window: 5,
                                onPageChanged: (p) => goToPage(p)
                              )
                            ),
                          )
                        ],
                      ),
                  ),
                )
              else // 내 친구
                Expanded(
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
                    child: friendUsers.isEmpty
                      ? Center(
                          child: Text(
                            "아직 친구가 없습니다."
                          ),
                        )
                      : CustomScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Text(
                              "친구 ${friendUserTotalElements.toString()}"
                            )
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final user = friendUsers[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(15),
                                    child: Column(
                                      children: [
                                        Slidable(
                                          key: ValueKey(user.id),
                                          startActionPane: ActionPane(
                                            motion: const DrawerMotion(),
                                            extentRatio: 0.25,
                                            children: [
                                              SlidableAction(
                                                onPressed: (context) {
                                                  handleCreateOrGetChatRoom(user.id);
                                                },
                                                backgroundColor: Colors.blue,
                                                icon: Icons.chat,
                                                label: "채팅"
                                              )
                                            ]
                                          ),
                                          endActionPane: ActionPane(
                                            motion: const DrawerMotion(),
                                            extentRatio: 0.5,
                                            children: [
                                              SlidableAction(
                                                onPressed: (context) {
                                                  handleBlockUser(user);
                                                },
                                                backgroundColor: Colors.orange,
                                                icon: Icons.block,
                                                label: "차단",
                                              ),
                                              SlidableAction(
                                                onPressed: (context) {
                                                  handleDeleteMyFriend(user.id);
                                                },
                                                backgroundColor: Colors.red,
                                                icon: Icons.delete,
                                                label: "삭제",
                                              )
                                            ]
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                                    
                                                  },
                                                  borderRadius: BorderRadius.circular(15),
                                                  child: UserTile(
                                                    userInfoDTO: user,
                                                    profileImageSize: 45,
                                                    fontSize: 18
                                                  )
                                                ),
                                              ),
                                              buildButton(user.friendStatus, user.id)
                                            ],
                                          ),
                                        ),
                                        CustomDivider()
                                      ],
                                    )
                                  )
                                );
                              },
                              childCount: friendUsers.length
                            )
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: PaginationBar(
                                currentPage: searchUserPage,
                                totalPages: searchUserTotalPages,
                                window: 5,
                                onPageChanged: (p) => goToPage(p)
                              )
                            ),
                          )
                        ],
                      ),
                  ),
                )
            ]
          )
        )
      )
    );
  }
}
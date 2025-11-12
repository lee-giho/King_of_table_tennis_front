import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/friend_api.dart';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/enum/friend_request_answer_type.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/customDivider.dart';
import 'package:king_of_table_tennis/widget/paginationBar.dart';
import 'package:king_of_table_tennis/widget/userTile.dart';

class ReceivedFriendRequestListScreen extends StatefulWidget {
  final VoidCallback refreshScreen;
  const ReceivedFriendRequestListScreen({
    super.key,
    required this.refreshScreen
  });

  @override
  State<ReceivedFriendRequestListScreen> createState() => _ReceivedFriendRequestListScreenState();
}

class _ReceivedFriendRequestListScreenState extends State<ReceivedFriendRequestListScreen> {

  int requestedUserPage = 0;
  int requestedUserPageSize = 5;
  int requestedUserTotalPages = 0;
  int requestedUserTotalElements = 0;

  List<UserInfoDTO> requestedUsers = [];

  @override
  void initState() {
    super.initState();

    handleGetReceivedFriendRequests(requestedUserPage, requestedUserPageSize);
  }

  void handleGetReceivedFriendRequests(int page, int size) async {
    final response = await apiRequest(() => getReceivedFriendRequests(page, size), context);

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
            requestedUserPage = lastPage;
            requestedUsers = [];
            requestedUserTotalPages = pageResponse.totalPages;
            requestedUserTotalElements = pageResponse.totalElements;
          });
          handleGetReceivedFriendRequests(page, size);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        requestedUsers = pageResponse.content;
        requestedUserTotalPages = totalPages;
        requestedUserPage = page;
        requestedUserTotalElements = pageResponse.totalElements;
      });
      
    } else {
      log("사용자 검색 실패");
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

      handleGetReceivedFriendRequests(requestedUserPage, requestedUserPageSize);
      widget.refreshScreen.call();
    } else {
      ToastMessage.show("친구 요청 응답에 실패했습니다.");
    }
  }

  void goToPage(int page) {
    if (page < 0 || page >= requestedUserTotalPages) return;
    setState(() {
      requestedUserPage = page;
    });
    handleGetReceivedFriendRequests(page, requestedUserPageSize);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container( // 전체 화면
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
          child: requestedUsers.isEmpty
            ? Center(
                child: Text(
                  "받은 친구 요청이 없습니다."
                ),
              )
            : CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = requestedUsers[index];
                      print(user.id);
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
                                  Row(
                                    children: [
                                      TextButton( // 수락 버튼
                                        onPressed: () {
                                          handleResponseFriendRequest(user.id, FriendRequestAnswerType.ACCEPT);
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
                                          handleResponseFriendRequest(user.id, FriendRequestAnswerType.REJECT);
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.red,
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
                                  )
                                ],
                              ),
                              CustomDivider()
                            ],
                          )
                        )
                      );
                    },
                    childCount: requestedUsers.length
                  )
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: PaginationBar(
                      currentPage: requestedUserPage,
                      totalPages: requestedUserTotalPages,
                      window: 5,
                      onPageChanged: (p) => goToPage(p)
                    )
                  ),
                )
              ],
            ),
        )
      ),
    );
  }
}
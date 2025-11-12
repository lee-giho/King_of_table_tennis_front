import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/widget/customDivider.dart';
import 'package:king_of_table_tennis/widget/paginationBar.dart';
import 'package:king_of_table_tennis/widget/userTile.dart';

class BlockedFriendListScreen extends StatefulWidget {
  const BlockedFriendListScreen({super.key});

  @override
  State<BlockedFriendListScreen> createState() => _BlockedFriendListScreenState();
}

class _BlockedFriendListScreenState extends State<BlockedFriendListScreen> {

  int blockedFriendPage = 0;
  int blockedFriendPageSize = 20;
  int blockedFriendTotalPages = 0;
  int blockedFriendTotalElements = 0;

  List<UserInfoDTO> blockedFriends = [];

  @override
  void initState() {
    super.initState();

    handleGetMyFriend(blockedFriendPage, blockedFriendPageSize);
  }

  void goToPage(int page) {
    if (page < 0 || page >= blockedFriendTotalPages) return;
    setState(() {
      blockedFriendPage = page;
    });
  }

    void handleGetMyFriend(int page, int size) async {
    final response = await apiRequest(() => getMyFriend(page, size, true), context);

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
            blockedFriendPage = lastPage;
            blockedFriends = [];
            blockedFriendTotalPages = pageResponse.totalPages;
            blockedFriendTotalElements = pageResponse.totalElements;
          });
          handleGetMyFriend(page, size);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        blockedFriends = pageResponse.content;
        blockedFriendTotalPages = totalPages;
        blockedFriendPage = page;
        blockedFriendTotalElements = pageResponse.totalElements;
      });
    } else {
      log("친구 조회 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
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
                  child: blockedFriends.isEmpty
                    ? Center(
                        child: Text(
                          "차단한 친구가 없습니다."
                        ),
                      )
                    : CustomScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final user = blockedFriends[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                  child: Column(
                                    children: [
                                      Slidable(
                                        key: ValueKey(user.id),
                                        endActionPane: ActionPane(
                                          motion: const DrawerMotion(),
                                          extentRatio: 0.5,
                                          children: [
                                            SlidableAction(
                                              onPressed: (context) {
                                                // handleBlockUser(user);
                                              },
                                              backgroundColor: Colors.green,
                                              icon: Icons.favorite,
                                              label: "차단풀기",
                                            ),
                                            SlidableAction(
                                              onPressed: (context) {
                                                // handleDeleteMyFriend(user.id);
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
                                            )
                                          ],
                                        ),
                                      ),
                                      CustomDivider()
                                    ],
                                  )
                                )
                              );
                            },
                            childCount: blockedFriends.length
                          )
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: PaginationBar(
                              currentPage: blockedFriendPage,
                              totalPages: blockedFriendTotalPages,
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
    );
  }
}
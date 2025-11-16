import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:king_of_table_tennis/api/chat_room_api.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/pre_chat_room.dart';
import 'package:king_of_table_tennis/screen/chat_screen.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/widget/customDivider.dart';
import 'package:king_of_table_tennis/widget/paginationBar.dart';
import 'package:king_of_table_tennis/widget/preChatRoomTile.dart';

class ChattingListScreen extends StatefulWidget {
  const ChattingListScreen({super.key});

  @override
  State<ChattingListScreen> createState() => _ChattingListScreenState();
}

class _ChattingListScreenState extends State<ChattingListScreen> {

  int chatRoomPage = 0;
  int chatRoomPageSize = 10;
  int chatRoomTotalPages = 0;

  List<PreChatRoom> preChatRooms = [];

  @override
  void initState() {
    super.initState();

    handleGetMyPreChatRoom(chatRoomPage, chatRoomPageSize);
  }

  void handleGetMyPreChatRoom(int page, int size) async {
    final response = await apiRequest(() => getMyPreChatRoom(page, size), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pageResponse = PageResponse<PreChatRoom>.fromJson(
        data,
        (json) => PreChatRoom.fromJson(json)
      );

      final int totalPages = pageResponse.totalPages;

      if (pageResponse.content.isEmpty && totalPages > 0 && page >= totalPages) {
        final int lastPage = totalPages - 1;
        if (lastPage != page) {
          if (!mounted) return;
          setState(() {
            chatRoomPage = lastPage;
            preChatRooms = [];
            chatRoomTotalPages = pageResponse.totalPages;
          });
          handleGetMyPreChatRoom(page, size);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        preChatRooms = pageResponse.content;
        chatRoomTotalPages = totalPages;
        chatRoomPage = page;
      });
    } else {
      log("채팅방 미리보기 가져오기 실패");
    }
  }

  void goToPage(int page) {
    if (page < 0 || page >= chatRoomTotalPages) return;
    setState(() {
      chatRoomPage = page;
    });
    handleGetMyPreChatRoom(page, chatRoomPageSize);
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
            child: preChatRooms.isEmpty
              ? Center(
                  child: Text(
                    "아직 친구가 없습니다."
                  ),
                )
              : CustomScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final preChatRoom = preChatRooms[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            child: Column(
                              children: [
                                Slidable(
                                  key: ValueKey(preChatRoom.id),
                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    extentRatio: 0.25,
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          print("나가기");
                                        },
                                        backgroundColor: Colors.red,
                                        icon: Icons.output,
                                        label: "나가기",
                                      )
                                    ]
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatScreen(
                                                  chatRoomId: preChatRoom.id,
                                                )
                                              )
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(15),
                                          child: PreChatRoomTile(
                                            preChatRoom: preChatRoom
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
                      childCount: preChatRooms.length
                    )
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: PaginationBar(
                        currentPage: chatRoomPage,
                        totalPages: chatRoomTotalPages,
                        window: 5,
                        onPageChanged: (p) => goToPage(p)
                      )
                    ),
                  )
                ],
              ),
          )
        )
      )
    );
  }
}
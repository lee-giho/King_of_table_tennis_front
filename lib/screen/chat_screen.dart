import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/api/chat_message_api.dart';
import 'package:king_of_table_tennis/api/chat_room_api.dart';
import 'package:king_of_table_tennis/model/chat_message.dart';
import 'package:king_of_table_tennis/model/chat_room_users_info.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/read_message_event.dart';
import 'package:king_of_table_tennis/model/read_message_payload.dart';
import 'package:king_of_table_tennis/model/send_message_payload.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/secure_storage.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/chatMessageBox.dart';
import 'package:king_of_table_tennis/widget/customDivider.dart';
import 'package:king_of_table_tennis/widget/profileImageCircle.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  const ChatScreen({
    super.key,
    required this.chatRoomId
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  var messageController = TextEditingController();
  FocusNode messageFocus = FocusNode();

  bool sending = false;

  bool isUserInfoReady = false;
  ChatRoomUsersInfo? chatRoomUsersInfo;

  bool isWebSocketReady = false;
  late StompClient stompClient;

  int chatMessagePage = 0;
  int chatMessagePageSize = 20;
  int chatMessageTotalPages = 0;

  List<ChatMessage> chatMessages = [];

  final ScrollController scrollController = ScrollController();

  bool isMessageLoading = false;

  int? myLastSentReadMessageId;

  @override
  void initState() {
    super.initState();

    handleGetChatRoomUsersInfo(widget.chatRoomId)
    .then((_) {
      chatConnect();
      handleGetChatMessage(widget.chatRoomId, chatMessagePage, chatMessagePageSize);
    });

    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    messageController.dispose();
    messageFocus.dispose();
    scrollController.removeListener(onScroll);
    scrollController.dispose();

    if (stompClient.connected) {
      stompClient.deactivate();
    }

    super.dispose();
  }

  bool isSameTime(DateTime a, DateTime b) {
    return a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;
  }

  Future<void> handleGetChatRoomUsersInfo(String chatRoomId) async {

    setState(() {
      isUserInfoReady = false;
    });

    final response = await apiRequest(() => getChatRoomUsersInfo(chatRoomId), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final users = ChatRoomUsersInfo.fromJson(data);

      setState(() {
        chatRoomUsersInfo = users;
        isUserInfoReady = true;
      });

    } else {
      ToastMessage.show("사용자 정보를 가져오는 중 오류가 발생했습니다.");
      Navigator.pop(context);
    }
  }

  void chatConnect() {

    setState(() {
      isWebSocketReady = false;
    });

    final wsAddress = dotenv.get("WS_ADDRESS");

    stompClient = StompClient(
      config: StompConfig(
        url: "$wsAddress/ws",
        onConnect: (StompFrame frame) {
          
          stompClient.subscribe(
            destination: "/topic/chat/room/${widget.chatRoomId}",
            callback: (frame) {
              final body = frame.body;
              if (body != null) {
                final decodedData = json.decode(body);
                
                ChatMessage receivedMsg = ChatMessage.fromJson(decodedData);

                final myId = chatRoomUsersInfo?.myInfo.id;

                if (myId != null && receivedMsg.senderId == myId) {
                  if (receivedMsg.unreadCount == 0) {
                    receivedMsg = receivedMsg.copywith(unreadCount: 1);
                  }
                }

                setState(() {
                  chatMessages.add(receivedMsg);
                });

                if (myId != null && receivedMsg.senderId != myId) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    sendReadReceiptIfNeeded();
                  });
                }
              }
            }
          );

          stompClient.subscribe(
            destination: "/topic/chat/read/${widget.chatRoomId}",
            callback: (frame) {
              final body = frame.body;
              if (body != null) {
                final decodedData = json.decode(body);
                final ReadMessageEvent readMessageEvent = ReadMessageEvent.fromJson(decodedData);

                final myId = chatRoomUsersInfo?.myInfo.id;
                if (myId == null) return;

                if (readMessageEvent.readerId != myId &&
                    readMessageEvent.lastReadMessageId != null
                ) {
                  final lastId = readMessageEvent.lastReadMessageId!;

                  setState(() {
                    chatMessages = chatMessages.map((m) {
                      if (m.senderId == myId && m.id <= lastId) {
                        return m.copywith(unreadCount: 0);
                      }
                      return m;
                    }).toList();
                  });  
                }
              }
            }
          );

          setState(() {
            isWebSocketReady = true;
          });
        },
        onWebSocketError: (err) {
          ToastMessage.show("서버와 연결이 불안정합니다.\n다시 시도해주세요");
        }
      )
    );

    stompClient.activate();
  }

  Future<void> handleGetChatMessage(String roomId, int page, int size) async {
    final response = await apiRequest(() => getMessages(roomId, page, size), context);

    if (response.statusCode == 200) {
      
      final data = json.decode(response.body);
      final pageResponse = PageResponse<ChatMessage>.fromJson(
        data,
        (json) => ChatMessage.fromJson(json)
      );

      final int totalPages = pageResponse.totalPages;

      if (pageResponse.content.isEmpty && totalPages > 0 && page >= totalPages) {
        final int lastPage = totalPages - 1;
        if (lastPage != page) {
          if (!mounted) return;
          setState(() {
            chatMessagePage = lastPage;
            chatMessages = [];
            chatMessageTotalPages = pageResponse.totalPages;
          });
          await handleGetChatMessage(roomId, lastPage, size);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        if (page == 0) {
          // 처음은 그대로
          chatMessages = pageResponse.content;
        } else {
          // 이후에는 앞에 끼워 넣기
          chatMessages.insertAll(0, pageResponse.content);
        }
        chatMessageTotalPages = totalPages;
        chatMessagePage = page;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        sendReadReceiptIfNeeded();
      });
    } else {
      log("채팅 메시지 가져오기 실패");
    }
  }

  void handleGetOlderMessages() async {
    if (isMessageLoading) return;
    if (chatMessagePage + 1 >= chatMessageTotalPages) return;

    setState(() {
      isMessageLoading = true;
    });

    final nextPage = chatMessagePage + 1;

    await handleGetChatMessage(widget.chatRoomId, nextPage, chatMessagePageSize);

    if (!mounted) return;
    setState(() {
      isMessageLoading = false;
    });
  }

  void onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    const double threshold = 100.0;

    if (!isMessageLoading &&
      chatMessagePage + 1 < chatMessageTotalPages &&
      position.pixels >= position.maxScrollExtent - threshold
    ) {
      handleGetOlderMessages();
    }
  }

  void handleSendMessage(SendMessagePayload sendMessagePayload) async {
    String? accessToken = await SecureStorage.getAccessToken();

    stompClient.send(
      destination: "/app/chat/send",
      headers: {
        'Authorization': 'Bearer $accessToken'
      },
      body: json.encode(sendMessagePayload.toJson())
    );

    setState(() {
      messageController.clear();
    });
  }

  void sendReadReceiptIfNeeded() async {
    if (!stompClient.connected) return;
    if (chatRoomUsersInfo == null) return;
    if (chatMessages.isEmpty) return;

    final myId = chatRoomUsersInfo?.myInfo.id;

    int? maxFromFriendId;
    for (final m in chatMessages) {
      if (m.senderId != myId) {
        if (maxFromFriendId == null || m.id > maxFromFriendId) {
          maxFromFriendId = m.id;
        }
      }
    }

    if (maxFromFriendId == null) return;

    // 이미 해당 ID까지 보냈으면 다시 안 보냄
    if (myLastSentReadMessageId != null && maxFromFriendId <= myLastSentReadMessageId!) return;

    myLastSentReadMessageId = maxFromFriendId;

    final ReadMessagePayload readMessagePayload = new ReadMessagePayload(
      roomId: widget.chatRoomId,
      lastReadMessageId: maxFromFriendId
    );

    String? accessToken = await SecureStorage.getAccessToken();

    stompClient.send(
      destination: "/app/chat/read",
      headers: {
        'Authorization': 'Bearer $accessToken'
      },
      body: json.encode(readMessagePayload.toJson())
    );
  }

  Future<void> handleDeleteChatRoom(String chatRoomId, String friendNickName) async {
    final response = await apiRequest(() => deleteChatRoom(chatRoomId), context);

    if (response.statusCode == 204) {
      ToastMessage.show("$friendNickName와(과)의 채팅방이 삭제되었습니다.");
    } else {
      ToastMessage.show("채팅방을 삭제하는 중 오류가 발생했습니다.\n다시 시도해주세요.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.topLeft,
          child: Text(
            chatRoomUsersInfo?.friendInfo.nickName ?? "",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            )
          )
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: Icon(
                Icons.menu
              )
            )
          )
        ],
      ),
      endDrawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Drawer(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chatRoomUsersInfo != null) ...[
                      ListTile(
                        leading: ProfileImageCircle(
                          userInfoDTO: chatRoomUsersInfo!.friendInfo,
                          profileImageSize: 40,
                        ),
                        title: Text(
                          chatRoomUsersInfo!.friendInfo.nickName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          )
                        ),
                        subtitle: Text(
                          chatRoomUsersInfo!.friendInfo.email
                        )
                      ),
                      const CustomDivider()
                    ]
                  ]
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout
                  ),
                  title: const Text(
                    "채팅방 나가기"
                  ),
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    handleDeleteChatRoom(
                      widget.chatRoomId,
                      chatRoomUsersInfo!.friendInfo.id
                    ).then((_) {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    });
                  },
                )
              ],
            )
          ),
        ),
      ),
      body: !isUserInfoReady && !isWebSocketReady
        ? Center(
          child: CircularProgressIndicator(
            color: AppColors.racketBlack,
          ),
        )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SafeArea(
                child: Container( // 전체화면
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          reverse: true,
                          itemCount: chatMessages.length,
                          itemBuilder: (context, index) {
                            final int currentIdx = chatMessages.length - 1- index;
                            final message = chatMessages[currentIdx];
                            final isMine = message.senderId == chatRoomUsersInfo?.myInfo.id;

                            // 프로필 표시 여부 계산 - 앞 메시지와 비교해 첫 번째인지 판단
                            bool showProfile = false;
                            if (!isMine) {
                              if (currentIdx == 0) {
                                // 첫 번째는 무조건 true
                                showProfile = true;
                              } else {
                                final prev = chatMessages[currentIdx - 1];
                                final prevIsMine = prev.senderId == chatRoomUsersInfo?.myInfo.id;

                                if (!prevIsMine && 
                                  prev.senderId == message.senderId &&
                                  isSameTime(prev.sentAt, message.sentAt)
                                  ) {
                                    // 이전 메시지와 같은 사람이고 같은 시간이면 프로필 숨김
                                    showProfile = false;
                                } else {
                                  showProfile = true;
                                }
                              }
                            }

                            // 시간 표시 여부 계산 - 앞 메시지와 비교해서 마지막인지 판단
                            bool showTime = false;
                            if (currentIdx == chatMessages.length - 1) {
                              // 마지막은 무조건 true
                              showTime = true;
                            } else {
                              final next = chatMessages[currentIdx + 1];
                              final nextIsSameUser = next.senderId == message.senderId;
                              final nextIsSameTime = isSameTime(next.sentAt, message.sentAt);
                              if (!nextIsSameUser || !nextIsSameTime) {
                                // 다음 메시지가 다른 사람이거나 다른 시간:분이면 true
                                showTime = true;
                              }
                            }

                            return Padding(
                              padding: showProfile && index != 0
                                ? const EdgeInsets.fromLTRB(0, 8, 0, 0)
                                : const EdgeInsets.all(0),
                              child: Row(
                                mainAxisAlignment: isMine
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isMine) ...[
                                    showProfile
                                      ? ProfileImageCircle(
                                          userInfoDTO: chatRoomUsersInfo!.friendInfo,
                                          profileImageSize: 40,
                                        )
                                      : const SizedBox(width: 40),
                                    SizedBox(width: 15)
                                  ],
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (showProfile && !isMine)
                                        Text(
                                          chatRoomUsersInfo!.friendInfo.nickName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ChatMessageBox(
                                        key: ValueKey(message.id),
                                        chatMessage: message,
                                        isMine: isMine,
                                        showTime: showTime,
                                        unreadCount: message.unreadCount,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                        )
                      )
                    ],
                  ),
              )
            )
          ),
      bottomNavigationBar: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  focusNode: messageFocus,
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                    )
                  ),
                  onSubmitted: sending
                    ? null
                    : (_) async {
                        if (messageController.text.trim().isNotEmpty) {
                          handleSendMessage(
                            SendMessagePayload(
                              roomId: widget.chatRoomId,
                              content: messageController.text
                            )
                          );
                        }
                      },
                )
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: sending
                  ? null
                  : () async {
                      if (messageController.text.trim().isNotEmpty) {
                        handleSendMessage(
                          SendMessagePayload(
                            roomId: widget.chatRoomId,
                            content: messageController.text
                          )
                        );
                      }
                    },
                icon: sending
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator()
                    )
                  : Icon(
                    Icons.send
                  )
              )
            ],
          )
        ),
      )
    );
  }
}
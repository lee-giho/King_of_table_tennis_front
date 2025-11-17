import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/api/chat_message_api.dart';
import 'package:king_of_table_tennis/api/chat_room_api.dart';
import 'package:king_of_table_tennis/model/chat_message.dart';
import 'package:king_of_table_tennis/model/chat_room_users_info.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/send_message_payload.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/secure_storage.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/chatMessageBox.dart';
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
int count = 0;
  List<ChatMessage> chatMessages = [];

  final ScrollController scrollController = ScrollController();

  bool isMessageLoading = false;

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
                
                final ChatMessage receivedMsg = ChatMessage.fromJson(decodedData);

                setState(() {
                  chatMessages.add(receivedMsg);
                });

                print(receivedMsg.content);
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
      print(++count);
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
        )
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
                            final message = chatMessages[chatMessages.length - 1 - index];
                            final isMine = message.senderId == chatRoomUsersInfo?.myInfo.id;

                            // 프로필 표시 여부 계산 - 앞 메시지와 비교해 첫 번째인지 판단
                            bool showProfile = false;
                            if (!isMine) {
                              if (index == 0) {
                                // 첫 번째는 무조건 true
                                showProfile = true;
                              } else {
                                final prev = chatMessages[index - 1];
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
                            if (index == chatMessages.length - 1) {
                              // 마지막은 무조건 true
                              showTime = true;
                            } else {
                              final next = chatMessages[index + 1];
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
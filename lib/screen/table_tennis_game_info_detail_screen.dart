import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:king_of_table_tennis/api/broadcast_api.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/enum/game_state.dart';
import 'package:king_of_table_tennis/model/broadcastRoomInfo.dart';
import 'package:king_of_table_tennis/model/game_detail_info_dto.dart';
import 'package:king_of_table_tennis/model/page_response.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';
import 'package:king_of_table_tennis/screen/broadcast_shower_screen.dart';
import 'package:king_of_table_tennis/screen/broadcast_viewer_screen.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/intl.dart';
import 'package:king_of_table_tennis/util/secure_storage.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';
import 'package:king_of_table_tennis/widget/gameInfoDetailUserTile.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class TableTennisGameInfoDetailScreen extends StatefulWidget {
  final String gameInfoId;
  final bool isMine;
  const TableTennisGameInfoDetailScreen({
    super.key,
    required this.gameInfoId,
    required this.isMine
  });

  @override
  State<TableTennisGameInfoDetailScreen> createState() => _TableTennisGameInfoDetailScreenState();
}

class _TableTennisGameInfoDetailScreenState extends State<TableTennisGameInfoDetailScreen> {

  GameDetailInfoDTO? gameDetailInfo;

  late StompClient stompClient;


  List<UserInfoDTO> applicants = [];
  int applicantPage = 0;
  int applicantPageSize = 5;
  int applicantTotalPages = 0;
  int applicantTotalElements = 0;
  bool open = false;

  @override
  void initState() {
    super.initState();

    wsConnect();
    handleGetGameDetailInfo(widget.gameInfoId);
    getApplicants(applicantPage, applicantPageSize);
  }

  @override
  void dispose() {
    stompClient.deactivate();

    super.dispose();
  }

  void handleGetGameDetailInfo(String gameInfoId) async {
    final response = await apiRequest(() => getGameDetailInfo(gameInfoId), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        gameDetailInfo = GameDetailInfoDTO.fromJson(data);
      });
      print(gameDetailInfo!.gameState.state.toKorean);
    } else {
      log("탁구장 경기 리스트 가져오기 실패");
    }
  }

  void wsConnect() {
    final wsAddress = dotenv.get("WS_ADDRESS");

    stompClient = StompClient(
      config: StompConfig(
        url: "$wsAddress/ws",
        onConnect: (StompFrame frame) {
          print("연결 성공");
          stompClient.subscribe(
            destination: "/topic/game/state/${widget.gameInfoId}",
            callback: (frame) {
              final body = frame.body;
              if (body != null) {
                final decodedData = jsonDecode(body);
                print("응답 데이터: $decodedData");
                handleGetGameDetailInfo(widget.gameInfoId);
              }
            }
          );
        }
      )
    );

    stompClient.activate();
  }

  Future<void> startBroadcast(String gameInfoId, GameState state) async {
    String? accessToken = await SecureStorage.getAccessToken();

    stompClient.send(
      destination: "/app/state",
      body: json.encode({
        "gameInfoId": gameInfoId,
        "state": state.toValue
      }),
      headers: {
        'Authorization': 'Bearer $accessToken'
      }
    );

    final response = await apiRequest(() => createBroadcastRoom(gameInfoId), context);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      BroadcastRoomInfo broadcastRoomInfo = BroadcastRoomInfo.fromJson(data);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BroadcastShowerScreen(
            broadcastRoomInfo: broadcastRoomInfo
          )
        )
      );
    } else {
      log("방송 방 만들기 실패");
    }
  }

  Future<void> enterBroadcast(String gameInfoId) async {
    String? accessToken = await SecureStorage.getAccessToken();

    final response = await apiRequest(() => enterBroadcastRoom(gameInfoId), context);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      BroadcastRoomInfo broadcastRoomInfo = BroadcastRoomInfo.fromJson(data);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BroadcastViewerScreen(
            broadcastRoomInfo: broadcastRoomInfo
          )
        )
      );
    } else {
      log("방송 방 입장 실패");
    }
  }

  Future<void> getApplicants(int page, int size) async {
    final response = await apiRequest(() => getApplicantInfo(widget.gameInfoId, page, size), context);
    print("response");
    if (response.statusCode == 200) {
      print("200");
      final data = json.decode(response.body);
      final pageResponse = PageResponse<UserInfoDTO>.fromJson(
        data,
        (json) => UserInfoDTO.fromJson(json)
      );

      setState(() {
        applicants = pageResponse.content;
        applicantTotalPages = pageResponse.totalPages;
        applicantTotalElements = pageResponse.totalElements;
      });

      print(applicants);
    }
  }

  // void onApplicantScroll() {
  //   if (appScrollctrl.position.pixels >= appScrollctrl.position.maxScrollExtent - 24) {
  //     setState(() {
  //       applicantPage++;
  //     });
  //     getApplicants(applicantPage, applicantPageSize);
  //   }
  // }

  Widget applicantTile(UserInfoDTO userInfo) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {

      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: userInfo.profileImage == "default"
                ? Container(
                    width: 40,
                    height: 40,
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
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      "${dotenv.env["API_ADDRESS"]}/image/profile/${userInfo.profileImage}"
                    )
                  )
            ),
            SizedBox(width: 15),
            Text(
              userInfo.nickName,
              style: TextStyle(
                fontSize: 16
              ),
            ),
            const Spacer(),
            Text(
              "${userInfo.winCount + userInfo.defeatCount}전 ${userInfo.winCount}승 ${userInfo.defeatCount}패"
            ),
            SizedBox(width: 15),
            const Icon(
              Icons.chevron_right,
              size: 18
            )
          ],
        ),
      ),
    );
  }

  Widget applicantSection() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(16)
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ExpansionTile(
            // 레이아웃
            tilePadding: const EdgeInsets.symmetric(horizontal: 10),
            childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),

            // 색
            textColor: Colors.black,
            iconColor: Colors.black,
            collapsedTextColor: Colors.black,
            collapsedIconColor: Colors.black,
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,

            // 모양
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),

            // 제목
            title : Text(
              "신청자: ${applicantTotalElements}명",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),

            // 아이콘을 회전 애니메이션으로 교체
            trailing: AnimatedRotation(
              duration: const Duration(milliseconds: 180),
              turns: open ? 0.5 : 0.0,
              child: const Icon(
                Icons.expand_more,
                size: 20,
              ),
            ),

            initiallyExpanded: open,
            onExpansionChanged: (v) async {
              setState(() => open = v);
              if (v) {
                applicantPage = 0;
                applicants.clear();
                await getApplicants(applicantPage, applicantPageSize);
              }
            },

            // 내용
            children: [
              ListView.builder(
                itemCount: applicants.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final applicant = applicants[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        onTap: () {
                          ToastMessage.show(applicant.nickName);
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: applicantTile(applicant),
                      ),
                    ),
                  );
                },
              ),

              // 페이지네이션 바
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (applicantPage > 0)
                      navButton("<", onTap: () => goToPage(applicantPage - 1)),
                    ...visiblePages(current: applicantPage, total: applicantTotalPages).map((p) {
                      final isActive = p == applicantPage;
                      return OutlinedButton(
                        onPressed: isActive
                          ? null
                          : () => goToPage(p),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(28, 28),
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                          side: BorderSide(
                            color: isActive
                              ? Colors.black
                              : Colors.grey
                          ),
                          backgroundColor: isActive
                            ? const Color.fromARGB(50, 30, 77, 135)
                            : null,
                          foregroundColor: isActive
                            ? Colors.white
                            : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          )
                        ),
                        child: Text(
                          "${p + 1}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal
                          ),
                        )
                      );
                    }),
                    if (applicantPage < applicantTotalPages - 1)
                      navButton(">", onTap: () => goToPage(applicantPage + 1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  void goToPage(int page) {
    if (page < 0 || page >= applicantTotalPages) return;
    setState(() {
      applicantPage = page;
    });
    getApplicants(applicantPage, applicantPageSize);
  }

  List<int> visiblePages({
    required int current,
    required int total,
    int window = 5
  }) {
    if (total <= 0) return const [];

    int start = current;
    final int remain = total - start;
    if (remain < window) {
      start = (total - window).clamp(0, total - 1);
    }
    final end = (start + window).clamp(0, total);
    return [for (int i = start; i < end; i++) i];
  }

  Widget navButton(String label, {required VoidCallback onTap}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        label == "<"
          ? Icons.arrow_back_ios
          : Icons.arrow_forward_ios,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "경기 정보"
          ),
        ),
      ),
      body: SafeArea(
        child: Container( // 전체화면
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: gameDetailInfo == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GameInfoDetailUserTile(
                                    userInfo: gameDetailInfo!.defenderInfo
                                  ),
                                  Text(
                                    "VS",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  GameInfoDetailUserTile(
                                    userInfo: gameDetailInfo!.challengerInfo
                                  )
                                ],
                              ),
                            ),
                            Column( // 경기 정보 부분
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "상세 정보",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1
                                    ),
                                    borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "경기 날짜",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                          Text(
                                            formatDateTime(gameDetailInfo!.gameInfo.gameDate),
                                            style: TextStyle(
                                              fontSize: 16
                                            )
                                          )
                                        ],
                                      ),
                                      Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "점수",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                gameDetailInfo!.gameInfo.gameScore.toString(),
                                                style: TextStyle(
                                                  fontSize: 16
                                                )
                                              ),
                                              Text(
                                                "점 ",
                                                style: TextStyle(
                                                  fontSize: 16
                                                )
                                              ),
                                              Text(
                                                gameDetailInfo!.gameInfo.gameSet.toString(),
                                                style: TextStyle(
                                                  fontSize: 16
                                                )
                                              ),
                                              Text(
                                                "세트",
                                                style: TextStyle(
                                                  fontSize: 16
                                                )
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "수락 타입",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                          Text(
                                            gameDetailInfo!.gameInfo.acceptanceType == "FCFS"
                                            ? "선착순"
                                            : "선택",
                                            style: TextStyle(
                                              fontSize: 16
                                            )
                                          )
                                        ],
                                      ),
                                      Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "경기 상태",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                          Text(
                                            gameDetailInfo!.gameState.state.toKorean,
                                            style: TextStyle(
                                              fontSize: 16
                                            )
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            if (widget.isMine)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "경기 신청자",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                    applicantSection(),
                                  ],
                                ),
                              )
                          ],
                        ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: gameDetailInfo!.gameState.state == GameState.WAITING && gameDetailInfo!.gameInfo.gameDate.isAfter(DateTime.now()) && widget.isMine
                      ? () {
                          startBroadcast(widget.gameInfoId, GameState.DOING);
                        }
                      : gameDetailInfo!.gameState.state == GameState.DOING
                        ? () {
                            enterBroadcast(widget.gameInfoId);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: AppColors.racketRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                        )
                      ),
                    child: Text(
                      gameDetailInfo!.gameState.state == GameState.WAITING && gameDetailInfo!.gameInfo.gameDate.isAfter(DateTime.now()) && widget.isMine
                        ? "방송 시작"
                        : gameDetailInfo!.gameState.state == GameState.DOING && !widget.isMine
                          ? "방송 보기"
                          : gameDetailInfo!.gameState.state.toKorean,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  )
                ],
            )
        )
      ),
    );
  }
}
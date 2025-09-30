import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/game_api.dart';
import 'package:king_of_table_tennis/model/game_registration_dto.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/intl.dart';
import 'package:king_of_table_tennis/widget/customDateTimePicker.dart';
import 'package:king_of_table_tennis/widget/customNumberPicker.dart';
import 'package:king_of_table_tennis/widget/customStringPicker.dart';

class GameRegistrationScreen extends StatefulWidget {
  final String tableTennisCourtId;
  final String tableTennisCourtName;
  final VoidCallback onApplyComplete;
  const GameRegistrationScreen({
    super.key,
    required this.tableTennisCourtId,
    required this.tableTennisCourtName,
    required this.onApplyComplete
  });

  @override
  State<GameRegistrationScreen> createState() => _GameRegistrationScreenState();
}

class _GameRegistrationScreenState extends State<GameRegistrationScreen> {

  DateTime now = DateTime.now();
  late DateTime selectDate;
  List<DateTime> selectedGameDate = [];

  late int selectGameSet;
  List<int> gameSet = [3, 5];

  late int selectGameScore;
  List<int> gameScore = [11, 21];

  late String selectPlace;

  late String selectAcceptanceType;
  List<String> acceptanceType = ["선착순", "직접 선택"];
  final Map<String, String> acceptanceTypeMap = {
    "선착순": "FCFS",
    "직접 선택": "SELECT"
  };

  @override
  void initState() {
    super.initState();

    setState(() {
      selectPlace = widget.tableTennisCourtId;
      selectDate = DateTime(now.year, now.month, now.day, now.hour+1);
      selectGameSet = gameSet[0];
      selectGameScore = gameScore[0];
      selectAcceptanceType = acceptanceType[0];
    });

    handleGetBlackListDateTime(widget.tableTennisCourtId);
  }

  void handleGetBlackListDateTime(String tableTennisCourtId) async {
    final response = await apiRequest(() => getBlackListDateTime(tableTennisCourtId), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final selectedGameDateList = data["selectedGameDateList"];
      
      setState(() {
        selectedGameDate = (selectedGameDateList as List)
        .map<DateTime>((item) => DateTime.parse(item as String))
        .toList();
      });

    } else {
      log("선택 불가능한 날짜 가져오기 실패: ${response.body}");
    }
  }

  void handleCreateGame(GameRegistrationDTO gameRegistrationDTO) async {
    final response = await apiRequest(() => createGame(gameRegistrationDTO), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      bool success = data["success"];

      if (success) {
        log("탁구 경기 등록 성공");
        ScaffoldMessenger.of(context) .showSnackBar(
          SnackBar(content: Text("탁구 경기 등록 성공"))
        );
        widget.onApplyComplete.call();
        Navigator.pop(context);
      } else {
        log("탁구 경기 등록 실패");  
      }
    } else {
      log("탁구 경기 등록 실패: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "탁구 경기 생성",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container( // 전체화면
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Text(
                            "장소",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.tableTennisCourtName,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 30),
                      Column(
                        children: [
                          Text(
                            "날짜 선택",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () async {
                              final DateTime? picked = await showCustomDateTimePicker(
                                context: context,
                                selectDate: selectDate,
                                blackList: selectedGameDate
                              );
                      
                              if (picked != null) {
                                setState(() {
                                  selectDate = picked;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              side: BorderSide(
                                width: 0.2,
                                color: Colors.black
                              ),
                              foregroundColor: AppColors.tableBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                              )
                            ),
                            child: Text(
                              formatDateTime(selectDate),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black
                              ),
                            )
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Column(
                        children: [
                          Text(
                            "경기 설정",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row( // 세트 설정
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final int? picked = await showCustomNumberPicker(
                                        context: context,
                                        options: gameSet,
                                        initialValue: selectGameSet
                                      );
                                                    
                                      if (picked != null) {
                                        setState(() {
                                          selectGameSet = picked;
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 4,
                                      side: BorderSide(
                                        width: 0.2,
                                        color: Colors.black
                                      ),
                                      foregroundColor: AppColors.tableBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      )
                                    ),
                                    child: Text(
                                      selectGameSet.toString(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black
                                      ),
                                    )
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "세트",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),
                                  )
                                ],
                              ),
                              Row( // 점수 설정
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final int? picked = await showCustomNumberPicker(
                                        context: context,
                                        options: gameScore,
                                        initialValue: selectGameScore
                                      );
                                                    
                                      if (picked != null) {
                                        setState(() {
                                          selectGameScore = picked;
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 4,
                                      side: BorderSide(
                                        width: 0.2,
                                        color: Colors.black
                                      ),
                                      foregroundColor: AppColors.tableBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      )
                                    ),
                                    child: Text(
                                      selectGameScore.toString(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black
                                      ),
                                    )
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "점",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 30),
                      Column(
                        children: [
                          Text(
                            "게임 수락 설정",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () async {
                              final String? picked = await showCustomStringPicker(
                                context: context,
                                options: acceptanceType,
                                initialValue: selectAcceptanceType
                              );
                      
                              if (picked != null) {
                                setState(() {
                                  selectAcceptanceType = picked;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              side: BorderSide(
                                width: 0.2,
                                color: Colors.black
                              ),
                              foregroundColor: AppColors.tableBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                              )
                            ),
                            child: Text(
                              selectAcceptanceType,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black
                              ),
                            )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  handleCreateGame(
                    GameRegistrationDTO(
                      gameSet: selectGameSet,
                      gameScore: selectGameScore,
                      place: selectPlace,
                      acceptanceType: acceptanceTypeMap[selectAcceptanceType]!,
                      gameDate: selectDate
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: BorderSide(
                    width: 0.2,
                    color: Colors.black
                  ),
                  backgroundColor: AppColors.racketRed,
                  foregroundColor: AppColors.tableBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                  )
                ),
                child: const Text(
                  "등록하기",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                )
              )
            ],
          ),
        )
      ),
    );
  }
}
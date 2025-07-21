import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/profile_registration_api.dart';
import 'package:king_of_table_tennis/model/profile_registration_dto.dart';
import 'package:king_of_table_tennis/model/table_tennis_info_registration_dto.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';

class TableTennisInfoRegistrationScreen extends StatefulWidget {
  final ProfileRegistrationDTO profileRegistrationDTO;
  const TableTennisInfoRegistrationScreen({
    super.key,
    required this.profileRegistrationDTO
  });

  @override
  State<TableTennisInfoRegistrationScreen> createState() => _TableTennisInfoRegistrationScreenState();
}

class _TableTennisInfoRegistrationScreenState extends State<TableTennisInfoRegistrationScreen> {

  int? selectedRacketType;
  int? selectedLevel;

  final Map<int, String> racketType = {
    0: "펜홀더",
    1: "쉐이크"
  };

  final Map<int, String> levelType = {
    0: "초급",
    1: "중급",
    2: "고급"
  };

  // 실력 값 저장
  var levelController = TextEditingController();

  Widget buildRacketTypeContainer({required int value, required String label}) {
    final isSelected = selectedRacketType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRacketType = value;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                  ? AppColors.racketRed
                  : Colors.transparent,
                  width: 2
              )
            ),
            margin: EdgeInsets.all(8),
            child: ColorFiltered(
              colorFilter: isSelected
              ? ColorFilter.mode(
                  Colors.transparent,
                  BlendMode.multiply
                )
              : ColorFilter.mode(
                  const Color.fromARGB(255, 106, 106, 106),
                  BlendMode.modulate
                ),
              child: Image.asset(
                "assets/images/logo.png",
                fit: BoxFit.cover,
              )
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 20
            ),
          )
        ],
      ),
    );
  }

  Widget buildLevelContainer({required int value, required String label}) {
    final isSelected = selectedLevel == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevel = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
             ? Colors.black
             : Colors.grey,
            width: 1
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 25,
              color: isSelected
                ? Colors.black
                : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  void handleProfileRegistration(ProfileRegistrationDTO profileRegistrationDTO) async {
    final response = await apiRequest(() => saveProfileImageAndNickName(profileRegistrationDTO), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      bool success = data["success"];

      if (success) {
        log("프로필 사진, 닉네임 등록 완료");
      } else {
        log("프로필 사진, 닉네임 등록 실패");  
      }
    } else {
      log("프로필 사진, 닉네임 등록 실패: ${response.body}");
    }
  }

  void handleTableTennisInfoRegistration(TableTennisInfoRegistrationDTO tableTennisInfoRegistrationDTO) async {
    final response = await apiRequest(() => saveTableTennisInfo(tableTennisInfoRegistrationDTO), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      bool success = data["success"];

      if (success) {
        log("탁구 정보 등록 완료");
      } else {
        log("탁구 정보 등록 실패");  
      }
    } else {
      log("탁구 정보 등록 실패: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("data: ${widget.profileRegistrationDTO.profileImage}");
    print("data: ${widget.profileRegistrationDTO.nickName}");
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "탁구 타입 설정",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: SafeArea(
        child: Container( // 전체 화면
          padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "라켓 선택",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(5),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: racketType.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.7
                              ),
                              itemBuilder: (context, index) {
                                final entry = racketType.entries.elementAt(index);
                                return buildRacketTypeContainer(
                                  value: entry.key,
                                  label: entry.value
                                );
                              }
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "실력 선택",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: levelType.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 5
                            ),
                            itemBuilder: (context, index) {
                              final entry = levelType.entries.elementAt(index);
                              return buildLevelContainer(
                                value: entry.key,
                                label: entry.value
                              );
                            }
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container( // 시작하기 버튼
                child: ElevatedButton(
                  onPressed: selectedRacketType != null && selectedLevel != null
                    ? () { 
                        handleProfileRegistration(widget.profileRegistrationDTO);
                        
                        TableTennisInfoRegistrationDTO tableTennisInfoRegistrationDTO = TableTennisInfoRegistrationDTO(
                          racketType: racketType[selectedRacketType]!,
                          userLevel: levelType[selectedLevel]!
                        );
                        handleTableTennisInfoRegistration(
                          tableTennisInfoRegistrationDTO
                        );
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
                  child: const Text(
                    "시작하기",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
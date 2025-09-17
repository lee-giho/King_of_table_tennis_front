import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';

class ChangeRacketTypeScreen extends StatefulWidget {
  final String racketType;
  final VoidCallback fetchMyInfo;
  const ChangeRacketTypeScreen({
    super.key,
    required this.racketType,
    required this.fetchMyInfo
  });

  @override
  State<ChangeRacketTypeScreen> createState() => _ChangeRacketTypeScreenState();
}

class _ChangeRacketTypeScreenState extends State<ChangeRacketTypeScreen> {

  @override
  void initState() {
    super.initState();

    selectedRacketType = racketTypeReverse[widget.racketType];
  }

  int? selectedRacketType;

  final Map<int, String> racketType = {
    0: "펜홀더",
    1: "쉐이크"
  };

  final Map<String, int> racketTypeReverse = {
    "펜홀더": 0,
    "쉐이크": 1
  };

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

  void handleSubmit(String newRacketType) async {
    final response = await apiRequest(() => changeUserInfo("racketType", newRacketType), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final isSuccess = data["success"];
      print("isSuccess: $isSuccess");
      if (isSuccess) {
        ToastMessage.show("라켓 타입이 변경되었습니다.");
        widget.fetchMyInfo.call();
        Navigator.pop(context);
      } else {
        ToastMessage.show("라켓 타입 변경을 실패했습니다.");
        log("라켓 타입 변경 실패 - isSuccess: $isSuccess");
      }
    } else {
      log("라켓 타입 변경 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "라켓 타입 변경",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: Container(
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
                  ),
                )
              ),
              Container( // 변경하기 버튼
                child: ElevatedButton(
                  onPressed: widget.racketType != racketType[selectedRacketType]
                    ? () {
                        handleSubmit(racketType[selectedRacketType]!);
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
                    "변경하기",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
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
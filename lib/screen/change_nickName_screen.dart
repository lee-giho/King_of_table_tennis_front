import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/profile_registration_api.dart';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/checkValidate.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';

class ChangeNickNameScreen extends StatefulWidget {
  final VoidCallback fetchMyInfo;
  const ChangeNickNameScreen({
    super.key,
    required this.fetchMyInfo
  });

  @override
  State<ChangeNickNameScreen> createState() => _ChangeNickNameScreenState();
}

class _ChangeNickNameScreenState extends State<ChangeNickNameScreen> {

  // 닉네임 입력 값 저장
  var nickNameController = TextEditingController();

  // 닉네임 FocusNode
  FocusNode nicKNameFocus = FocusNode();

  // 상태값
  bool isNickNameValid = false;

  // 닉네임 중복확인 여부
  bool isNickNameDuplication = true;

  // 닉네임 변경 여부
  bool isNickNameChanged = false;

  // 닉네임 입력 검증
  bool nickNameInputValid = false;

  void handleCheckNickNameDuplication(String nickName) async {
    final response = await apiRequest(() => checkNickNameDuplication(nickName), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final exists = data["exists"];

      if (!exists) {
        setState(() {
          isNickNameDuplication = exists;
        });
      }
      setState(() {
        isNickNameChanged = false;
      });

      print(data);
    } else {
      log("닉네임 중복확인 실패");
    }
  }

  void handleSubmit(String nickName) async {
    final response = await apiRequest(() => changeNickName(nickName), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final isSuccess = data["success"];
      print("isSuccess: $isSuccess");
      if (isSuccess) {
        ToastMessage.show("닉네임이 변경되었습니다.");
        widget.fetchMyInfo.call();
        Navigator.pop(context);
      } else {
        log("닉네임 변경 실패 - isSuccess: $isSuccess");
      }
    } else {
      log("닉네임 변경 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "닉네임 변경",
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
                    child: Container( // 닉네임 입력 부분
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: nickNameController,
                              focusNode: nicKNameFocus,
                              keyboardType: TextInputType.text,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                return Checkvalidate().validateNickName(value, isNickNameDuplication, isNickNameChanged);
                              },
                              onChanged: (value) {
                                setState(() {
                                  nickNameInputValid = Checkvalidate().checkNickNameInput(value);
                                  isNickNameChanged = true;
                                });
                      
                                isNickNameValid = Checkvalidate().validateNickName(value, isNickNameDuplication, isNickNameChanged) == null;
                                isNickNameDuplication = true; // 값이 변경되면 중복확인 필요
                              },
                              decoration: const InputDecoration(
                                hintText: "변경할 닉네임을 입력해주세요."
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: nickNameInputValid && isNickNameDuplication
                              ? () {
                                  handleCheckNickNameDuplication(nickNameController.text);
                                }
                              : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(100, 50),
                              backgroundColor: AppColors.racketRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                              )
                            ),
                            child: Text(
                              "중복확인",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                              ),
                            )
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container( // 변경하기 버튼
                child: ElevatedButton(
                  onPressed: !isNickNameDuplication
                    ? () {
                        handleSubmit(nickNameController.text);
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
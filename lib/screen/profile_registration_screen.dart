import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/profile_registration_api.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/checkValidate.dart';

class ProfileRegistrationScreen extends StatefulWidget {
  const ProfileRegistrationScreen({super.key});

  @override
  State<ProfileRegistrationScreen> createState() => _ProfileRegistrationScreenState();
}

class _ProfileRegistrationScreenState extends State<ProfileRegistrationScreen> {

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

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nickNameController.dispose();
    
    nicKNameFocus.dispose();

    super.dispose();
  }

  void handleCheckNickNameDuplication(String nickName) async {
    final response = await checkNickNameDuplication(nickName);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "프로필 설정",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Container( // 전체 화면
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container( // 닉네임 입력 부분
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "닉네임 *",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              Row(
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
                                        hintText: "닉네임을 입력해주세요."
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
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ),
                Container( // 회원가입 버튼
                  child: ElevatedButton(
                    onPressed: isNickNameValid
                      ? () {
                          print("다음 클릭!!!");
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
                      "다음",
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
        )
      ),
    );
  }
}
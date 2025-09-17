import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/user_api.dart';
import 'package:king_of_table_tennis/util/apiRequest.dart';
import 'package:king_of_table_tennis/util/appColors.dart';
import 'package:king_of_table_tennis/util/checkValidate.dart';
import 'package:king_of_table_tennis/util/toastMessage.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  bool isVerifyPassword = false;

  var currentPasswordController = TextEditingController();
  var passwordController = TextEditingController();
  var rePasswordController = TextEditingController();

  FocusNode currentPasswordFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode rePasswordFocus = FocusNode();

  bool isPasswordValid = false;
  bool isRePasswordValid = false;

  // 입력 상태 체크 함수
  void checkFormValid() {
    setState(() {
      isPasswordValid = Checkvalidate().validatePassword(passwordController.text) == null;
      isRePasswordValid = Checkvalidate().validateRePassword(passwordController.text, rePasswordController.text) == null;
    });
  }

  void handleVerifyPassword(String password) async {
    final response = await apiRequest(() => verifyPassword(password), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final isSuccess = data["success"];
      print("isSuccess: $isSuccess");
      if (isSuccess) {
        setState(() {
          isVerifyPassword = true;
        });
      } else {
        ToastMessage.show("비밀번호가 일치하지 않습니다.");
        log("비밀번호가 일치하지 않음 - isSuccess: $isSuccess");
      }
    } else {
      log("비밀번호 확인 실패");
    }
  }

  void handleSubmit(String newPassword) async {
    final response = await apiRequest(() => changeUserInfo("password", newPassword), context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final isSuccess = data["success"];
      print("isSuccess: $isSuccess");
      if (isSuccess) {
        setState(() {
          ToastMessage.show("비밀번호가 변경되었습니다.");
          Navigator.pop(context);
        });
      } else {
        ToastMessage.show("비밀번호 변경을 실패했습니다.");
        log("비밀번호 변경 실패 - isSuccess: $isSuccess");
      }
    } else {
      log("비밀번호 변경 실패");
    }
  }
  
  Widget buildVerifyPassword() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "현재 비밀번호를 입력해주세요.",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          TextFormField(
            controller: currentPasswordController,
            focusNode: currentPasswordFocus,
            obscureText: true,
            autovalidateMode: AutovalidateMode.onUnfocus,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "비밀번호를 입력해주세요.";
              } else {
                return null;
              }
            },
            onChanged: (value) {
              setState(() {});
            },
            decoration: const InputDecoration(
              hintText: "비밀번호를 입력해주세요."
            ),
          )
        ],
      ),
    );
  }

  Widget buildChangePassword() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "비밀번호 *",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              TextFormField(
                controller: passwordController,
                focusNode: passwordFocus,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (currentPasswordController.text == passwordController.text) {
                    return "기존 비밀번호와 동일합니다.";
                  } else {
                    return Checkvalidate().validatePassword(value);
                  }
                },
                onChanged: (value) {
                  checkFormValid();
                  if (currentPasswordController.text == passwordController.text) {
                    setState(() {
                      isPasswordValid = false;
                    });
                  }
                },
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "비밀번호를 입력해주세요."
                ),
              )
            ],
          ),
        ),
        Container( // 비밀번호 확인 입력 부분
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "비밀번호 확인 *",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              TextFormField(
                controller: rePasswordController,
                focusNode: rePasswordFocus,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (currentPasswordController.text == rePasswordController.text) {
                    if (passwordController.text == rePasswordController.text){
                      return "기존 비밀번호와 동일합니다.";
                    } else {
                      return Checkvalidate().validateRePassword(passwordController.text, value);  
                    }
                  } else {
                    return Checkvalidate().validateRePassword(passwordController.text, value);
                  }
                },
                onChanged: (value) {
                  checkFormValid();
                  if (currentPasswordController.text == rePasswordController.text) {
                    setState(() {
                      isRePasswordValid = false;
                    });
                  }
                },
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "비밀번호를 한 번 더 입력해주세요."
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "비밀번호 변경",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                      child: !isVerifyPassword
                        ? buildVerifyPassword()
                        : buildChangePassword()
                    ),
                  )
                ),
                Container( // 변경하기 버튼
                  child: ElevatedButton(
                    onPressed: (!isVerifyPassword && currentPasswordController.value.text.isNotEmpty) || (isVerifyPassword && isPasswordValid && isRePasswordValid)
                      ? () {
                          if (!isVerifyPassword) {
                            handleVerifyPassword(currentPasswordController.text);
                          } else {
                            handleSubmit(passwordController.text);
                          }
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
                      !isVerifyPassword
                        ? "비밀번호 확인"
                        : "변경하기",
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
      ),
    );
  }
}
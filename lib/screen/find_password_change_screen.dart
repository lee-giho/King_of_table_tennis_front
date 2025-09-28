import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/find_password_change_api.dart';
import 'package:king_of_table_tennis/model/change_password_dto.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/checkValidate.dart';

class FindPasswordChangeScreen extends StatefulWidget {
  final ChangePasswordDTO changePasswordDTO;
  const FindPasswordChangeScreen({
    super.key,
    required this.changePasswordDTO
  });

  @override
  State<FindPasswordChangeScreen> createState() => _FindPasswordChangeScreenState();
}

class _FindPasswordChangeScreenState extends State<FindPasswordChangeScreen> {

  // 비밀번호, 비밀번호 확인 입력 값 저장
  var passwordController = TextEditingController();
  var rePasswordController = TextEditingController();

  // 비밀번호, 비밀번호 확인 FocusNode
  FocusNode passwordFocus = FocusNode();
  FocusNode rePasswordFocus = FocusNode();

  // 비밀번호 유효성 상태
  bool isPasswordValid = false;

  // 비밀번호 확인 유효성 상태
  bool isRePasswordValid = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    passwordController.dispose();
    rePasswordController.dispose();

    passwordFocus.dispose();
    rePasswordFocus.dispose();

    super.dispose();
  }

  // 입력 상태 체크 함수
  void checkFormValid() {
    setState(() {
      isPasswordValid = Checkvalidate().validatePassword(passwordController.text) == null;
      isRePasswordValid = Checkvalidate().validateRePassword(passwordController.text, rePasswordController.text) == null;
    });
  }

  void handleChangePassword(ChangePasswordDTO changePasswordDTO) async {
    final response = await findPasswordChange(changePasswordDTO);

    if (response.statusCode == 200) {
      log(response.body);
      Navigator.pop(context); // 현재 화면(find_password_change_screen) pop
      Navigator.pop(context); // 이전 화면(find_password_screen) pop
    } else {
      log(response.body);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${response.body}"))
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
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Container( // 전체 화면
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Container( // 아이디, 비밀번호, 비밀번호 확인, 이름 입력 부분
                      child: Column(
                        children: [
                          Container( // 비밀번호 입력 부분
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "새 비밀번호 *",
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
                                    return Checkvalidate().validatePassword(value);
                                  },
                                  onChanged: (value) {
                                    checkFormValid();
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
                                    return Checkvalidate().validateRePassword(passwordController.text, value);
                                  },
                                  onChanged: (value) {
                                    checkFormValid();
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
                      ),
                    ),
                  )
                ),
                Container( // 회원가입 버튼
                  child: ElevatedButton(
                    onPressed: (formKey.currentState?.validate() ?? false) && isPasswordValid && isRePasswordValid
                      ? () {
                          final changePasswordDTO = widget.changePasswordDTO.copyWith(password: passwordController.text);
                          handleChangePassword(changePasswordDTO);
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
                      "비밀번호 변경",
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
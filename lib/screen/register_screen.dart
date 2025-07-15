import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/register_api.dart';
import 'package:king_of_table_tennis/model/register_dto.dart';
import 'package:king_of_table_tennis/screen/register_email_screen.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/checkValidate.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // 아이디, 비밀번호, 비밀번호 확인, 이름 입력 값 저장
  var idController = TextEditingController();
  var passwordController = TextEditingController();
  var rePasswordController = TextEditingController();
  var nameController = TextEditingController();

  // 아이디, 비밀번호, 비밀번호 확인, 이름 FocusNode
  FocusNode idFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode rePasswordFocus = FocusNode();
  FocusNode nameFocus = FocusNode();

  // 상태값
  bool isIdValid = false;
  bool isPasswordValid = false;
  bool isRePasswordValid = false;
  bool isNameValid = false;

  // 아이디 중복확인 여부
  bool isIdDuplication = true;

  // 아이디 변경 여부
  bool isIdChanged = false;

  // 아이디 입력 검증
  bool idInputValid = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();
    nameController.dispose();

    idFocus.dispose();
    passwordFocus.dispose();
    rePasswordFocus.dispose();
    nameFocus.dispose();

    super.dispose();
  }

  // 입력 상태 체크 함수
  void checkFormValid() {
    setState(() {
      isIdValid = Checkvalidate().validateId(idController.text, isIdDuplication, isIdChanged) == null;
      isPasswordValid = Checkvalidate().validatePassword(passwordController.text) == null;
      isRePasswordValid = Checkvalidate().validateRePassword(passwordController.text, rePasswordController.text) == null;
      isNameValid = Checkvalidate().validateName(nameController.text) == null;
    });
  }

  // 회원가입 버튼 활성화 조건
  bool get isFormValid {
    return isIdValid && isPasswordValid && isRePasswordValid && isNameValid && !isIdDuplication;
  }

  void handleCheckIdDuplication(String id) async {
    final response = await checkIdDuplication(id);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final exists = data["exists"];

      if (!exists) {
        setState(() {
          isIdDuplication = exists;
        });
      }
      setState(() {
        isIdChanged = false;
      });
      
      print(data);
    } else {
      log("아이디 중복확인 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "회원가입",
          style: TextStyle(
            fontWeight: FontWeight.bold
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container( // 페이지 타이틀
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                              child: Center(
                                child: const Text(
                                  "회원 정보 입력",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
                            ),
                            Container( // 아이디, 비밀번호, 비밀번호 확인, 이름 입력 부분
                              child: Column(
                                children: [
                                  Container( // 아이디 입력 부분
                                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "아이디 *",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: idController,
                                                focusNode: idFocus,
                                                keyboardType: TextInputType.text,
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                validator: (value) {
                                                  return Checkvalidate().validateId(value, isIdDuplication, isIdChanged);
                                                },
                                                onChanged: (value) {
                                                  setState(() {
                                                    idInputValid = Checkvalidate().checkIdInput(value);
                                                    isIdChanged = true;
                                                  });
                                              
                                                  isIdValid = Checkvalidate().validateId(value, isIdDuplication, isIdChanged) == null;
                                                  isIdDuplication = true; // 값이 변경되면 중복확인 필요
                                                },
                                                decoration: const InputDecoration(
                                                  hintText: "아이디를 입력해주세요."
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: idInputValid
                                                ? () {
                                                    handleCheckIdDuplication(idController.text);
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
                                              child: const Text(
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
                                  Container( // 비밀번호 입력 부분
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
                                  Container( // 이름 입력 부분
                                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "이름 *",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        TextFormField(
                                          controller: nameController,
                                          focusNode: nameFocus,
                                          keyboardType: TextInputType.text,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          validator: (value) {
                                            return Checkvalidate().validateName(value);
                                          },
                                          onChanged: (value) {
                                            checkFormValid();
                                          },
                                          decoration: const InputDecoration(
                                            hintText: "이름을 입력해주세요."
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ),
                Container( // 회원가입 버튼
                  child: ElevatedButton(
                    onPressed: isFormValid
                      ? () {
                          // signUp();
                          print("회원가입 버튼 클릭!!");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterEmailScreen(
                                registerDTO: RegisterDTO(
                                  id: idController.text,
                                  password: passwordController.text,
                                  name: nameController.text,
                                  nickName: "",
                                  email: "",
                                  profileImage: ""
                                )
                              )
                            )
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
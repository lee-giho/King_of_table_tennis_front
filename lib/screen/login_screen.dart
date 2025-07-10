import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/util/appColors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // 자동 로그인 여부
  bool? isAutoLogin = false;

  // 아이디 & 비밀번호 입력 값 저장
  var idController = TextEditingController();
  var passwordController = TextEditingController();

  // 아이디 & 비밀번호 포커스
  FocusNode idFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    idFocus.dispose();
    passwordFocus.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // 포커스 해제
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              children: [
                Container( // 로고
                  margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                      Text(
                        "우 리 동 네",
                        style: TextStyle(
                          fontSize: 18
                        ),
                      ),
                      Text(
                        "탁구왕",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                ),
                Container( // 로그인폼
                  child: Column(
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Container( // 아이디 입력 부분
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "아이디",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  TextFormField(
                                    controller: idController,
                                    focusNode: idFocus,
                                    keyboardType: TextInputType.text,
                                    autovalidateMode: AutovalidateMode.onUnfocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "아이디를 입력해주세요.";
                                      } else {
                                        return null;
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: "아이디를 입력해주세요.",
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5)
                                        ),
                                        borderSide: BorderSide(
                                          color: Appcolors.racketBlack
                                        )
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5)
                                        ),
                                        borderSide: BorderSide(
                                          color: Appcolors.racketRed
                                        )
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5)
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.red
                                        )
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5)
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.red
                                        )
                                      )
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container( // 비밀번호 입력 부분
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "비밀번호",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  TextFormField(
                                    controller: passwordController,
                                    focusNode: passwordFocus,
                                    keyboardType: TextInputType.text,
                                    obscureText: true,
                                    autovalidateMode: AutovalidateMode.onUnfocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "비밀번호를 입력해주세요.";
                                      } else {
                                        return null;
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: "비밀번호를 입력해주세요.",
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5)
                                        ),
                                        borderSide: BorderSide(
                                          color: Appcolors.racketBlack
                                        )
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5)
                                        ),
                                        borderSide: BorderSide(
                                          color: Appcolors.racketRed
                                        )
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5)
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.red
                                        )
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5)
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.red
                                        )
                                      )
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ),
                      Container( // 자동 로그인 & 로그인 버튼 부분
                        child: Column(
                          children: [
                            Container( // 로그인 상태 유지 체크박스 부분
                              child: Row(
                                children: [
                                  Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)
                                    ),
                                    value: isAutoLogin,
                                    onChanged: (value) {
                                      setState(() {
                                        isAutoLogin = value;
                                      });
                                    }
                                  ),
                                  const Text(
                                    "로그인 상태 유지",
                                    style: TextStyle(
                                      fontSize: 18
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container( // 로그인 버튼 부분
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              print("로그인 버튼 클릭!!");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: Appcolors.racketRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                            )
                          ),
                          child: const Text(
                            "로그인",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          )
                        ),
                      ),
                      Row( // 아이디 찾기 & 비밀번호 찾기 & 회원가입 버튼 부분
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: () {
                              print("아이디 찾기 클릭!!");
                            },
                            child: Text(
                              "아이디 찾기",
                              style: TextStyle(
                                color: Colors.grey[800]
                              ),
                            )
                          ),
                          const Text("|"),
                          TextButton(
                            onPressed: () {
                              print("비밀번호 찾기 클릭!!");
                            },
                            child: Text(
                              "비밀번호 찾기",
                              style: TextStyle(
                                color: Colors.grey[800]
                              ),
                            )
                          ),
                          const Text("|"),
                          TextButton(
                            onPressed: () {
                              print("회원가입 클릭!!");
                            },
                            child: Text(
                              "회원가입",
                              style: TextStyle(
                                color: Colors.grey[800]
                              ),
                            )
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ),
      )
    );
  }
}
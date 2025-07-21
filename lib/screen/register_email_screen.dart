import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/api/register_api.dart';
import 'package:king_of_table_tennis/api/email_api.dart';
import 'package:king_of_table_tennis/enum/email_type.dart';
import 'package:king_of_table_tennis/model/register_dto.dart';
import 'package:king_of_table_tennis/util/AppColors.dart';
import 'package:king_of_table_tennis/util/checkValidate.dart';

class RegisterEmailScreen extends StatefulWidget {
  final RegisterDTO registerDTO;
  const RegisterEmailScreen({
    super.key,
    required this.registerDTO
  });

  @override
  State<RegisterEmailScreen> createState() => _RegisterEmailScreenState();
}

class _RegisterEmailScreenState extends State<RegisterEmailScreen> {

  // 이메일, 인증번호 입력 값 저장
  var emailController = TextEditingController();
  var codeController = TextEditingController();

  // 이메일, 인증번호 FocusNode
  FocusNode emailFocus = FocusNode();
  FocusNode codeFocus = FocusNode();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 이메일 입력 유효성 상태
  bool isEmailValid = false;

  // 인증번호 입력 유효성 상태
  bool isCodeValid = false;

  // 인증번호 전송 상태
  bool isCodeSent = false;

  // 인증번호 확인 상태
  bool isCodeCheck = false;

  final emailApi = RegisterEmailApi();
  String emailSessionId = "";

  // 타이머 시간
  int remainingTime = 180;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();

    emailController.dispose();
    codeController.dispose();

    emailFocus.dispose();
    codeFocus.dispose();
    
    super.dispose();
  }

  void checkFormValid() {
    setState(() {
      isEmailValid = Checkvalidate().validateEmail(emailController.text) == null;
      isCodeValid = Checkvalidate().validateCode(codeController.text) == null && (remainingTime > 0 && remainingTime < 180);
    });
  }

  // 타이머 시작 함수
  void startTimer() {

    // 기존 타이머가 있으면 취소
    timer?.cancel();

    setState(() {
      remainingTime = 180;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--; // 남은 시간 감소
        } else {
          timer.cancel(); // 타이머 취소
        }
      });
    });
  }

  // 시간 형식 변환 함수 (초 -> mm:ss)
  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void handleSendVerificationCode(String email) async {
    final response = await emailApi.sendVerificationCode(EmailType.register.value, email);

    if (response.statusCode == 200) {
      startTimer();

      setState(() {
        if (isCodeSent && isCodeCheck) {
          isCodeCheck = false;
        }
        isCodeSent = true;
        emailSessionId = response.data['sessionId'];
      });
    } else {
      log("인증코드 전송 실패");
    }
  }

  void handleCheckVerificationCode(String code, String emailSessionId) async {
    final response = await emailApi.checkVerificationCode(code, emailSessionId);

    if (response.statusCode == 200) {
      setState(() {
        isCodeCheck = true;
      });
    } else {
      log("인증코드 확인 실패: ${response.data}");
    }
  }

  void handleRegister(RegisterDTO registerDTO) async {
    final response = await register(registerDTO);

    if (response.statusCode == 200) {
      log(response.body);
      Navigator.pop(context); // 현재 화면(register_email_screen) pop
      Navigator.pop(context); // 이전 화면(register_screen) pop
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
        title: const Text(
          "회원가입",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          child: Container( // 전체 화면
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Form(
                      key: formKey,
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
                                    "이메일 인증",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                )
                              ),
                              Container( // 이메일, 인증코드 입력 부분
                                child: Column(
                                  children: [
                                    Container( // 이메일 입력 부분
                                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "이메일 *",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: emailController,
                                                  focusNode: emailFocus,
                                                  keyboardType: TextInputType.emailAddress,
                                                  onChanged: (value) {
                                                    checkFormValid();
                                                  },
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  validator: (value) {
                                                    return Checkvalidate().validateEmail(value);
                                                  },
                                                  decoration: const InputDecoration(
                                                    hintText: "이메일을 입력해주세요."
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              ElevatedButton(
                                                onPressed: isEmailValid
                                                  ? () {
                                                      handleSendVerificationCode(emailController.text);
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
                                                  isCodeSent ? "재전송" : "인증번호 전송",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                )
                                              )
                                            ],
                                          ),
                                          
                                        ],
                                      ),
                                    ),
                                    Container( // 인증번호 입력 부분
                                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "인증번호 *",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              Text(
                                                isCodeSent ? formatTime(remainingTime) : "",
                                                style: const TextStyle(
                                                  fontSize: 18
                                                ),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: codeController,
                                                  focusNode: codeFocus,
                                                  keyboardType: TextInputType.number,
                                                  maxLength: 6,
                                                  onChanged: (value) {
                                                    checkFormValid();
                                                  },
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  validator: (value) {
                                                    return Checkvalidate().validateCode(value);
                                                  },
                                                  decoration: const InputDecoration(
                                                    hintText: "인증번호를 입력해주세요."
                                                  ),
                                                )
                                              ),
                                              const SizedBox(width: 10),
                                              ElevatedButton(
                                                onPressed: isCodeValid
                                                  ? () {
                                                      handleCheckVerificationCode(codeController.text, emailSessionId);
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
                                                  "인증번호 확인",
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
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ),
                  )
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: (formKey.currentState?.validate() ?? false) && isCodeSent && isCodeCheck
                      ? () {
                          final updatedDTO = widget.registerDTO.copyWith(email: emailController.text);
                          handleRegister(updatedDTO);
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
                      "회원가입",
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
      ),
    );
  }
}
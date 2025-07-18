import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/api/profile_registration_api.dart';
import 'package:king_of_table_tennis/model/profile_registration_dto.dart';
import 'package:king_of_table_tennis/screen/table_tennis_info_registration_screen.dart';
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

  // 사용자가 선택한 이미지
  XFile? selectProfileImage;

  @override
  void dispose() {
    nickNameController.dispose();
    
    nicKNameFocus.dispose();

    super.dispose();
  }

  Future<void> pickImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        selectProfileImage = pickedImage;
      });
    }
  }

  void showProfileOptions() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Dialog(
          insetPadding: const EdgeInsets.all(30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "프로필 선택",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "갤러리에서 선택",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.racketRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    )
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    pickImage();
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "기본 이미지 선택",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.racketRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    )
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      selectProfileImage = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      )
    );
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: Material(
                              color: Colors.grey[300],
                              child: InkWell(
                                onTap: () {
                                  showProfileOptions();
                                },
                                child: SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                    child: selectProfileImage != null
                                    ? Image.file(
                                        File(selectProfileImage!.path),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 160,
                                      ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
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
                      onPressed: !isNickNameDuplication
                        ? () {
                            print("다음 클릭!!!");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TableTennisInfoRegistrationScreen(
                                  profileRegistrationDTO: ProfileRegistrationDTO(
                                    profileImage: selectProfileImage,
                                    nickName: nickNameController.text
                                  ),
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
      ),
    );
  }
}
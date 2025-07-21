import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:king_of_table_tennis/api/token_api.dart';
import 'package:king_of_table_tennis/util/secure_storage.dart';
import 'package:king_of_table_tennis/screen/login_screen.dart';

Future<http.Response> apiRequest(Future<http.Response> Function() request, BuildContext context) async {
  final response1 = await request(); // 첫 번째 요청

  if (response1.statusCode == 200) { // 첫 번째 요청의 statusCode가 200으로 성공하면 응답 반환
    return response1;

  } else { // 첫 번째 요청의 statusCode가 200이 아니면
    final refreshAccessTokenResponse = await refreshAccessToken(); // accessToken 재발급 요청

    if (refreshAccessTokenResponse.statusCode == 200) { // accessToken 재발급이 성공하면
      final data = json.decode(refreshAccessTokenResponse.body);
      final newAccessToken = data["newAccessToken"];

      await SecureStorage.replaceAccessToken(newAccessToken); // 새로 발급받은 accessToken 저장

      final response2 = await request(); // 두 번째 요청

      if (response2.statusCode == 200) { // 두 번째 요청의 statusCode가 200으로 성공하면 응답 반환
        return response2;

      } else { // 두 번째 요청의 statusCode가 200이 아니면 요청을 할 수 없는 상황이기 때문에
        requestFailureProcess(context); // 요청 실패 처리 수행
        return response2;
      }

    } else { // accessToken 재발급이 실패하면 accessToken과 refreshToken이 둘 다 만료된 상태이기 때문에
      requestFailureProcess(context); // 요청 실패 처리 수행
      return response1;
    }
  }
  
}

void requestFailureProcess (BuildContext context) async { // 요청 실패 처리 수행
  await SecureStorage.logout(); // 로그아웃 처리 후
  Navigator.pushAndRemoveUntil( // 로그인 화면으로 이동
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (route) => false // 스택에 남는 페이지 없이 전체 초기화
  );
  ScaffoldMessenger.of(context)
    .showSnackBar(SnackBar(
      content: Column(
        children: [
          Text("사용자 정보가 유효하지 않습니다."),
          Text("다시 로그인해주세요.")
        ],
      )
    ));
}
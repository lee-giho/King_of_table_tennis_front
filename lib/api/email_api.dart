import 'dart:developer';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegisterEmailApi {
  final Dio dio;
  final CookieJar cookieJar;

  RegisterEmailApi()
    : dio = Dio(),
      cookieJar = CookieJar() {
    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<Response> sendVerificationCode(String email) async {
    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/email/code/register?email=$email");

    try {
      final response = await dio.get(
        apiAddress.toString()
      );

      return response;
    } catch (e) {
      log("네트워크 오류: ${e}");
      rethrow;
    }
  }

  Future<Response> checkVerificationCode(String code, String sessionId) async {
    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/email/code/verify?code=$code");

    try {
      final response = await dio.get(
        apiAddress.toString(),
        options: Options(
          headers: {'sessionId': sessionId}
        )
      );

      return response;
    } catch (e) {
      log("네트워크 오류: ${e}");
      rethrow;
    }
  }

}
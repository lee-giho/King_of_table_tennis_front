import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:king_of_table_tennis/model/change_password_dto.dart';

Future<http.Response> findPasswordChange(ChangePasswordDTO changePasswordDTO) async {
  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/password");
  final headers = {'Content-Type': 'application/json'};

  try {
    final response = await http.patch(
      apiAddress,
      headers: headers,
      body: json.encode(changePasswordDTO.toJson())
    );

    return response;
  } catch (e) {
    log("네트워크 오류: ${e}");
    rethrow;
  }
}
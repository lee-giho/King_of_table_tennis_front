import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:king_of_table_tennis/model/register_dto.dart';

Future<http.Response> checkIdDuplication(String id) async {
  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/exists/id/${id}");
  final headers = {'Content-Type': 'application/json'};

  final response = await http.get(
    apiAddress,
    headers: headers,
  );

  return response;
}

Future<http.Response> register(RegisterDTO registerDTO) async {
  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/register");
  final headers = {'Content-Type': 'application/json'};

  try {
    final response = await http.post(
      apiAddress,
      headers: headers,
      body: json.encode(registerDTO.toJson())
    );

    return response;
  } catch (e) {
    log("네트워크 오류: ${e}");
    rethrow;
  }
}
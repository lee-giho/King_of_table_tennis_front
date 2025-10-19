import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:king_of_table_tennis/model/RegisterPostRequest.dart';
import 'dart:convert';
import 'package:king_of_table_tennis/util/secure_storage.dart';

Future<http.Response> registerPost(RegisterPostRequest registerPostRequest) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/post");
  final headers = {
    'Authorization': 'Bearer ${accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.post(
    apiAddress,
    headers: headers,
    body: json.encode(registerPostRequest.toJson())
  );

  return response;
}
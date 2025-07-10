import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<http.Response> login(String id, String password) async {
  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/login");
  final headers = {'Content-Type': 'application/json'};

  final response = await http.post(
    apiAddress,
    headers: headers,
    body: json.encode({
      'id': id,
      'password': password
    })
  );

  return response;
}
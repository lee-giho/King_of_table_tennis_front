import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:king_of_table_tennis/util/secure_storage.dart';

Future<http.Response> createBroadcastRoom(String gameInfoId) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/broadcast");
  final headers = {
    'Authorization': 'Bearer ${accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.post(
    apiAddress,
    headers: headers,
    body: json.encode({
      "gameInfoId": gameInfoId
    })
  );

  return response;
}

Future<http.Response> deleteBroadcastRoom(String gameInfoId) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/broadcast?roomId=${gameInfoId}");
  final headers = {
    'Authorization': 'Bearer ${accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.delete(
    apiAddress,
    headers: headers
  );

  return response;
}

Future<http.Response> enterBroadcastRoom(String gameInfoId) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/broadcast/enter/$gameInfoId");
  final headers = {
    'Authorization': 'Bearer ${accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.get(
    apiAddress,
    headers: headers
  );

  return response;
}
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:king_of_table_tennis/model/RegisterCommentRequest.dart';
import 'package:king_of_table_tennis/util/secure_storage.dart';

Future<http.Response> deleteMyComment(String commentId) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/comment/$commentId");
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

Future<http.Response> patchMyComment(String commentId, RegisterCommentRequest registerCommentRequest) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/comment/$commentId");
  final headers = {
    'Authorization': 'Bearer ${accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.patch(
    apiAddress,
    headers: headers,
    body: json.encode(registerCommentRequest.toJson())
  );

  return response;
}
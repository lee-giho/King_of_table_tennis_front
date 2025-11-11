import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:king_of_table_tennis/enum/friend_request_answer_type.dart';
import 'dart:convert';

import 'package:king_of_table_tennis/model/friend_request.dart';
import 'package:king_of_table_tennis/util/secure_storage.dart';

Future<http.Response> requestFriend(FriendRequest friendRequest) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/friend");
  final headers = {
    'Authorization': 'Bearer ${accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.post(
    apiAddress,
    headers: headers,
    body: json.encode(friendRequest.toJson())
  );

  return response;
}

Future<http.Response> responseFriendRequest(String targetUserId, FriendRequestAnswerType friendRequestAnswerType) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/friend/requests/$targetUserId");
  final headers = {
    'Authorization': 'Bearer ${accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.patch(
    apiAddress,
    headers: headers,
    body: json.encode({
      "answer": friendRequestAnswerType.value
    })
  );

  return response;
}

Future<http.Response> deleteMyFriend(String targetUserId) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/friend/$targetUserId");
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
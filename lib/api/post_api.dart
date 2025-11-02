import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:king_of_table_tennis/enum/comment_sort_option.dart';
import 'package:king_of_table_tennis/enum/post_sort_option.dart';
import 'package:king_of_table_tennis/enum/post_type.dart';
import 'package:king_of_table_tennis/model/RegisterCommentRequest.dart';
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

Future<http.Response> deleteMyPost(String postId) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/post/$postId");
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

Future<http.Response> patchMyPost(String postId, RegisterPostRequest registerPostRequest) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/post/$postId");
  final headers = {
    'Authorization': 'Bearer ${accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.patch(
    apiAddress,
    headers: headers,
    body: json.encode(registerPostRequest.toJson())
  );

  return response;
}

Future<http.Response> getPostById(String postId) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/post/$postId");
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

Future<http.Response> getPost({
  required int page,
  required int size,
  required List<PostType> categories,
  required PostSortOption sort,
  String? keyword
}) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  String base = "${dotenv.get("API_ADDRESS")}/api/post";

  final params = <String>[
    "page=$page",
    "size=$size",
    ...categories.map((c) => "category=${c.value}"),
    "sort=${sort.value}",
    if (keyword != null && keyword.trim().isNotEmpty)
      "keyword=${Uri.encodeQueryComponent(keyword.trim())}"
  ].join("&");

  final uri = Uri.parse("$base?$params");

  final headers = {
    'Authorization': 'Bearer ${accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.get(
    uri,
    headers: headers
  );

  return response;
}

Future<http.Response> registerComment(String postId, RegisterCommentRequest registerCommentRequest) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/post/$postId/comment");
  final headers = {
    'Authorization': 'Bearer ${accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.post(
    apiAddress,
    headers: headers,
    body: json.encode(registerCommentRequest.toJson())
  );

  return response;
}

Future<http.Response> getComments(String postId, int page, int size, CommentSortOption sort, bool showMyComment) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/post/$postId/comments?page=$page&size=$size&sort=${sort.value}&showMyComment=$showMyComment");
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
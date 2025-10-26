import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:king_of_table_tennis/enum/post_sort_option.dart';
import 'package:king_of_table_tennis/enum/post_type.dart';
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

Future<http.Response> getPostByCategory(int page, int size, List<PostType> categories, PostSortOption sort) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  String url = "${dotenv.get("API_ADDRESS")}/api/post?page=$page&size=$size";

  final categoryParams = categories.map((c) => "category=${c.value}").join("&");
  url = "$url&$categoryParams&sort=${sort.value}";

  final uri = Uri.parse(url);

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
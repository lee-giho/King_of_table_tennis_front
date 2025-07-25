import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:king_of_table_tennis/util/secure_storage.dart';

Future<http.Response> searchTableTennisCourtByName(String name) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/ttc/${name}");
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
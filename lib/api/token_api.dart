import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:king_of_table_tennis/util/secure_storage.dart';

Future<http.Response> refreshAccessToken() async {
  String? refreshToken = await SecureStorage.getRefreshToken();
 
  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/accessToken");
  final headers = {
    'Authorization': 'Bearer ${refreshToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.get(
    apiAddress,
    headers: headers
  );

  return response;
}
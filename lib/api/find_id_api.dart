import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<http.Response> findId(String name, String email) async {
  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/id?name=$name&email=$email");
  final headers = {'Content-Type': 'application/json'};

  final response = await http.get(
    apiAddress,
    headers: headers
  );

  return response;
}
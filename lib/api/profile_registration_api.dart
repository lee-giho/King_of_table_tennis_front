import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:king_of_table_tennis/model/profile_registration_dto.dart';
import 'package:king_of_table_tennis/util/secure_storage.dart';

Future<http.Response> checkNickNameDuplication(String nickName) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/exists/nickName/${nickName}");
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

Future<http.Response> saveProfileImageAndNickName(ProfileRegistrationDTO profileRegistrationDTO) async {
  String? accessToken = await SecureStorage.getAccessToken();

  // .env에서 서버 URL 가져오기
  final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/profileImage/nickName");

  final request = http.MultipartRequest('PATCH', apiAddress);

  request.headers['Authorization'] = 'Bearer ${accessToken}';

  request.fields['nickName'] = profileRegistrationDTO.nickName;

  if (profileRegistrationDTO.profileImage != null) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'profileImage', profileRegistrationDTO.profileImage!.path
      )
    );
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  return response;
}
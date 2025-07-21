import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // FlutterSecureStorage 인스턴스 생성
  static final storage = FlutterSecureStorage();

  // 공통적인 'write' 메서드
  static Future<void> writeData(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  // 공통적인 'read' 메서드
  static Future<String?> readData(String key) async {
    return await storage.read(key: key);
  }

  // 자동 로그인 여부 저장
  static Future<void> saveIsAutoLogin(bool? isAutoLogin) async {
    await storage.write(
      key: 'autoLogin',
      value: isAutoLogin.toString() // bool -> String 변환
    );
  }

  // 자동 로그인 여부 읽기
  static Future<bool?> getIsAutoLogin() async {
    final isAutoLogin = await storage.read(key: 'autoLogin');
    // 값이 없으면 null 반환
    if (isAutoLogin == null) {
      return null;
    }
    return isAutoLogin.toLowerCase() == 'true'; // String -> bool 변환
  }

  // accessToken 저장
  static Future<void> saveAccessToken(String accessToken) async {
    await storage.write(
      key: 'accessToken',
      value: accessToken
    );
  }

  // accessToken 삭제 후 다시 저장
  static Future<void> replaceAccessToken(String accessToken) async {
    await storage.delete(key: 'accessToken');
    await storage.write(
      key: 'accessToken',
      value: accessToken
    );
  }

  // accessToken 읽기
  static Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  // refreshToken 저장
  static Future<void> saveRefreshToken(String refreshToken) async {
    await storage.write(
      key: 'refreshToken',
      value: refreshToken
    );
  }

  // refreshToken 읽기
  static Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refreshToken');
  }

  // 로그아웃 처리
  static Future<void> logout() async {
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
    saveIsAutoLogin(false);
  }
}
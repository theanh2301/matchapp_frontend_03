import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static String? token;
  static int? userId;
  static int? gradeId;
  static String? role;

  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration maxSessionAge = Duration(days: 7);

  static const String _tokenKey = 'token';
  static const String _userIdKey = 'userId';
  static const String _gradeIdKey = 'gradeId';
  static const String _roleKey = 'role';
  static const String _loginAtKey = 'authLoginAt';
  static const String _lastActivityKey = 'authLastActivityAt';

  static DateTime? _lastActivityPersistedAt;
  static final String _baseUrl = "${ApiConstants.baseUrl}/auth";

  static Future<UserModel> login(String email, String password) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(ApiConstants.requestTimeout);

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      final authData = decodedData['data'];

      await saveAuthData(authData);

      return UserModel.fromJson(authData);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Dang nhap that bai');
    }
  }

  static Future<bool> register(
    String fullName,
    String email,
    String password,
    String confirmPassword,
    int gradeId,
  ) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'fullName': fullName,
            'email': email,
            'password': password,
            'confirmPassword': confirmPassword,
            'gradeId': gradeId,
          }),
        )
        .timeout(ApiConstants.requestTimeout);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Dang ky that bai');
    }
  }

  static Future<void> saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    await prefs.setString(_tokenKey, data['token'] ?? '');
    await prefs.setInt(_userIdKey, data['userId'] ?? 0);
    await prefs.setInt(_gradeIdKey, data['gradeId'] ?? 0);
    await prefs.setString(_roleKey, data['role'] ?? 'USER');
    await prefs.setInt(_loginAtKey, now);
    await prefs.setInt(_lastActivityKey, now);

    token = data['token'];
    userId = data['userId'];
    gradeId = data['gradeId'];
    role = data['role'];
    _lastActivityPersistedAt = DateTime.fromMillisecondsSinceEpoch(now);
  }

  static Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString(_tokenKey);
    userId = prefs.getInt(_userIdKey);
    gradeId = prefs.getInt(_gradeIdKey);
    role = prefs.getString(_roleKey);

    if (isLoggedIn && await isSessionExpired()) {
      await logout();
    }
  }

  static Future<void> touchActivity() async {
    if (!isLoggedIn) return;

    final now = DateTime.now();
    if (_lastActivityPersistedAt != null &&
        now.difference(_lastActivityPersistedAt!) <
            const Duration(minutes: 1)) {
      return;
    }

    _lastActivityPersistedAt = now;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActivityKey, now.millisecondsSinceEpoch);
  }

  static Future<bool> isSessionExpired() async {
    if (!isLoggedIn) return true;

    final prefs = await SharedPreferences.getInstance();
    final loginAt = prefs.getInt(_loginAtKey);
    final lastActivityAt = prefs.getInt(_lastActivityKey);
    if (loginAt == null || lastActivityAt == null) return true;

    final now = DateTime.now();
    final loginTime = DateTime.fromMillisecondsSinceEpoch(loginAt);
    final activityTime = DateTime.fromMillisecondsSinceEpoch(lastActivityAt);

    return now.difference(loginTime) > maxSessionAge ||
        now.difference(activityTime) > sessionTimeout;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_gradeIdKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_loginAtKey);
    await prefs.remove(_lastActivityKey);

    token = null;
    userId = null;
    gradeId = null;
    role = null;
    _lastActivityPersistedAt = null;
  }

  static bool get isLoggedIn => token != null && token!.isNotEmpty;
}

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

  static final String _baseUrl = "${ApiConstants.baseUrl}/auth";

  static Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      final authData = decodedData['data'];

      await saveAuthData(authData);

      return UserModel.fromJson(authData);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Đăng nhập thất bại');
    }
  }

  static Future<bool> register(
      String fullName,
      String email,
      String password,
      String confirmPassword,
      int gradeId, // Hoàn thiện tham số classId ở đây
      ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'gradeId': gradeId, // Truyền thêm classId vào body request
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Đăng ký thất bại');
    }
  }

  /// Lưu dữ liệu (Gọi tự động bên trong hàm login)
  static Future<void> saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // Lưu vào ổ cứng điện thoại
    await prefs.setString('token', data['token'] ?? '');
    await prefs.setInt('userId', data['userId'] ?? 0);
    await prefs.setInt('gradeId', data['gradeId'] ?? 0);
    await prefs.setString('role', data['role'] ?? 'USER');

    // Cập nhật ngay vào RAM
    token = data['token'];
    userId = data['userId'];
    gradeId = data['gradeId'];
    role = data['role'];
  }

  /// Nạp dữ liệu từ ổ cứng lên RAM (Phải gọi hàm này ở main.dart)
  static Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    userId = prefs.getInt('userId');
    gradeId = prefs.getInt('gradeId');
    role = prefs.getString('role');
  }

  /// Đăng xuất
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa sạch dữ liệu trên ổ cứng

    // Reset RAM về null
    token = null;
    userId = null;
    gradeId = null;
    role = null;
  }

  /// Getter kiểm tra xem người dùng đã đăng nhập chưa
  static bool get isLoggedIn => token != null && token!.isNotEmpty;
}
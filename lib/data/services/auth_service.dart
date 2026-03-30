
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  // Thay đổi URL này theo địa chỉ Backend của bạn
  final String baseUrl = "http://192.168.0.103:8080/api/auth";


  // Hàm Đăng nhập
  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Thành công, trả về dữ liệu User
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      // Thất bại, quăng lỗi để UI xử lý
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Đăng nhập thất bại');
    }
  }

  // Hàm Đăng ký
  Future<bool> register(
      String fullName,
      String email,
      String password,
      String confirmPassword,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Đăng ký thất bại');
    }
  }
}
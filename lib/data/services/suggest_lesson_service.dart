// Tệp: lib/data/services/suggested_lesson_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learn_math_app_03/core/constants/ApiConstants.dart';
import '../models/suggest_lesson_model.dart';

class SuggestedLessonService {

  Future<List<SuggestedLessonModel>> getSuggestedLessons(int userId) async {
    // 1. Tạo URL với các tham số truyền vào
    final String urlString = "${ApiConstants.baseUrl}/lessons/suggested-lessons?userId=$userId";
    final Uri url = Uri.parse(urlString);

    // THÊM DÒNG NÀY ĐỂ KIỂM TRA ĐƯỜNG DẪN TRONG DEBUG CONSOLE
    print("--- Calling API: $urlString ---");

    try {
      // 2. Gọi API bằng phương thức GET
      final response = await http.get(url);

      // 3. Kiểm tra mã trạng thái (200 là thành công)
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> dataList = responseData['data'];

        List<SuggestedLessonModel> lessons = dataList
            .map((jsonItem) => SuggestedLessonModel.fromJson(jsonItem))
            .toList();

        return lessons;
      } else {
        print("Lỗi từ Server: ${response.statusCode} - ${response.body}");
        throw Exception("Lỗi gọi API: Mã trạng thái ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      throw Exception("Không thể kết nối đến máy chủ: $e");
    }
  }
}
// Tệp: lib/data/services/suggested_lesson_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learn_math_app_03/core/constants/ApiConstants.dart';
import '../models/suggest_lesson_model.dart';

class SuggestedLessonService {

  Future<List<SuggestedLessonModel>> getSuggestedLessons(int userId, int subjectId) async {
    // 1. Tạo URL với các tham số truyền vào
    final Uri url = Uri.parse("${ApiConstants.baseUrl}/lessons/suggested-lessons?userId=$userId&subjectId=$subjectId");

    try {
      // 2. Gọi API bằng phương thức GET
      final response = await http.get(url);

      // 3. Kiểm tra mã trạng thái (200 là thành công)
      if (response.statusCode == 200) {
        // Chuyển đổi chuỗi JSON trả về thành Map
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Lấy danh sách từ trường "data"
        final List<dynamic> dataList = responseData['data'];

        // Map từng phần tử JSON sang đối tượng SuggestedLessonModel
        List<SuggestedLessonModel> lessons = dataList
            .map((jsonItem) => SuggestedLessonModel.fromJson(jsonItem))
            .toList();

        return lessons;
      } else {
        // Xử lý lỗi nếu API trả về mã lỗi khác 200
        throw Exception("Lỗi gọi API: Mã trạng thái ${response.statusCode}");
      }
    } catch (e) {
      // Bắt các lỗi liên quan đến kết nối mạng hoặc parse JSON
      throw Exception("Không thể kết nối đến máy chủ: $e");
    }
  }
}
import 'package:flutter/material.dart';
import 'package:learn_math_app_03/screens/main_screen.dart';

import 'theme/app_colors.dart';

void main() {
  // Chạy ứng dụng
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathJoy', // Tên ứng dụng của bạn
      debugShowCheckedModeBanner: false, // Ẩn dải ruy-băng "DEBUG" màu đỏ ở góc màn hình
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary, // Sử dụng màu xanh dương chủ đạo
        scaffoldBackgroundColor: AppColors.bgLight, // Màu nền xám nhạt cho toàn app

        // Nếu bản thiết kế Figma của bạn dùng font chữ cụ thể (như Inter, Roboto, Quicksand)
        // Bạn có thể khai báo ở đây sau khi đã thêm font vào pubspec.yaml
        // fontFamily: 'Inter',

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),

      // Khai báo màn hình khởi chạy đầu tiên là AuthScreen (Đăng nhập/Đăng ký)
      home: const MainScreen(),
    );
  }
}
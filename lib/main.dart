import 'package:flutter/material.dart';
import 'package:learn_math_app_03/ui/screens/splash/splash_screen.dart';

import 'core/theme/app_colors.dart';
import 'data/services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathJoy',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => AuthService.touchActivity(),
          onPointerMove: (_) => AuthService.touchActivity(),
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.bgLight,

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

      home: const SplashScreen(),
    );
  }
}

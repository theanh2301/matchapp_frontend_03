import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../widget/robot_mascot.dart';
import '../auth/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<double> _entranceAnimation;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Animation xuất hiện (từ nhỏ phóng to ra) cho nội dung chính
    _entranceAnimation = CurvedAnimation(
      parent: _bgController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );
    // Lưu ý: Vì _bgController lặp lại, nếu muốn entrance chỉ chạy 1 lần
    // thì nên dùng controller riêng. Ở đây mình dùng chung để demo sự đơn giản,
    // nhưng thực tế bạn có thể tách ra nếu muốn robot "đứng yên" sau khi xuất hiện.
    Future.delayed(const Duration(seconds: 3), () {
      // Kiểm tra xem màn hình còn hiển thị không trước khi chuyển (tránh lỗi)
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AuthScreen(), // Chuyển sang AuthScreen
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563EB), // Blue đầm hơn
              Color(0xFF7C3AED), // Violet
              Color(0xFFDB2777), // Pink
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- 1. Background Effects ---
            _buildAnimatedBlob(
              top: -50, left: -50, size: 300,
              color: Colors.purpleAccent.withOpacity(0.3),
              controller: _bgController,
              direction: 1.0,
            ),
            _buildAnimatedBlob(
              bottom: -50, right: -20, size: 250,
              color: Colors.blueAccent.withOpacity(0.3),
              controller: _bgController,
              direction: -1.0,
            ),

            // --- 2. Main Content ---
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const RobotMascot(
                  size: 140,
                  isWhiteStyle: true,
                ),

                const SizedBox(height: 50),

                _buildAppTitle(),

                const SizedBox(height: 60),

                _buildLoadingDots(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return Column(
      children: [
        const Text(
          "MathJoy",
          style: TextStyle(
            color: Colors.white,
            fontSize: 52,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            shadows: [
              Shadow(blurRadius: 10, color: Colors.black26, offset: Offset(0, 5)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: const Text(
            "Trợ lý AI học toán thông minh",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedBlob({
    double? top, double? left, double? right, double? bottom,
    required double size,
    required Color color,
    required AnimationController controller,
    required double direction, // 1.0 hoặc -1.0 để xoay chiều ngược nhau
  }) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          // Hiệu ứng "thở" (scale) và di chuyển nhẹ
          final scale = 1.0 + (math.sin(controller.value * math.pi) * 0.1 * direction);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(color: color, blurRadius: 60, spreadRadius: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _bgController,
          builder: (context, child) {
            // Tạo hiệu ứng sóng (wave) cho các chấm
            final wave = math.sin((_bgController.value * 4 * math.pi) + (i * 1.0));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4 + (wave * 0.4).abs()), // Opacity thay đổi
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
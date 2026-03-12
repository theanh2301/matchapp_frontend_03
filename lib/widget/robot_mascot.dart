import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';


class RobotMascot extends StatefulWidget {
  final double size;
  final bool isWhiteStyle; // Tham số mới: true = màu trắng, false = màu gradient

  const RobotMascot({
    super.key,
    this.size = 130, // Kích thước mặc định
    this.isWhiteStyle = false,
  });

  @override
  State<RobotMascot> createState() => _RobotMascotState();
}

class _RobotMascotState extends State<RobotMascot> with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _blinkController;
  late AnimationController _hoverController;

  Timer? _symbolTimer;
  Timer? _blinkTimer;

  final List<String> mathSymbols = ['+', '−', '×', '÷', 'π', '√'];
  int _currentSymbolIndex = 0;

  // Kích thước chuẩn dùng để tính tỉ lệ
  static const double _baseSize = 130.0;

  @override
  void initState() {
    super.initState();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _startBlinkingLoop();
    _startSymbolLoop();
  }

  void _startBlinkingLoop() {
    _blinkTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        _blinkController.forward().then((_) => _blinkController.reverse());
      }
    });
  }

  void _startSymbolLoop() {
    _symbolTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          _currentSymbolIndex = (_currentSymbolIndex + 1) % mathSymbols.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _blinkController.dispose();
    _hoverController.dispose();
    _symbolTimer?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. TÍNH TOÁN TỈ LỆ SCALE
    // Mọi thứ sẽ phóng to/thu nhỏ dựa trên tỉ lệ này
    final double scaleFactor = widget.size / _baseSize;

    return AnimatedBuilder(
      animation: Listenable.merge([_orbitController, _hoverController]),
      builder: (context, child) {
        // Hiệu ứng bay lên xuống cũng scale theo
        final hoverOffset = math.sin(_hoverController.value * math.pi) * 8 * scaleFactor;

        return Transform.scale(
          scale: scaleFactor, // Scale toàn bộ widget
          child: Transform.translate(
            offset: Offset(0, hoverOffset),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Các hạt vệ tinh
                ...List.generate(8, (i) => _buildParticle(i)),

                // Các ký tự toán học bay quanh
                ...List.generate(4, (i) => _buildFloatingSymbol(i)),

                // Đầu Robot chính
                _buildHead(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHead() {
    // CẤU HÌNH MÀU SẮC DỰA VÀO BIẾN isWhiteStyle

    // Màu nền thân
    final Decoration boxDecoration;
    if (widget.isWhiteStyle) {
      // Style TRẮNG (Cho Splash Screen)
      boxDecoration = BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      );
    } else {
      // Style GRADIENT (Cho Login Screen)
      boxDecoration = BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd], // Xanh -> Tím
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientEnd.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      );
    }

    return Container(
      width: _baseSize,
      height: _baseSize,
      decoration: boxDecoration,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -25,
            child: _buildAntenna(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              _buildEyes(),
              const SizedBox(height: 12),
              _buildMouth(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEyes() {
    // Mắt đổi màu: Nếu robot trắng thì mắt tím, nếu robot màu thì mắt trắng
    final Color eyeColor = widget.isWhiteStyle
        ? AppColors.robotEyeColorDark
        : AppColors.white;

    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _eyeWidget(eyeColor),
            const SizedBox(width: 25),
            _eyeWidget(eyeColor),
          ],
        );
      },
    );
  }

  Widget _eyeWidget(Color color) {
    return Transform.scale(
      scaleY: 1.0 - _blinkController.value,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMouth() {
    // Màu nền miệng
    final Color mouthBgColor = widget.isWhiteStyle
        ? AppColors.robotMouthBgLight
        : AppColors.robotMouthBgDark;

    // Màu chữ trong miệng
    final Color textColor = widget.isWhiteStyle
        ? AppColors.primary
        : AppColors.white;

    return Container(
      width: 42,
      height: 32,
      decoration: BoxDecoration(
        color: mouthBgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            mathSymbols[_currentSymbolIndex],
            key: ValueKey(mathSymbols[_currentSymbolIndex]),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAntenna() {
    return Transform.rotate(
      angle: math.sin(_hoverController.value * 2 * math.pi) * 0.05,
      child: Column(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.antennaOrange,
              boxShadow: [
                BoxShadow(
                    color: AppColors.antennaOrange.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2
                )
              ],
            ),
          ),
          Container(
              width: 3,
              height: 20,
              // Màu dây anten cũng đổi theo style
              color: widget.isWhiteStyle
                  ? AppColors.white.withOpacity(0.9)
                  : AppColors.white.withOpacity(0.7)
          ),
        ],
      ),
    );
  }

  Widget _buildParticle(int i) {
    final angle = (i * 45) * (math.pi / 180) + (_orbitController.value * 2 * math.pi);
    const radius = 100.0;

    // Hạt đổi màu nhẹ nếu ở nền trắng để dễ nhìn hơn
    final Color particleColor = widget.isWhiteStyle
        ? AppColors.white.withOpacity(0.4)
        : AppColors.white.withOpacity(0.6);

    return Transform.translate(
      offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: particleColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildFloatingSymbol(int i) {
    final angle = (i * 90 + 22.5) * (math.pi / 180) - (_orbitController.value * 2 * math.pi);
    const radius = 120.0;

    // Chữ bay cũng đổi màu nếu ở nền trắng
    final Color symbolColor = widget.isWhiteStyle
        ? AppColors.white.withOpacity(0.5)
        : AppColors.white.withOpacity(0.4);

    return Opacity(
      opacity: 1.0, // Control opacity via color
      child: Transform.translate(
        offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
        child: Text(
          mathSymbols[i],
          style: TextStyle(color: symbolColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
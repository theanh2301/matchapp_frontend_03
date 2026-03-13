import 'dart:ui';
import 'package:flutter/material.dart';

// MÔ HÌNH DỮ LIỆU CÂU HỎI
class QuizQuestion {
  final String category;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  QuizQuestion({
    required this.category,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  int _correctAnswers = 0;
  bool _isFinished = false;

  // DỮ LIỆU MẪU DỰA TRÊN ẢNH
  final List<QuizQuestion> _questions = [
    QuizQuestion(
      category: 'Đại số',
      question: 'Chọn công thức đúng để tính Delta (Δ):',
      options: [
        'Δ = b² - 4ac',
        'Δ = b - 4ac',
        'Δ = b² + 4ac',
        'Δ = 4ac - b²',
      ],
      correctOptionIndex: 0,
      explanation: 'Công thức tính biệt thức Delta của phương trình bậc 2 (ax² + bx + c = 0) luôn là Δ = b² - 4ac. Nó dùng để xét số nghiệm của phương trình.',
    ),
    QuizQuestion(
      category: 'Đại số',
      question: 'Nếu Δ > 0 thì phương trình bậc 2 có mấy nghiệm?',
      options: [
        'Vô nghiệm',
        'Nghiệm kép',
        'Hai nghiệm phân biệt',
        'Vô số nghiệm',
      ],
      correctOptionIndex: 2,
      explanation: 'Khi Δ > 0, phương trình bậc 2 sẽ có hai nghiệm phân biệt x₁ và x₂ được tính bằng công thức: x = (-b ± √Δ) / 2a.',
    ),
  ];

  // XỬ LÝ KHI CHỌN ĐÁP ÁN
  void _onOptionSelected(int index) {
    if (_selectedOptionIndex != null || _isFinished) return;

    setState(() {
      _selectedOptionIndex = index;
      if (index == _questions[_currentIndex].correctOptionIndex) {
        _correctAnswers++;
      }
    });
  }

  // XỬ LÝ KHI BẤM NÚT "TIẾP TỤC"
  void _onNextPressed() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  // HÀM CHƠI LẠI TỪ ĐẦU
  void _playAgain() {
    setState(() {
      _isFinished = false;
      _currentIndex = 0;
      _correctAnswers = 0;
      _selectedOptionIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];
    final bool isAnswered = _selectedOptionIndex != null;

    return Scaffold(
      // 1. Đổi màu nền chính sang dải Gradient xanh lam đậm
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)], // Gradient màu Deep Blue
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ==========================================
              // GIAO DIỆN GAME CHÍNH (Nằm dưới)
              // ==========================================
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP BAR (Làm trong suốt để hòa vào nền)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                            Text(
                              '${_currentIndex + 1}/${_questions.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 48), // Cân bằng không gian
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_currentIndex + 1) / _questions.length,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent), // Đổi màu chạy sang xanh ngọc
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // NỘI DUNG CÂU HỎI
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag môn học
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text(
                              question.category,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tiêu đề câu hỏi
                          Text(
                            question.question,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
                          ),
                          const SizedBox(height: 32),

                          // Danh sách đáp án
                          ...List.generate(question.options.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildOptionButton(
                                index: index,
                                text: question.options[index],
                                correctIndex: question.correctOptionIndex,
                                selectedIndex: _selectedOptionIndex,
                              ),
                            );
                          }),

                          // HỘP GIẢI THÍCH
                          if (isAnswered)
                            AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 500),
                              child: Container(
                                margin: const EdgeInsets.only(top: 16.0),
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  // Nền hộp giải thích hơi trong suốt
                                  color: _selectedOptionIndex == question.correctOptionIndex
                                      ? Colors.greenAccent.withOpacity(0.15)
                                      : Colors.redAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedOptionIndex == question.correctOptionIndex
                                        ? Colors.greenAccent.withOpacity(0.5)
                                        : Colors.redAccent.withOpacity(0.5),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _selectedOptionIndex == question.correctOptionIndex ? Icons.check_circle : Icons.cancel,
                                          color: _selectedOptionIndex == question.correctOptionIndex ? Colors.greenAccent : Colors.redAccent,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _selectedOptionIndex == question.correctOptionIndex ? "Chính xác!" : "Chưa chính xác!",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: _selectedOptionIndex == question.correctOptionIndex ? Colors.greenAccent : Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      question.explanation,
                                      style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.6),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // NÚT TIẾP TỤC Ở DƯỚI CÙNG
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isAnswered && !_isFinished ? _onNextPressed : null,
                        style: ElevatedButton.styleFrom(
                          // Nút nổi bật hơn với màu vàng cam
                          backgroundColor: isAnswered ? const Color(0xFFFF9800) : Colors.white.withOpacity(0.1),
                          foregroundColor: isAnswered ? Colors.white : Colors.white54,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: isAnswered ? 5 : 0,
                        ),
                        child: const Text('Tiếp tục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),

              // ==========================================
              // KHUNG THÔNG BÁO HOÀN THÀNH (Đè lên)
              // ==========================================
              if (_isFinished) _buildGlassOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // KHUNG THÔNG BÁO HOÀN THÀNH - STYLE GLASSMORPHISM CHUẨN XỊN
  Widget _buildGlassOverlay() {
    int xpEarned = _correctAnswers * 10;

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Làm mờ sâu hơn
        child: Container(
          color: Colors.black.withOpacity(0.4), // Phủ màn đen nhẹ
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  // 2. Chỉnh nền popup thành màu trắng kính mờ sang trọng
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, size: 90, color: Colors.amber),
                    const SizedBox(height: 20),
                    const Text(
                      'Tuyệt vời!',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bạn đã trả lời đúng $_correctAnswers/${_questions.length} câu',
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 30),

                    // Nút hiển thị XP
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.amber.withOpacity(0.8), width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            '+$xpEarned XP',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Hai nút: Chơi Lại và Tiếp Tục
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _playAgain,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Học lại', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent.shade400, // Nút tiếp tục màu xanh ngọc nổi bật
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 5,
                            ),
                            child: const Text('Tiếp tục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET NÚT ĐÁP ÁN - Làm lại cho phù hợp nền tối
  Widget _buildOptionButton({
    required int index,
    required String text,
    required int correctIndex,
    required int? selectedIndex,
  }) {
    final letter = String.fromCharCode(65 + index);
    bool isSelected = selectedIndex == index;
    bool isCorrect = index == correctIndex;
    bool isAnswered = selectedIndex != null;

    // Màu mặc định khi chưa chọn
    Color borderColor = Colors.white.withOpacity(0.2);
    Color bgColor = Colors.white.withOpacity(0.05);
    Color textColor = Colors.white;
    Color circleColor = Colors.white.withOpacity(0.1);
    Color circleTextColor = Colors.white70;

    if (isAnswered) {
      if (isCorrect) {
        // Nút đúng: Xanh lá cây sáng
        borderColor = Colors.greenAccent;
        bgColor = Colors.greenAccent.withOpacity(0.2);
        textColor = Colors.greenAccent;
        circleColor = Colors.greenAccent;
        circleTextColor = Colors.black87;
      } else if (isSelected && !isCorrect) {
        // Nút sai (người dùng lỡ bấm): Đỏ
        borderColor = Colors.redAccent;
        bgColor = Colors.redAccent.withOpacity(0.2);
        textColor = Colors.redAccent;
        circleColor = Colors.redAccent;
        circleTextColor = Colors.white;
      } else {
        // Các nút còn lại bị làm mờ đi
        borderColor = Colors.white.withOpacity(0.05);
        textColor = Colors.white30;
        circleTextColor = Colors.white30;
      }
    }

    return GestureDetector(
      onTap: () => _onOptionSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16), // Bo góc mềm hơn
          border: Border.all(color: borderColor, width: 2),
          // Thêm bóng đổ nhẹ khi được chọn
          boxShadow: isAnswered && (isCorrect || (isSelected && !isCorrect))
              ? [BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 10)]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                border: Border.all(color: isAnswered && (isCorrect || isSelected) ? Colors.transparent : Colors.white.withOpacity(0.3)),
              ),
              child: Text(
                letter,
                style: TextStyle(fontWeight: FontWeight.bold, color: circleTextColor, fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
              ),
            ),
            if (isAnswered && isCorrect)
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 28)
            else if (isAnswered && isSelected && !isCorrect)
              const Icon(Icons.cancel, color: Colors.redAccent, size: 28),
          ],
        ),
      ),
    );
  }
}
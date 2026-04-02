import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../data/models/quiz_model.dart';
import '../../../../data/models/quiz_progress_model.dart';
import '../../../../data/services/quiz_service.dart';

class QuizGameScreen extends StatefulWidget {
  final int lessonId; // Bắt buộc truyền ID bài học

  const QuizGameScreen({super.key, required this.lessonId});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  final QuizService _quizService = QuizService();

  bool _isLoading = true;
  bool _hasError = false;
  List<QuizModel> _quizzes = [];

  int _currentIndex = 0;
  int? _selectedOptionIndex;
  int _correctAnswers = 0;
  int _totalXpEarned = 0; // Thay vì điểm cứng, ta lấy từ DB
  bool _isFinished = false;

  bool _isSaving = false;
  final List<QuizProgressRequest> _submitQueue = [];

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _quizService.getQuizzesByLesson(widget.lessonId);
      if (mounted) {
        setState(() {
          _quizzes = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  // XỬ LÝ KHI CHỌN ĐÁP ÁN
  void _onOptionSelected(int index) {
    if (_selectedOptionIndex != null || _isFinished) return;

    setState(() {
      _selectedOptionIndex = index;
      if (index == _quizzes[_currentIndex].correctOptionIndex) {
        _correctAnswers++;
        _totalXpEarned += _quizzes[_currentIndex].xpReward; // Cộng XP của câu đó
      }
    });
  }

  // XỬ LÝ KHI BẤM NÚT "TIẾP TỤC"
  void _onNextPressed() {
    // 1. Lưu đáp án vừa chọn vào hàng đợi
    // TODO: Thay bằng userId thực tế
    int currentUserId = 3;

    _submitQueue.add(QuizProgressRequest(
      userId: currentUserId,
      questionId: _quizzes[_currentIndex].id, // Giả sử Model có thuộc tính id
      answerId: _quizzes[_currentIndex].answers[_selectedOptionIndex!].id, // Lấy id của đáp án được chọn
      answeredAt: DateTime.now().toIso8601String()
    ));

    // 2. Kiểm tra nếu chưa hết câu hỏi thì qua câu mới
    if (_currentIndex < _quizzes.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
      });
    } else {
      // Đã xong câu cuối -> Gọi hàm lưu API
      _saveAllProgress();
    }
  }

  // --- HÀM LƯU LÊN SERVER ---
  Future<void> _saveAllProgress() async {
    setState(() {
      _isFinished = true; // Kích hoạt hiện bảng thông báo
      _isSaving = true;   // Kích hoạt vòng xoay loading
    });

    await _quizService.saveQuizProgress(_submitQueue);

    if (mounted) {
      setState(() {
        _isSaving = false; // Tắt vòng xoay loading
      });
    }
  }

  // HÀM CHƠI LẠI TỪ ĐẦU
  void _playAgain() {
    setState(() {
      _isFinished = false;
      _currentIndex = 0;
      _correctAnswers = 0;
      _totalXpEarned = 0;
      _selectedOptionIndex = null;
      _submitQueue.clear(); // Xóa lịch sử cũ để chơi lại
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
          ),
        ),
        child: SafeArea(
          child: _buildBodyContent(),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.white),
            const SizedBox(height: 16),
            const Text("Không thể tải bài trắc nghiệm", style: TextStyle(color: Colors.white, fontSize: 18)),
            TextButton(
              onPressed: _fetchQuizzes,
              child: const Text("Thử lại", style: TextStyle(color: Colors.greenAccent)),
            )
          ],
        ),
      );
    }

    if (_quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Chưa có câu hỏi nào.", style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Quay lại", style: TextStyle(color: Colors.greenAccent)),
            )
          ],
        ),
      );
    }

    final question = _quizzes[_currentIndex];
    final bool isAnswered = _selectedOptionIndex != null;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP BAR
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
                        '${_currentIndex + 1}/${_quizzes.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / _quizzes.length,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        question.typeQuestion, // Lấy từ DB (QUIZ, DAILY, v.v)
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      question.content,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
                    ),
                    const SizedBox(height: 32),

                    // DANH SÁCH ĐÁP ÁN
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

                    // HỘP GIẢI THÍCH (Hiển thị description của đáp án người dùng vừa chọn)
                    if (isAnswered)
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          margin: const EdgeInsets.only(top: 16.0),
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
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
                                question.answers[_selectedOptionIndex!].description, // Trích xuất description từ API
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

            // NÚT TIẾP TỤC
            Container(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isAnswered && !_isFinished ? _onNextPressed : null,
                  style: ElevatedButton.styleFrom(
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

        if (_isFinished) _buildGlassOverlay(),
      ],
    );
  }
  Widget _buildGlassOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          color: Colors.black.withOpacity(0.4),
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
                    const Text('Tuyệt vời!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    Text('Bạn đã trả lời đúng $_correctAnswers/${_quizzes.length} câu', style: const TextStyle(fontSize: 18, color: Colors.white70)),
                    const SizedBox(height: 30),

                    // NẾU ĐANG LƯU THÌ HIỆN VÒNG XOAY, NẾU KHÔNG THÌ HIỆN ĐIỂM VÀ NÚT
                    if (_isSaving)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: CircularProgressIndicator(color: Colors.amber),
                      )
                    else ...[
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
                            Text('+$_totalXpEarned XP', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
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
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent.shade400,
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
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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

    Color borderColor = Colors.white.withOpacity(0.2);
    Color bgColor = Colors.white.withOpacity(0.05);
    Color textColor = Colors.white;
    Color circleColor = Colors.white.withOpacity(0.1);
    Color circleTextColor = Colors.white70;

    if (isAnswered) {
      if (isCorrect) {
        borderColor = Colors.greenAccent;
        bgColor = Colors.greenAccent.withOpacity(0.2);
        textColor = Colors.greenAccent;
        circleColor = Colors.greenAccent;
        circleTextColor = Colors.black87;
      } else if (isSelected && !isCorrect) {
        borderColor = Colors.redAccent;
        bgColor = Colors.redAccent.withOpacity(0.2);
        textColor = Colors.redAccent;
        circleColor = Colors.redAccent;
        circleTextColor = Colors.white;
      } else {
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
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
              child: Text(letter, style: TextStyle(fontWeight: FontWeight.bold, color: circleTextColor, fontSize: 16)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
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
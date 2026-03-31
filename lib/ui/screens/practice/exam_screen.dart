import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/exam_model.dart'; // Nơi chứa PracticeQuestionModel và PracticeAnswerModel
import '../../../data/models/practice_progress_model.dart';
import '../../../data/services/exam_service.dart'; // Nơi chứa PracticeListService

class QuizScreen extends StatefulWidget {
  final int practiceId; // Bắt buộc truyền ID bài tập vào
  final String title;


  const QuizScreen({
    super.key,
    required this.practiceId,
    required this.title,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Biến quản lý dữ liệu API
  final PracticeListService _practiceListService = PracticeListService();
  List<PracticeQuestionModel> _questions = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Quản lý trạng thái bài làm
  int currentQuestionIndex = 0;
  int timeLeft = 300; // Mặc định 5 phút (Bạn có thể lấy timeLimit từ API overview truyền qua nếu có)
  Timer? _timer;
  Map<int, int> selectedAnswers = {}; // Lưu đáp án: {questionIndex: optionIndex}
  bool isSubmitted = false; // Đã nộp bài chưa?
  // 🔥 THÊM BIẾN NÀY ĐỂ HIỂN THỊ LOADING KHI LƯU KẾT QUẢ
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions(); // Gọi API ngay khi mở màn hình
  }

  // Hàm gọi API lấy danh sách câu hỏi
  Future<void> _loadQuestions() async {
    try {
      final data = await _practiceListService.getPracticeQuestions(widget.practiceId);

      setState(() {
        _questions = data;
        _isLoading = false;
      });

      // Chỉ bắt đầu đếm giờ nếu tải thành công và có câu hỏi
      if (_questions.isNotEmpty) {
        _startTimer();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0 && !isSubmitted) {
        setState(() => timeLeft--);
      } else if (timeLeft == 0) {
        _timer?.cancel();
        _submitQuiz(); // Hết giờ tự động nộp bài
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get formattedTime {
    int minutes = timeLeft ~/ 60;
    int seconds = timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Chọn đáp án
  void _selectOption(int index) {
    if (isSubmitted) return; // Đã nộp bài thì khóa không cho chọn nữa
    setState(() {
      selectedAnswers[currentQuestionIndex] = index;
    });
  }

  // Nộp bài
  Future<void> _submitQuiz() async {
    setState(() {
      _isSaving = true; // Kích hoạt UI loading
      _timer?.cancel(); // Dừng đồng hồ
    });

    // TODO: Lấy userId thực tế đang đăng nhập trong app của bạn
    int currentUserId = 1;
    List<PracticeProgressRequest> requests = [];

    // Duyệt qua các câu hỏi đã chọn đáp án để tạo list request
    selectedAnswers.forEach((questionIndex, optionIndex) {
      final question = _questions[questionIndex];
      final selectedAnswer = question.answers[optionIndex];

      requests.add(PracticeProgressRequest(
        userId: currentUserId,
        questionId: question.id, // Giả sử PracticeQuestionModel có thuộc tính id
        answerId: selectedAnswer.id, // Giả sử PracticeAnswerModel có thuộc tính id
      ));
    });

    // Chỉ gọi API nếu người dùng có chọn ít nhất 1 đáp án
    if (requests.isNotEmpty) {
      await _practiceListService.saveQuizProgress(requests);
    }

    if (mounted) {
      setState(() {
        _isSaving = false; // Tắt vòng xoay
        isSubmitted = true; // Đánh dấu đã nộp bài
        currentQuestionIndex = 0; // Quay về câu 1 để người dùng xem giải thích
      });
    }
  }

  // Mở BottomSheet hiện lưới nhảy nhanh câu hỏi
  void _openQuestionGrid() {
    if (_questions.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Danh sách câu hỏi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(_questions.length, (index) {
                  bool isAnswered = selectedAnswers.containsKey(index);

                  Color boxColor = AppColors.white;
                  Color borderColor = Colors.grey.shade300;
                  Color textColor = Colors.black87;

                  if (isSubmitted) {
                    // Tìm index của đáp án đúng trong model API trả về
                    int correctIdx = _questions[index].answers.indexWhere((ans) => ans.isCorrect);
                    bool isCorrect = selectedAnswers[index] == correctIdx;

                    boxColor = isCorrect ? AppColors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1);
                    borderColor = isCorrect ? AppColors.green : Colors.red;
                    textColor = isCorrect ? AppColors.green : Colors.red;
                  } else if (isAnswered) {
                    boxColor = AppColors.primary;
                    borderColor = AppColors.primary;
                    textColor = AppColors.white;
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => currentQuestionIndex = index);
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ),
                  );
                }),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: AppColors.primary),
            onPressed: _openQuestionGrid,
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: _questions.isEmpty ? 0 : (currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey.shade200,
            color: AppColors.primary,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  // Tách riêng hàm _buildBody để kiểm soát UI Đang tải / Lỗi / Có dữ liệu
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text("Đang tải bộ câu hỏi...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_isSaving) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text("Đang nộp bài và lưu kết quả...", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text("Đã có lỗi xảy ra:\n$_errorMessage", style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text("Đã có lỗi xảy ra:\n$_errorMessage", style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Center(child: Text("Bài tập này hiện chưa có câu hỏi nào."));
    }

    // Lấy dữ liệu câu hỏi hiện tại
    final question = _questions[currentQuestionIndex];
    final options = question.answers; // Danh sách PracticeAnswerModel
    int? currentSelection = selectedAnswers[currentQuestionIndex];

    // Lấy giải thích từ đáp án đúng
    String explanation = "Chưa có giải thích cho câu hỏi này.";
    try {
      explanation = options.firstWhere((ans) => ans.isCorrect).description;
    } catch (_) {}

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row Thời gian và tiến độ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "Câu ${currentQuestionIndex + 1}/${_questions.length}",
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, color: isSubmitted ? Colors.grey : AppColors.orange, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          isSubmitted ? "Đã nộp" : formattedTime,
                          style: TextStyle(color: isSubmitted ? Colors.grey : AppColors.orange, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 30),

                // Câu hỏi (Lấy từ content của model)
                Text(question.content, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4)),
                const SizedBox(height: 30),

                // Danh sách Đáp án
                ...List.generate(options.length, (index) {
                  List<String> labels = ["A", "B", "C", "D", "E", "F"];
                  String label = index < labels.length ? labels[index] : "${index + 1}";

                  // So sánh đáp án
                  bool isSelected = currentSelection == index;
                  bool isCorrectAnswer = options[index].isCorrect;

                  Color bgColor = AppColors.white;
                  Color borderColor = Colors.grey.shade300;
                  Color textColor = Colors.black87;
                  Color labelBgColor = Colors.grey.shade100;

                  if (isSubmitted) {
                    if (isCorrectAnswer) {
                      bgColor = AppColors.green.withOpacity(0.1);
                      borderColor = AppColors.green;
                      labelBgColor = AppColors.green;
                      textColor = AppColors.green;
                    } else if (isSelected && !isCorrectAnswer) {
                      bgColor = Colors.red.withOpacity(0.1);
                      borderColor = Colors.red;
                      labelBgColor = Colors.red;
                      textColor = Colors.red;
                    }
                  } else if (isSelected) {
                    bgColor = AppColors.primary.withOpacity(0.05);
                    borderColor = AppColors.primary;
                    labelBgColor = AppColors.primary;
                    textColor = AppColors.primary;
                  }

                  return GestureDetector(
                    onTap: () => _selectOption(index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: isSelected || (isSubmitted && isCorrectAnswer) ? 2.0 : 1.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(color: labelBgColor, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text(
                              label,
                              style: TextStyle(
                                color: (isSelected || (isSubmitted && (isCorrectAnswer || isSelected))) ? AppColors.white : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              options[index].content,
                              style: TextStyle(fontSize: 16, color: textColor, fontWeight: isSelected || (isSubmitted && isCorrectAnswer) ? FontWeight.bold : FontWeight.normal),
                            ),
                          ),
                          if (isSubmitted && isCorrectAnswer)
                            const Icon(Icons.check_circle, color: AppColors.green),
                          if (isSubmitted && isSelected && !isCorrectAnswer)
                            const Icon(Icons.cancel, color: Colors.red),
                        ],
                      ),
                    ),
                  );
                }),

                // Hộp Giải thích (Chỉ hiện khi đã nộp bài và có nội dung)
                if (isSubmitted && explanation.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Colors.amber),
                            SizedBox(width: 8),
                            Text("Giải thích chi tiết", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(explanation, style: const TextStyle(height: 1.5, color: Colors.black87)),
                      ],
                    ),
                  )
                ]
              ],
            ),
          ),
        ),

        // ==========================================
        // NAVIGATION DƯỚI CÙNG
        // ==========================================
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: currentQuestionIndex > 0 ? AppColors.primary : Colors.grey.shade300),
                  ),
                  onPressed: currentQuestionIndex > 0
                      ? () => setState(() => currentQuestionIndex--)
                      : null,
                  child: Text("Câu trước", style: TextStyle(color: currentQuestionIndex > 0 ? AppColors.primary : Colors.grey.shade400, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSubmitted ? AppColors.primary : (currentQuestionIndex == _questions.length - 1 ? AppColors.green : AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (currentQuestionIndex < _questions.length - 1) {
                      setState(() => currentQuestionIndex++);
                    } else if (!isSubmitted) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Nộp bài?"),
                          content: const Text("Bạn đã chắc chắn muốn nộp bài chưa?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _submitQuiz();
                              },
                              child: const Text("Nộp bài", style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.pop(context); // Đã nộp bài, bấm hoàn thành -> Thoát
                    }
                  },
                  child: Text(
                    isSubmitted
                        ? (currentQuestionIndex == _questions.length - 1 ? "Hoàn thành" : "Câu tiếp")
                        : (currentQuestionIndex == _questions.length - 1 ? "Nộp bài" : "Câu tiếp"),
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
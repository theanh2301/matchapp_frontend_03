import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class QuizScreen extends StatefulWidget {
  final String title;
  const QuizScreen({super.key, required this.title});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int timeLeft = 300; // 5 phút
  Timer? _timer;

  // Trạng thái bài làm
  Map<int, int> selectedAnswers = {}; // Lưu đáp án đã chọn: {questionIndex: optionIndex}
  bool isSubmitted = false; // Đã nộp bài chưa?

  // Dữ liệu giả lập (Có thêm đáp án đúng và giải thích)
  final List<Map<String, dynamic>> questions = [
    {
      "question": "Nghiệm của phương trình x² - 4 = 0 là gì?",
      "options": ["x = 2", "x = -2", "x = 2 hoặc x = -2", "Vô nghiệm"],
      "correctIndex": 2,
      "explanation": "Ta có x² - 4 = 0 ⇔ x² = 4 ⇔ x = 2 hoặc x = -2. Cả hai nghiệm đều thoả mãn."
    },
    {
      "question": "Đâu là công thức tính Delta (Δ) của phương trình bậc 2: ax² + bx + c = 0?",
      "options": ["b² - 4ac", "b - 4ac", "b² + 4ac", "4ac - b²"],
      "correctIndex": 0,
      "explanation": "Công thức chuẩn để tính biệt thức Delta là Δ = b² - 4ac."
    },
    {
      "question": "Giá trị của sin(30°) bằng bao nhiêu?",
      "options": ["1/2", "√3/2", "1", "√2/2"],
      "correctIndex": 0,
      "explanation": "Theo bảng lượng giác cơ bản, sin(30°) = 1/2."
    },
    {
      "question": "Điều kiện để phương trình bậc 2 có 2 nghiệm phân biệt là gì?",
      "options": ["Δ < 0", "Δ = 0", "Δ > 0", "Δ ≥ 0"],
      "correctIndex": 2,
      "explanation": "Phương trình có 2 nghiệm phân biệt khi và chỉ khi biệt thức Δ > 0."
    }
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0 && !isSubmitted) {
        setState(() => timeLeft--);
      } else if (timeLeft == 0) {
        _timer?.cancel();
        _submitQuiz(); // Hết giờ tự nộp bài
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
    if (isSubmitted) return; // Đã nộp bài thì không cho chọn nữa
    setState(() {
      selectedAnswers[currentQuestionIndex] = index;
    });
  }

  // Nộp bài
  void _submitQuiz() {
    setState(() {
      isSubmitted = true;
      _timer?.cancel(); // Dừng thời gian
      currentQuestionIndex = 0; // Quay về câu 1 để xem lại
    });
  }

  // Mở BottomSheet hiện lưới câu hỏi (để nhảy nhanh)
  void _openQuestionGrid() {
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
                children: List.generate(questions.length, (index) {
                  bool isAnswered = selectedAnswers.containsKey(index);

                  // Màu sắc ô lưới tuỳ thuộc vào trạng thái (Đã nộp bài hay chưa)
                  Color boxColor = AppColors.white;
                  Color borderColor = Colors.grey.shade300;
                  Color textColor = Colors.black87;

                  if (isSubmitted) {
                    bool isCorrect = selectedAnswers[index] == questions[index]["correctIndex"];
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
    final question = questions[currentQuestionIndex];
    final options = question["options"] as List<String>;
    int? currentSelection = selectedAnswers[currentQuestionIndex];

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
            onPressed: _openQuestionGrid, // Mở menu chọn câu
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / questions.length,
            backgroundColor: Colors.grey.shade200,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Column(
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
                          "Câu ${currentQuestionIndex + 1}/${questions.length}",
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

                  // Câu hỏi
                  Text(question["question"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4)),
                  const SizedBox(height: 30),

                  // Danh sách Đáp án
                  ...List.generate(options.length, (index) {
                    List<String> labels = ["A", "B", "C", "D"];

                    // Logic màu sắc hiển thị
                    bool isSelected = currentSelection == index;
                    bool isCorrectAnswer = question["correctIndex"] == index;

                    Color bgColor = AppColors.white;
                    Color borderColor = Colors.grey.shade300;
                    Color textColor = Colors.black87;
                    Color labelBgColor = Colors.grey.shade100;

                    if (isSubmitted) {
                      if (isCorrectAnswer) {
                        // Đáp án đúng luôn tô xanh lá
                        bgColor = AppColors.green.withOpacity(0.1);
                        borderColor = AppColors.green;
                        labelBgColor = AppColors.green;
                        textColor = AppColors.green;
                      } else if (isSelected && !isCorrectAnswer) {
                        // Đáp án sai mà user đã chọn thì tô đỏ
                        bgColor = Colors.red.withOpacity(0.1);
                        borderColor = Colors.red;
                        labelBgColor = Colors.red;
                        textColor = Colors.red;
                      }
                    } else if (isSelected) {
                      // Đang làm bài, đáp án được chọn tô xanh dương
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
                                labels[index],
                                style: TextStyle(
                                  color: (isSelected || (isSubmitted && (isCorrectAnswer || isSelected))) ? AppColors.white : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                options[index],
                                style: TextStyle(fontSize: 16, color: textColor, fontWeight: isSelected || (isSubmitted && isCorrectAnswer) ? FontWeight.bold : FontWeight.normal),
                              ),
                            ),
                            // Thêm icon Tích xanh / X đỏ khi xem lại
                            if (isSubmitted && isCorrectAnswer)
                              const Icon(Icons.check_circle, color: AppColors.green),
                            if (isSubmitted && isSelected && !isCorrectAnswer)
                              const Icon(Icons.cancel, color: Colors.red),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Hộp Giải thích (Chỉ hiện khi đã nộp bài)
                  if (isSubmitted) ...[
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
                          Text(question["explanation"], style: const TextStyle(height: 1.5, color: Colors.black87)),
                        ],
                      ),
                    )
                  ]
                ],
              ),
            ),
          ),

          // ==========================================
          // NAVIGATION DƯỚI CÙNG (CÂU TRƯỚC - CÂU TIẾP / NỘP BÀI)
          // ==========================================
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                // Nút Câu trước
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

                // Nút Câu tiếp theo / Nộp bài
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSubmitted ? AppColors.primary : (currentQuestionIndex == questions.length - 1 ? AppColors.green : AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (currentQuestionIndex < questions.length - 1) {
                        setState(() => currentQuestionIndex++);
                      } else if (!isSubmitted) {
                        // Hiện thông báo xác nhận Nộp bài
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
                        // Nếu đã nộp bài và đang ở câu cuối -> Thoát
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      isSubmitted
                          ? (currentQuestionIndex == questions.length - 1 ? "Hoàn thành" : "Câu tiếp")
                          : (currentQuestionIndex == questions.length - 1 ? "Nộp bài" : "Câu tiếp"),
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
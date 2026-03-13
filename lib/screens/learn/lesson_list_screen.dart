import 'package:flutter/material.dart';
import 'package:learn_math_app_03/screens/learn/game/flash_card.dart';
import 'package:learn_math_app_03/screens/learn/game/match_card.dart';
import 'package:learn_math_app_03/screens/learn/game/quiz_card.dart';
import '../../theme/app_colors.dart';

class LessonListScreen extends StatefulWidget {
  final String chapterTitle;
  final String chapterSubtitle;
  final String progressText;
  final Color themeColor;

  const LessonListScreen({
    super.key,
    required this.chapterTitle,
    required this.chapterSubtitle,
    required this.progressText,
    required this.themeColor,
  });

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  // Quản lý dữ liệu và trạng thái của các bài học
  List<Map<String, dynamic>> lessons = [
    {
      "number": 1,
      "title": "Phương trình bậc 2",
      "subtitle": "Công thức nghiệm và ứng dụng",
      "flashcardsCompleted": true, // Đã học
      "interactiveCompleted": true, // Đã học
      "matchingCompleted": false, // Chưa học
      "isActive": true,
    },
    {
      "number": 2,
      "title": "Định lý Vi-et",
      "subtitle": "Mối liên hệ giữa nghiệm và hệ số",
      "flashcardsCompleted": true,
      "interactiveCompleted": false,
      "matchingCompleted": false,
      "isActive": true,
    },
    {
      "number": 3,
      "title": "Công thức nghiệm",
      "subtitle": "Delta và các dạng bài tập",
      "flashcardsCompleted": false,
      "interactiveCompleted": false,
      "matchingCompleted": false,
      "isActive": false, // Khóa vì chưa học tới
    },
  ];

  String _calculateProgress(Map<String, dynamic> lesson) {
    int total = 3;
    int completed = 0;
    if (lesson["flashcardsCompleted"]) completed++;
    if (lesson["interactiveCompleted"]) completed++;
    if (lesson["matchingCompleted"]) completed++;
    return "$completed/$total";
  }

  void _playGame(int lessonIndex, String gameType, String gameName) async {
    dynamic destination;

    switch (gameType) {
      case "flashcardsCompleted":
        destination = const FlashcardGameScreen();
        break;

      case "interactiveCompleted":
        destination = const QuizGameScreen();

      default:
        destination = const MatchCardGameScreen();
    }

    // Thực hiện chuyển màn hình
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );

    // Cập nhật trạng thái hoàn thành nếu chơi xong
    if (result == true) {
      setState(() {
        lessons[lessonIndex][gameType] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HEADER THÔNG TIN CHƯƠNG
            // ==========================================
            Container(
              width: double.infinity,
              color: widget.themeColor,
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chapterTitle,
                    style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.chapterSubtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.progressText,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. DANH SÁCH BÀI HỌC
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: List.generate(lessons.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildLessonCard(
                      index: index,
                      lessonData: lessons[index],
                      themeColor: widget.themeColor,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CẬP NHẬT: GIAO DIỆN THẺ BÀI HỌC (SỬA NỀN TRONG SUỐT VÀ PHÂN SỐ)
  // ==========================================
  Widget _buildLessonCard({
    required int index,
    required Map<String, dynamic> lessonData,
    required Color themeColor,
  }) {
    bool isActive = lessonData["isActive"];

    // NẾU ACTIVE: Nền thẻ là màu chủ đạo trong suốt (0.05), viền là màu chủ đạo (0.4)
    // NẾU INACTIVE: Nền thẻ là xám trong suốt, viền xám nhạt
    Color cardBgColor = isActive ? themeColor.withOpacity(0.05) : Colors.grey.shade200.withOpacity(0.4);
    Color cardBorderColor = isActive ? themeColor.withOpacity(0.4) : Colors.grey.shade300;
    Color numberBgColor = isActive ? themeColor : Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor, // Đã đổi màu nền thành màu trong suốt của viền
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CỘT TRÁI: Số thứ tự + Đường kẻ dọc
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: numberBgColor, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  lessonData["number"].toString(),
                  style: TextStyle(color: isActive ? AppColors.white : Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (isActive) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 28.0),
                  child: Container(
                    width: 1.5,
                    height: 40,
                    color: cardBorderColor,
                  ),
                ),
              ]
            ],
          ),
          const SizedBox(width: 16),

          // CỘT GIỮA: Tiêu đề + Các Tag Game
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    lessonData["title"],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isActive ? Colors.black87 : Colors.grey.shade500)
                ),
                const SizedBox(height: 4),
                Text(
                    lessonData["subtitle"],
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500)
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildGameTag(
                      text: "Flashcards",
                      isCompleted: lessonData["flashcardsCompleted"],
                      isActive: isActive,
                      onTap: () => _playGame(index, "flashcardsCompleted", "Lật thẻ Flashcard"),
                    ),
                    _buildGameTag(
                      text: "Học tương tác",
                      isCompleted: lessonData["interactiveCompleted"],
                      isActive: isActive,
                      onTap: () => _playGame(index, "interactiveCompleted", "Học tương tác"),
                    ),
                    _buildGameTag(
                      text: "Ghép thẻ",
                      isCompleted: lessonData["matchingCompleted"],
                      isActive: isActive,
                      onTap: () => _playGame(index, "matchingCompleted", "Ghép thẻ"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // CỘT PHẢI: Phân số tiến độ (Luôn hiển thị) + Icon mũi tên
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? themeColor : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _calculateProgress(lessonData),
                  style: TextStyle(color: isActive ? AppColors.white : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          )
        ],
      ),
    );
  }

  // ==========================================
  // TAG GAME (Hình viên thuốc)
  // ==========================================
  // ==========================================
  // CẬP NHẬT: TAG GAME (Chữ nhỏ hơn cho giống thiết kế)
  // ==========================================
  Widget _buildGameTag({
    required String text,
    required bool isCompleted,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    Color iconColor;
    Color textColor;
    Color bgColor;
    Color borderColor;

    if (isCompleted) {
      iconColor = AppColors.green;
      textColor = AppColors.green;
      bgColor = AppColors.green.withOpacity(0.08);
      borderColor = AppColors.green.withOpacity(0.4);
    } else if (isActive) {
      iconColor = Colors.grey.shade600;
      textColor = Colors.grey.shade600;
      bgColor = AppColors.white;
      borderColor = Colors.grey.shade300;
    } else {
      iconColor = Colors.grey.shade400;
      textColor = Colors.grey.shade400;
      bgColor = Colors.transparent;
      borderColor = Colors.grey.shade200;
    }

    IconData icon = isCompleted ? Icons.check_circle_outline : Icons.radio_button_unchecked;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: isActive ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // GIẢM padding dọc xuống 4
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 14), // GIẢM kích thước icon từ 16 xuống 14
              const SizedBox(width: 4), // GIẢM khoảng cách giữa icon và chữ
              Text(
                text,
                style: TextStyle(
                    fontSize: 10.5, // GIẢM cỡ chữ từ 12 xuống 10.5
                    color: textColor,
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MÀN HÌNH TRÒ CHƠI GIẢ LẬP (MOCK GAME SCREEN)
// ============================================================================
class MockGameScreen extends StatelessWidget {
  final String gameName;
  final Color themeColor;

  const MockGameScreen({super.key, required this.gameName, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gameName, style: const TextStyle(color: Colors.white)),
        backgroundColor: themeColor,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videogame_asset, size: 80, color: themeColor),
            const SizedBox(height: 20),
            Text("Đang chơi: $gameName", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("HOÀN THÀNH BÀI HỌC", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:learn_math_app_03/data/models/lesson_model.dart';
import 'package:learn_math_app_03/data/services/lesson_service.dart';
import '../../../core/theme/app_colors.dart';
import 'game/flash_card.dart';
import 'game/match_card.dart';
import 'game/quiz_card.dart';

class LessonListScreen extends StatefulWidget {
  final int chapterId;
  final String chapterTitle;
  final String chapterSubtitle;
  final String progressText;
  final Color themeColor;

  const LessonListScreen({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterSubtitle,
    required this.progressText,
    required this.themeColor,
  });

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final LessonService _learnService = LessonService();
  bool _isLoading = true;
  bool _hasError = false;
  List<LessonModel> _lessons = [];

  // TODO: Thay userId bằng ID thật
  final int _currentUserId = 2;

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _learnService.getLessonsOverview(_currentUserId, widget.chapterId);
      if (mounted) {
        setState(() {
          _lessons = result;
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

  void _playGame(int lessonIndex, String gameType, String gameName) async {
    dynamic destination;

    int currentLessonId = _lessons[lessonIndex].lessonId;

    switch (gameType) {
      case "flashcardsCompleted":
        destination = FlashcardGameScreen(lessonId: currentLessonId);
        break;
      case "interactiveCompleted":
        destination = QuizGameScreen(lessonId: currentLessonId);
        break;
      default:
        destination = MatchCardGameScreen(lessonId: currentLessonId);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );

    // Cập nhật trạng thái giả lập trên UI nếu chơi xong
    // (Sau này bạn cần gọi thêm API để lưu trạng thái này lên Database)
    if (result == true) {
      setState(() {
        if (gameType == "flashcardsCompleted") _lessons[lessonIndex].isFlashcardDone = true;
        if (gameType == "interactiveCompleted") _lessons[lessonIndex].isQuestionDone = true;
        if (gameType == "matchingCompleted") _lessons[lessonIndex].isMatchCardDone = true;
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
            // HEADER THÔNG TIN CHƯƠNG (Giữ nguyên)
            Container(
              width: double.infinity,
              color: widget.themeColor,
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chapterTitle, style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.chapterSubtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 16),
                  Text(widget.progressText, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            // DANH SÁCH BÀI HỌC DYNAMIC
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: _buildLessonsBody(),
            ),
          ],
        ),
      ),
    );
  }

  // Khối logic hiển thị trạng thái API
  Widget _buildLessonsBody() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator(color: widget.themeColor)),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text("Không thể tải danh sách bài học", style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(onPressed: _fetchLessons, child: Text("Thử lại", style: TextStyle(color: widget.themeColor)))
            ],
          ),
        ),
      );
    }

    if (_lessons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text("Chưa có bài học nào trong chương này.", style: TextStyle(color: Colors.grey.shade500)),
        ),
      );
    }

    return Column(
      children: _lessons.asMap().entries.map((entry) {
        int index = entry.key;
        LessonModel lesson = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildLessonCard(
            index: index,
            lessonData: lesson,
            themeColor: widget.themeColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLessonCard({
    required int index,
    required LessonModel lessonData,
    required Color themeColor,
  }) {
    // Cho phép tất cả đều sáng (Active) vì backend chưa có trường khoá bài học
    bool isActive = true;

    Color cardBgColor = isActive ? themeColor.withOpacity(0.05) : Colors.grey.shade200.withOpacity(0.4);
    Color cardBorderColor = isActive ? themeColor.withOpacity(0.4) : Colors.grey.shade300;
    Color numberBgColor = isActive ? themeColor : Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SỐ THỨ TỰ
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: numberBgColor, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  (index + 1).toString(), // Dùng index + 1 làm số bài
                  style: TextStyle(color: isActive ? AppColors.white : Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (isActive) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 28.0),
                  child: Container(width: 1.5, height: 40, color: cardBorderColor),
                ),
              ]
            ],
          ),
          const SizedBox(width: 16),

          // NỘI DUNG CHÍNH
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lessonData.lessonName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isActive ? Colors.black87 : Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text(lessonData.description, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildGameTag(
                      text: "Flashcards",
                      isCompleted: lessonData.isFlashcardDone,
                      isActive: isActive,
                      onTap: () => _playGame(index, "flashcardsCompleted", "Lật thẻ Flashcard"),
                    ),
                    _buildGameTag(
                      text: "Học tương tác",
                      isCompleted: lessonData.isQuestionDone,
                      isActive: isActive,
                      onTap: () => _playGame(index, "interactiveCompleted", "Học tương tác"),
                    ),
                    _buildGameTag(
                      text: "Ghép thẻ",
                      isCompleted: lessonData.isMatchCardDone,
                      isActive: isActive,
                      onTap: () => _playGame(index, "matchingCompleted", "Ghép thẻ"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // TIẾN ĐỘ THEO CHUẨN 3 GAME
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: isActive ? themeColor : Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  "${lessonData.completedGamesCount}/3", // Tối đa 3 game con
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

  // WIDGET TAG GAME
  Widget _buildGameTag({
    required String text,
    required bool isCompleted,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    Color iconColor = isCompleted ? AppColors.green : (isActive ? Colors.grey.shade600 : Colors.grey.shade400);
    Color textColor = isCompleted ? AppColors.green : (isActive ? Colors.grey.shade600 : Colors.grey.shade400);
    Color bgColor = isCompleted ? AppColors.green.withOpacity(0.08) : (isActive ? AppColors.white : Colors.transparent);
    Color borderColor = isCompleted ? AppColors.green.withOpacity(0.4) : (isActive ? Colors.grey.shade300 : Colors.grey.shade200);
    IconData icon = isCompleted ? Icons.check_circle_outline : Icons.radio_button_unchecked;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: isActive ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor, width: 1.0)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Text(text, style: TextStyle(fontSize: 10.5, color: textColor, fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
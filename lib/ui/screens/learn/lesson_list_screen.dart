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

  final int userId;
  final int gradeId;

  const LessonListScreen({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterSubtitle,
    required this.progressText,
    required this.themeColor,

    required this.userId,
    required this.gradeId,
  });

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final LessonService _learnService = LessonService();
  bool _isLoading = true;
  bool _hasError = false;
  List<LessonModel> _lessons = [];

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
      final result = await _learnService.getLessonsOverview(widget.userId, widget.chapterId);
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
        destination = FlashcardGameScreen(lessonId: currentLessonId, userId: widget.userId,);
        break;
      case "interactiveCompleted":
        destination = QuizGameScreen(lessonId: currentLessonId, userId: widget.userId);
        break;
      default:
        destination = MatchCardGameScreen(lessonId: currentLessonId, userId: widget.userId);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );

    // Cập nhật trạng thái giả lập trên UI nếu chơi xong
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
            // HEADER THÔNG TIN CHƯƠNG
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
          padding: const EdgeInsets.only(bottom: 24),
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
    bool isActive = true;

    // Đổi nền trắng của ô thành màu tím trong suốt (opacity 0.15)
    Color cardBgColor = isActive ? themeColor.withOpacity(0.15) : Colors.grey.shade200.withOpacity(0.4);
    Color cardBorderColor = isActive ? themeColor.withOpacity(0.3) : Colors.grey.shade300;

    Color numberBgColor = isActive ? AppColors.white : Colors.grey.shade300;
    Color numberBorderColor = isActive ? themeColor : Colors.grey.shade300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // CỘT SỐ THỨ TỰ & ĐƯỜNG KẺ DỌC
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: numberBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: numberBorderColor, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  (index + 1).toString(),
                  style: TextStyle(color: isActive ? themeColor : Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (isActive) ...[
                const SizedBox(height: 8),
                Expanded(
                  child: Container(width: 1.5, color: cardBorderColor),
                ),
                const SizedBox(height: 8),
              ]
            ],
          ),
          const SizedBox(width: 16),

          // NỘI DUNG CHÍNH CỦA CARD
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBgColor, // Sử dụng nền tím trong suốt ở đây
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardBorderColor, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DÒNG 1: Tiêu đề và Tiến độ (2/3)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                            lessonData.lessonName,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isActive ? Colors.black87 : Colors.grey.shade500)
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Nút tiến độ 2/3 (Đổi nền sang trắng)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.white, // Nền trắng
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(
                          "${lessonData.completedGamesCount}/3",
                          style: TextStyle(color: themeColor, fontSize: 13, fontWeight: FontWeight.bold), // Chữ màu tím
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // DÒNG 2: Phụ đề
                  Text(
                      lessonData.description,
                      style: TextStyle(fontSize: 14, color: Colors.black54)
                  ),
                  const SizedBox(height: 16),

                  // DÒNG 3: DANH SÁCH GAME XẾP DỌC
                  Column(
                    children: [
                      _buildGameOption(
                        title: "Flashcard",
                        iconData: Icons.style,
                        isCompleted: lessonData.isFlashcardDone,
                        themeColor: themeColor,
                        onTap: () => _playGame(index, "flashcardsCompleted", "Lật thẻ"),
                      ),
                      _buildGameOption(
                        title: "Quiz",
                        iconData: Icons.auto_awesome,
                        isCompleted: lessonData.isQuestionDone,
                        themeColor: themeColor,
                        onTap: () => _playGame(index, "interactiveCompleted", "Học tương tác"),
                      ),
                      _buildGameOption(
                        title: "MatchCard",
                        iconData: Icons.ads_click,
                        isCompleted: lessonData.isMatchCardDone,
                        themeColor: themeColor,
                        onTap: () => _playGame(index, "matchingCompleted", "Ghép thẻ"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET GIAO DIỆN NÚT BẤM GAME
  Widget _buildGameOption({
    required String title,
    required IconData iconData,
    required bool isCompleted,
    required Color themeColor,
    required VoidCallback onTap,
  }) {
    // Nếu chưa hoàn thành (isCompleted == false):
    // Đổi item đang tím thành nền trắng (AppColors.white)
    // Và chữ trắng thành chữ tím (themeColor) để dễ nhìn
    final Color bgColor = isCompleted ? const Color(0xFFE6F9F0) : AppColors.white;
    final Color contentColor = isCompleted ? const Color(0xFF00A86B) : themeColor;
    final IconData trailingIcon = isCompleted ? Icons.check_circle_outline : Icons.chevron_right;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon bên trái
                Icon(iconData, color: contentColor, size: 20),
                const SizedBox(width: 12),

                // Tiêu đề game
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: contentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Icon trạng thái bên phải
                Icon(trailingIcon, color: contentColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
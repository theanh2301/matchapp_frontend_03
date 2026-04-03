import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/models/suggest_lesson_model.dart';
import '../../../data/services/subject_service.dart';
import '../../../data/services/suggest_lesson_service.dart';
import 'chapter_list_screen.dart';
import 'game/flash_card.dart';
import 'game/match_card.dart';
import 'game/quiz_card.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final List<String> _grades = ['Lớp 6', 'Lớp 7', 'Lớp 8', 'Lớp 9', 'Lớp 10', 'Lớp 11', 'Lớp 12'];
  int _selectedGradeIndex = 0; // Mặc định Lớp 10

  // --- SERVICE & TRẠNG THÁI MÔN HỌC ---
  final SubjectService _learnService = SubjectService();
  bool _isLoading = true;
  bool _hasError = false;
  List<SubjectModel> _subjects = [];

  // --- SERVICE & TRẠNG THÁI GỢI Ý HỌC TẬP ---
  final SuggestedLessonService _suggestedService = SuggestedLessonService();
  bool _isLoadingSuggested = true;
  bool _hasErrorSuggested = false;
  List<SuggestedLessonModel> _suggestedLessons = [];

  // TODO: Thay userId = 1 bằng ID thật của user đang đăng nhập
  final int _currentUserId = 3;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  // Hàm gọi đồng thời hoặc lần lượt các API cần thiết
  Future<void> _fetchAllData() async {
    await _fetchSubjects();
    await _fetchSuggestedLessons();
  }

  Future<void> _fetchSubjects() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      int subjectClass = _selectedGradeIndex + 6;
      final result = await _learnService.getSubjectsProgress(_currentUserId, subjectClass);

      if (mounted) {
        setState(() {
          _subjects = result;
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
      debugPrint("API Error (Subjects): $e");
    }
  }

  Future<void> _fetchSuggestedLessons() async {
    setState(() {
      _isLoadingSuggested = true;
      _hasErrorSuggested = false;
    });

    try {
      // TODO: Ở đây mình truyền tạm subjectId = 5 theo API bạn cung cấp.
      // Nếu bạn muốn lấy id của môn học đầu tiên trong danh sách _subjects,
      // bạn có thể đổi thành: int targetSubjectId = _subjects.isNotEmpty ? _subjects.first.subjectId : 5;
      int targetSubjectId = 5;

      final result = await _suggestedService.getSuggestedLessons(_currentUserId, targetSubjectId);

      if (mounted) {
        setState(() {
          _suggestedLessons = result;
          _isLoadingSuggested = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasErrorSuggested = true;
          _isLoadingSuggested = false;
        });
      }
      debugPrint("API Error (Suggested Lessons): $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HEADER & CHỌN LỚP
            // ==========================================
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Học tập", style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Chọn khối lớp để xem tiến độ", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 20),

                  // Thanh chọn lớp
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _grades.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedGradeIndex == index;
                        return GestureDetector(
                          onTap: () {
                            if (!isSelected) {
                              setState(() => _selectedGradeIndex = index);
                              _fetchAllData(); // Gọi lại khi đổi lớp
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.white : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _grades[index],
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : AppColors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. DANH SÁCH CHỦ ĐỀ HOẶC THÔNG BÁO LỖI
            // ==========================================
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildBodyContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Column(
            children: [
              Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text("Không thể kết nối đến máy chủ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Vui lòng kiểm tra lại kết nối mạng của bạn.", style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchAllData,
                icon: const Icon(Icons.refresh),
                label: const Text("Thử lại"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              )
            ],
          ),
        ),
      );
    }

    if (_subjects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Text("Chưa có môn học nào cho khối lớp này.", style: TextStyle(color: Colors.grey.shade600)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Môn học", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        ..._subjects.map((subject) {
          Color iconColor = AppColors.primary;
          IconData iconData = Icons.calculate_outlined;

          if (subject.subjectName.toLowerCase().contains("lý") || subject.subjectName.toLowerCase().contains("vật")) {
            iconColor = AppColors.orangeFire;
            iconData = Icons.bolt;
          } else if (subject.subjectName.toLowerCase().contains("hóa")) {
            iconColor = AppColors.green;
            iconData = Icons.science;
          } else if (subject.subjectName.toLowerCase().contains("toán")) {
            iconColor = AppColors.primary;
            iconData = Icons.functions;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTopicCard(
              title: subject.subjectName,
              subtitle: "${subject.completedLessons}/${subject.totalLessons} bài • ⭐ ${subject.earnedXp}/${subject.totalXp} XP",
              progress: subject.progress,
              icon: iconData,
              iconBgColor: iconColor,
              data: subject,
              earnedXp: subject.earnedXp,
              totalLesson: subject.totalLessons,
            ),
          );
        }).toList(),

        const SizedBox(height: 30),

        const Text("Lộ trình học tập (Gợi ý)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // ==========================================
        // KHU VỰC HIỂN THỊ GỢI Ý TỪ API
        // ==========================================
        _buildSuggestedLessonsSection(),

        const SizedBox(height: 40),
      ],
    );
  }

  // Khối logic kết xuất danh sách gợi ý
  Widget _buildSuggestedLessonsSection() {
    if (_isLoadingSuggested) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_hasErrorSuggested) {
      return Center(
        child: Column(
          children: [
            const Text("Lỗi tải gợi ý học tập", style: TextStyle(color: Colors.red)),
            TextButton(
              onPressed: _fetchSuggestedLessons,
              child: const Text("Tải lại gợi ý"),
            )
          ],
        ),
      );
    }

    if (_suggestedLessons.isEmpty) {
      return const Text("Không có bài học gợi ý nào lúc này.", style: TextStyle(color: Colors.grey));
    }

    List<Widget> items = [];
    bool foundCurrent = false; // Biến đánh dấu đã tìm thấy bài học "đang học" chưa

    for (int i = 0; i < _suggestedLessons.length; i++) {
      final lesson = _suggestedLessons[i];
      TimelineStatus status;

      if (lesson.isCompleted) {
        // Đã học
        status = TimelineStatus.completed;
      } else if (!foundCurrent) {
        // Bài đầu tiên chưa học -> Đang học
        status = TimelineStatus.current;
        foundCurrent = true;
      } else {
        // Các bài chưa học phía sau -> Sắp học
        status = TimelineStatus.upcoming;
      }

      items.add(
        _buildTimelineItem(
          status: status,
          title: lesson.lessonName,
          subtitle: "Bài học gợi ý",
          number: (i + 1).toString(),
          isFirst: i == 0,
          isLast: i == _suggestedLessons.length - 1,

          // Thêm sự kiện onTap vào đây
          onTap: status != TimelineStatus.completed
              ? () => _showGameOptions(context, lesson)
              : null,
        ),
      );
    }

    return Column(children: items);
  }

  void _showGameOptions(BuildContext context, SuggestedLessonModel lesson) {
    // TODO: Khi API Backend cập nhật thêm các trường chi tiết cho bài gợi ý,
    // bạn hãy thay các biến false này bằng dữ liệu thật từ model nhé.
    // Ví dụ: bool isFlashcardDone = lesson.isFlashcardDone;
    bool isFlashcardDone = false;
    bool isQuizDone = false;
    bool isMatchDone = false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Tự động thu gọn theo nội dung
            children: [
              Text(
                "Học: ${lesson.lessonName}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const Text("Chọn phần bạn muốn học ngay", style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 24),

              // Nút 1: Flashcard
              _buildBottomSheetButton(
                title: "Flashcards",
                icon: Icons.style,
                color: const Color(0xFF6C47FF),
                isCompleted: isFlashcardDone, // Truyền trạng thái vào đây
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardGameScreen(lessonId: lesson.lessonId)));
                },
              ),
              const SizedBox(height: 12),

              // Nút 2: Học tương tác (Quiz)
              _buildBottomSheetButton(
                title: "Học tương tác",
                icon: Icons.auto_awesome,
                color: const Color(0xFF6C47FF),
                isCompleted: isQuizDone,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => QuizGameScreen(lessonId: lesson.lessonId)));
                },
              ),
              const SizedBox(height: 12),

              // Nút 3: Ghép thẻ
              _buildBottomSheetButton(
                title: "Ghép thẻ",
                icon: Icons.ads_click,
                color: const Color(0xFF6C47FF),
                isCompleted: isMatchDone,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MatchCardGameScreen(lessonId: lesson.lessonId)));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget con hỗ trợ tạo nút bấm trong BottomSheet đã được nâng cấp
  Widget _buildBottomSheetButton({
    required String title,
    required IconData icon,
    required Color color,
    required bool isCompleted, // Thêm tham số kiểm tra hoàn thành
    required VoidCallback onPressed,
  }) {
    // Nếu hoàn thành: Nền xanh nhạt, chữ và icon xanh lục.
    // Nếu chưa: Nền trắng, viền và chữ tím.
    final Color bgColor = isCompleted ? const Color(0xFFE6F9F0) : Colors.white;
    final Color contentColor = isCompleted ? const Color(0xFF00A86B) : color;
    final IconData trailingIcon = isCompleted ? Icons.check_circle : Icons.chevron_right;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: contentColor,
        elevation: 0,
        // Nếu đã hoàn thành thì bỏ viền, chưa hoàn thành thì hiện viền mờ
        side: BorderSide(
            color: isCompleted ? Colors.transparent : color.withOpacity(0.3),
            width: 1.5
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          Icon(trailingIcon), // Mũi tên hoặc Dấu tích
        ],
      ),
    );
  }

  Widget _buildTopicCard({
    required String title,
    required String subtitle,
    required double progress,
    required IconData icon,
    required Color iconBgColor,
    required SubjectModel data,
    required int totalLesson,
    required int earnedXp
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChapterListScreen(
              subjectId: data.subjectId,
              subjectName: title,
              progressText: subtitle,
              progressValue: progress,
              totalXP: data.totalXp,
              themeColor: iconBgColor,
              subjectIcon: icon,
              earnedXP: earnedXp,
              totalLessons: totalLesson,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    color: iconBgColor,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required TimelineStatus status,
    required String title,
    required String subtitle,
    String? number,
    bool isFirst = false,
    bool isLast = false,
    VoidCallback? onTap, // Thêm tham số onTap
  }) {
    Color borderColor;
    Color bgColor;

    switch (status) {
      case TimelineStatus.completed:
        borderColor = AppColors.green;
        bgColor = AppColors.green.withOpacity(0.05);
        break;
      case TimelineStatus.current:
        borderColor = AppColors.primary;
        bgColor = AppColors.white;
        break;
      case TimelineStatus.upcoming:
      default:
        borderColor = Colors.grey.shade300;
        bgColor = AppColors.white;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Expanded(flex: 1, child: Container(width: 2, color: isFirst ? Colors.transparent : Colors.grey.shade300)),
                    Expanded(flex: 1, child: Container(width: 2, color: isLast ? Colors.transparent : Colors.grey.shade300)),
                  ],
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: status == TimelineStatus.completed ? AppColors.green : (status == TimelineStatus.current ? AppColors.primary : Colors.grey.shade200),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: status == TimelineStatus.completed
                      ? const Icon(Icons.check, color: AppColors.white, size: 16)
                      : Text(number ?? "", style: TextStyle(color: status == TimelineStatus.current ? AppColors.white : Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Thẻ nội dung có thể bấm được
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap, // Gọi hàm sự kiện khi bấm
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.5),
                      boxShadow: status == TimelineStatus.current ? [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều dọc
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: status == TimelineStatus.upcoming ? Colors.grey.shade600 : Colors.black87)),
                              const SizedBox(height: 4),
                              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        // Nút "Đang học" HOẶC Icon Play
                        if (status == TimelineStatus.current)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                            child: const Text("Đang học", style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),

                        // Thêm Icon điều hướng cho các mục chưa hoàn thành
                        if (status != TimelineStatus.completed)
                          Icon(Icons.play_circle_fill, color: AppColors.primary.withOpacity(0.8), size: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum TimelineStatus { completed, current, upcoming }
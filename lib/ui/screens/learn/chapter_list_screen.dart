import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/services/chapter_service.dart';
import 'lesson_list_screen.dart';

class ChapterListScreen extends StatefulWidget {
  final int subjectId;
  final String subjectName;
  final String progressText;
  final double progressValue;
  final int totalXP;
  final int earnedXP;
  final Color themeColor;
  final IconData subjectIcon;
  final int totalLessons;

  const ChapterListScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.progressText,
    required this.progressValue,
    required this.totalXP,
    required this.earnedXP,
    required this.themeColor,
    required this.subjectIcon,
    required this.totalLessons
  });

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> {
  final ChapterService _learnService = ChapterService();
  bool _isLoading = true;
  bool _hasError = false;
  List<ChapterModel> _chapters = [];

  // TODO: Thay userId = 2 bằng ID thật của user đang đăng nhập
  final int _currentUserId = 2;

  @override
  void initState() {
    super.initState();
    _fetchChapters();
  }

  Future<void> _fetchChapters() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      debugPrint("🚀 Đang gọi API Chapters với userId=$_currentUserId và subjectId=${widget.subjectId}");
      final result = await _learnService.getChaptersOverview(_currentUserId, widget.subjectId);

      if (mounted) {
        setState(() {
          _chapters = result;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HEADER KHỐI MÀU TRÊN CÙNG (Giữ nguyên giao diện cũ của bạn)
            // ==========================================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [widget.themeColor, widget.themeColor.withOpacity(0.8)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.only(top: 50, left: 16, right: 24, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(widget.subjectIcon, color: AppColors.white.withOpacity(0.5), size: 48),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.subjectName, style: const TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(widget.progressText, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: widget.progressValue,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.yellowAccent, size: 16),
                              const SizedBox(width: 6),
                              Text("${widget.earnedXP}/${widget.totalXP} XP", style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              const Icon(Icons.menu_book, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text("${widget.totalLessons} bài", style: const TextStyle(color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // ==========================================
            // 2. DANH SÁCH CÁC CHƯƠNG (BODY DYNAMIC)
            // ==========================================
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Danh sách chương", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),
                  _buildChapterBody(), // Gọi hàm build nội dung
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm xử lý hiển thị Loading / Lỗi / Danh sách
  Widget _buildChapterBody() {
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
              const Text("Không thể tải danh sách chương", style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: _fetchChapters,
                child: Text("Thử lại", style: TextStyle(color: widget.themeColor)),
              )
            ],
          ),
        ),
      );
    }

    if (_chapters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text("Chưa có chương nào trong môn học này.", style: TextStyle(color: Colors.grey.shade500)),
        ),
      );
    }

    // Hiển thị danh sách động từ API
    return Column(
      children: _chapters.asMap().entries.map((entry) {
        int index = entry.key;
        ChapterModel chapter = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildChapterItem(
            data: chapter,
            context: context,
            number: index + 1,
            title: chapter.chapterName,
            subtitle: chapter.description,
            completedLessons: chapter.completedLessons,
            totalLessons: chapter.totalLessons,
            earnedXP: chapter.earnedXp,
            totalXP: chapter.totalPossibleXp,
            themeColor: widget.themeColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChapterItem({
    required BuildContext context,
    required int number,
    required String title,
    required String subtitle,
    required int completedLessons,
    required int totalLessons,
    required int earnedXP,
    required int totalXP,
    required Color themeColor,
    required ChapterModel data,
  }) {
    double progressValue = totalLessons > 0 ? completedLessons / totalLessons : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonListScreen(
              chapterId: data.chapterId,
              chapterTitle: title,
              chapterSubtitle: subtitle,
              progressText: "$completedLessons/$totalLessons bài hoàn thành",
              themeColor: themeColor,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(16)),
              alignment: Alignment.center,
              child: Text(number.toString(), style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text("$completedLessons/$totalLessons bài", style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text("$earnedXP/$totalXP XP", style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
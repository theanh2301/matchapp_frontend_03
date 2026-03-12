import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'lesson_list_screen.dart';

class ChapterListScreen extends StatelessWidget {
  final String subjectName;
  final String progressText;
  final double progressValue;
  final int totalXP;
  final int totalChapters;
  final Color themeColor;
  final IconData subjectIcon;

  const ChapterListScreen({
    super.key,
    required this.subjectName,
    required this.progressText,
    required this.progressValue,
    required this.totalXP,
    required this.totalChapters,
    required this.themeColor,
    required this.subjectIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: themeColor,
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
            // 1. HEADER KHỐI MÀU TRÊN CÙNG
            // ==========================================
            Container(
              width: double.infinity,
              color: themeColor,
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(subjectIcon, color: AppColors.white, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subjectName,
                            style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            progressText,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Thanh tiến độ
                  LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    color: AppColors.white,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 16),

                  // Chỉ số thống kê (XP, Chương)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 16),
                      const SizedBox(width: 4),
                      Text("$totalXP XP", style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      const Icon(Icons.menu_book, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text("$totalChapters chương", style: const TextStyle(color: Colors.white70)),
                    ],
                  )
                ],
              ),
            ),

            // ==========================================
            // 2. DANH SÁCH CÁC CHƯƠNG (BODY)
            // ==========================================
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Danh sách chương",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),

                  // Dữ liệu mẫu tĩnh - Sau này bạn thay bằng dữ liệu lấy từ API
                  _buildChapterItem(
                    context: context,
                    number: 1,
                    title: "Phương trình và bất phương trình",
                    subtitle: "Các dạng phương trình cơ bản và nâng cao",
                    progressText: "0/3 bài",
                    progressValue: 0.0,
                    themeColor: themeColor,
                  ),
                  const SizedBox(height: 16),
                  _buildChapterItem(
                    context: context,
                    number: 2,
                    title: "Hệ phương trình",
                    subtitle: "Phương pháp giải hệ phương trình",
                    progressText: "0/2 bài",
                    progressValue: 0.0,
                    themeColor: themeColor,
                  ),
                  const SizedBox(height: 16),
                  _buildChapterItem(
                    context: context,
                    number: 3,
                    title: "Bất phương trình",
                    subtitle: "Giải và biện luận bất phương trình",
                    progressText: "0/1 bài",
                    progressValue: 0.0,
                    themeColor: themeColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget con: Hiển thị từng chương học
  Widget _buildChapterItem({
    required BuildContext context,
    required int number,
    required String title,
    required String subtitle,
    required String progressText,
    required double progressValue,
    required Color themeColor,
  }) {
    return GestureDetector(
      onTap: () {
        // Khi bấm vào 1 chương -> Chuyển sang màn hình danh sách bài học (Lessons)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonListScreen(
              chapterTitle: title,
              chapterSubtitle: subtitle,
              progressText: "0/3 bài hoàn thành",
              themeColor: themeColor,
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
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Cột đánh số thứ tự chương
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                number.toString(),
                style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            // Cột nội dung chương
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(progressText, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.grey.shade200,
                          color: themeColor,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'lesson_list_screen.dart';

class ChapterListScreen extends StatelessWidget {
  final String subjectName;
  final String progressText;
  final double progressValue;
  final int totalXP;
  final int earnedXP;
  final int totalChapters;
  final Color themeColor;
  final IconData subjectIcon;

  const ChapterListScreen({
    super.key,
    required this.subjectName,
    required this.progressText,
    required this.progressValue,
    required this.totalXP,
    this.earnedXP = 1200,
    required this.totalChapters,
    required this.themeColor,
    required this.subjectIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HEADER KHỐI MÀU TRÊN CÙNG
            // ==========================================
            Container(
              width: double.infinity,
              // Sử dụng Gradient để màu sắc có chiều sâu như trong thiết kế
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [themeColor, themeColor.withOpacity(0.8)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.only(top: 50, left: 16, right: 24, bottom: 30), // Top 50 để cách Status Bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nút Trở Lại
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 8),

                  // Khối Icon và Tiêu đề
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0), // Canh lề nhẹ với nút back
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều dọc
                      children: [
                        // Icon Môn Học
                        Icon(subjectIcon, color: AppColors.white.withOpacity(0.5), size: 48), // Hình mờ nhẹ
                        const SizedBox(width: 16),

                        // Tiêu đề & Tiến độ
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subjectName,
                                style: const TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                progressText,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Thanh tiến độ lớn
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chỉ số thống kê (XP, Chương) dạng Badge
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        // Badge XP
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.yellowAccent, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                "$earnedXP/$totalXP XP",
                                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Badge Số chương
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.menu_book, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                "$totalChapters chương",
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
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

                  _buildChapterItem(
                    context: context,
                    number: 1,
                    title: "Phương trình và bất phương trình",
                    subtitle: "Các dạng phương trình cơ bản và nâng cao",
                    completedLessons: 0,
                    totalLessons: 3,
                    earnedXP: 300,
                    totalXP: 600,
                    themeColor: themeColor,
                  ),
                  const SizedBox(height: 16),
                  _buildChapterItem(
                    context: context,
                    number: 2,
                    title: "Hệ phương trình",
                    subtitle: "Phương pháp giải hệ phương trình",
                    completedLessons: 0,
                    totalLessons: 2,
                    earnedXP: 0,
                    totalXP: 600,
                    themeColor: themeColor,
                  ),
                  const SizedBox(height: 16),
                  _buildChapterItem(
                    context: context,
                    number: 3,
                    title: "Bất phương trình",
                    subtitle: "Giải và biện luận bất phương trình",
                    completedLessons: 0,
                    totalLessons: 1,
                    earnedXP: 0,
                    totalXP: 600,
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

  // CẬP NHẬT: Widget hiển thị từng chương theo thiết kế mới
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
  }) {
    double progressValue = totalLessons > 0 ? completedLessons / totalLessons : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonListScreen(
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
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CỘT SỐ THỨ TỰ (Ô vuông bo góc)
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                number.toString(),
                style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),

            // 2. CỘT NỘI DUNG CHÍNH
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề & Icon mũi tên
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Để icon nằm ngang với dòng đầu tiên của title dài
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Phụ đề
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),

                  // Thông số: Số bài & XP
                  Row(
                    children: [
                      Text(
                        "$completedLessons/$totalLessons bài",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "$earnedXP/$totalXP XP",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Thanh tiến trình ngang
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
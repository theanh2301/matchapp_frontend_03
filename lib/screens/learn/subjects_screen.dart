import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'chapter_list_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final List<String> _grades = ['Lớp 6', 'Lớp 7', 'Lớp 8', 'Lớp 9', 'Lớp 10', 'Lớp 11', 'Lớp 12'];
  int _selectedGradeIndex = 4; // Mặc định chọn Lớp 10

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HEADER & CHỌN LỚP (Màu xanh dương)
            // ==========================================
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Học tập",
                    style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Chọn chủ đề để bắt đầu học",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
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
                            setState(() {
                              _selectedGradeIndex = index;
                            });
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
            // 2. DANH SÁCH CHỦ ĐỀ
            // ==========================================
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chủ đề",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildTopicCard(
                    title: "Đại số",
                    subtitle: "12/24 bài • ⭐ 1200 XP",
                    progress: 0.5,
                    icon: Icons.calculate_outlined,
                    iconBgColor: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildTopicCard(
                    title: "Hình học",
                    subtitle: "8/18 bài • ⭐ 800 XP",
                    progress: 0.45,
                    icon: Icons.architecture,
                    iconBgColor: AppColors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildTopicCard(
                    title: "Lượng giác",
                    subtitle: "5/15 bài • ⭐ 500 XP",
                    progress: 0.33,
                    icon: Icons.show_chart,
                    iconBgColor: AppColors.purple,
                  ),
                  const SizedBox(height: 12),
                  _buildTopicCard(
                    title: "Hàm số",
                    subtitle: "0/20 bài • ⭐ 0 XP",
                    progress: 0.0,
                    icon: Icons.lock_outline,
                    iconBgColor: Colors.orange.shade300,
                    isLocked: true,
                  ),

                  const SizedBox(height: 30),

                  // ==========================================
                  // 3. LỘ TRÌNH HỌC TẬP (TIMELINE)
                  // ==========================================
                  const Text(
                    "Lộ trình học tập",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildTimelineItem(
                    status: TimelineStatus.completed,
                    title: "Phương trình bậc 2",
                    subtitle: "Công thức nghiệm và ứng dụng",
                    isFirst: true,
                  ),
                  _buildTimelineItem(
                    status: TimelineStatus.completed,
                    title: "Định lý Vi-et",
                    subtitle: "Mối liên hệ giữa nghiệm và hệ số",
                  ),
                  _buildTimelineItem(
                    status: TimelineStatus.current,
                    title: "Công thức nghiệm",
                    subtitle: "Delta và các dạng bài tập",
                    number: "3",
                  ),
                  _buildTimelineItem(
                    status: TimelineStatus.upcoming,
                    title: "Hệ phương trình",
                    subtitle: "Phương pháp thế và cộng đại số",
                    number: "4",
                    isLast: true,
                  ),

                  const SizedBox(height: 40), // Spacing for bottom nav bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget con: Thẻ Chủ đề
  Widget _buildTopicCard({
    required String title,
    required String subtitle,
    required double progress,
    required IconData icon,
    required Color iconBgColor,
    bool isLocked = false,
  }) {
    return GestureDetector(
        onTap: () {
          if (!isLocked) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChapterListScreen(
                  subjectName: title,
                  progressText: subtitle,
                  progressValue: progress,
                  totalXP: 1200, // Truyền data giả lập
                  totalChapters: 3,
                  themeColor: iconBgColor,
                  subjectIcon: icon,
                ),
              ),
            );
          }
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
            // Icon Box
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
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  if (!isLocked) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      color: iconBgColor,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ]
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

  // Widget con: Một bước trong Lộ trình học tập (Timeline)
  Widget _buildTimelineItem({
    required TimelineStatus status,
    required String title,
    required String subtitle,
    String? number,
    bool isFirst = false,
    bool isLast = false,
  }) {
    // Xác định màu sắc dựa trên trạng thái
    Color borderColor;
    Color bgColor;
    Color iconColor;

    switch (status) {
      case TimelineStatus.completed:
        borderColor = AppColors.green;
        bgColor = AppColors.green.withOpacity(0.05);
        iconColor = AppColors.green;
        break;
      case TimelineStatus.current:
        borderColor = AppColors.primary;
        bgColor = AppColors.white;
        iconColor = AppColors.primary;
        break;
      case TimelineStatus.upcoming:
      default:
        borderColor = Colors.grey.shade300;
        bgColor = AppColors.white;
        iconColor = Colors.grey.shade400;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cột vẽ đường kẻ và hình tròn (Timeline Track)
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Đường kẻ dọc
                Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 2,
                        color: isFirst ? Colors.transparent : Colors.grey.shade300,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 2,
                        color: isLast ? Colors.transparent : Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
                // Hình tròn ở giữa
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
                      : Text(
                    number ?? "",
                    style: TextStyle(
                      color: status == TimelineStatus.current ? AppColors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Thẻ nội dung
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16), // Khoảng cách giữa các thẻ
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: status == TimelineStatus.current
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: status == TimelineStatus.upcoming ? Colors.grey.shade600 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    if (status == TimelineStatus.current)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Đang học",
                          style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enum quản lý trạng thái của Lộ trình học
enum TimelineStatus { completed, current, upcoming }
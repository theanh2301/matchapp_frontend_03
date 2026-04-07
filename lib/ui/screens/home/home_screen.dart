import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

import '../../../data/models/subject_progress_model.dart';
import '../../../data/services/subject_service.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final String className;
  final VoidCallback onNavigateToLearn;
  final VoidCallback onNavigateToPractice;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.className,
    required this.onNavigateToLearn,
    required this.onNavigateToPractice,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<SubjectProgressModel>> _progressFuture;

  // Khởi tạo Service để gọi API
  final SubjectService _subjectService = SubjectService();

  @override
  void initState() {
    super.initState();
    // Khởi tạo việc gọi API khi màn hình load
    _progressFuture = _subjectService.fetchSubjectProgress(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Thêm Scaffold để đảm bảo màn hình có nền chuẩn
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER (Phần màu xanh dương trên cùng)
            // ==========================================
            Container(
              padding: const EdgeInsets.only(
                top: 60, // Padding top cho thanh trạng thái
                left: 20,
                right: 20,
                bottom: 30,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Xin chào, ${widget.userName}! 👋",
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${widget.className} • Sẵn sàng học chưa?",
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Thẻ Streak & XP
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.orange, // Đảm bảo AppColors có màu này
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_fire_department,
                                color: AppColors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "7 ngày",
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Chuỗi học liên tiếp",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "450 XP",
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Điểm hôm nay",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. PHẦN GIỮA (Nền xám nhạt)
            // ==========================================
            Container(
              color: AppColors.bgLight, // Đảm bảo AppColors có màu này (ví dụ: Color(0xFFF5F7FA))
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thẻ Mục tiêu hôm nay
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.emoji_events, color: Color(0xFFE64A19), size: 24),
                                SizedBox(width: 8),
                                Text(
                                  "Thử thách hàng ngày",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "2/3 hoàn thành",
                                style: TextStyle(
                                  color: Color(0xFFE64A19),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 34),

                        _buildDailyTaskItem(
                          title: "Hoàn thành 3 bài Flashcard",
                          xp: "+50 XP",
                          isCompleted: true,
                        ),
                        const SizedBox(height: 20),
                        _buildDailyTaskItem(
                          title: "Đạt 80% độ chính xác",
                          xp: "+30 XP",
                          isCompleted: true,
                        ),
                        const SizedBox(height: 20),
                        _buildDailyTaskItem(
                          title: "Luyện tập 30 phút",
                          xp: "+40 XP",
                          isCompleted: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2 Nút Hành động nhanh
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          title: "Học bài mới",
                          subtitle: "12 bài đang chờ",
                          icon: Icons.psychology,
                          color: AppColors.green,
                          // 2. Gọi hàm callback khi bấm nút Học
                          onTap: widget.onNavigateToLearn,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickActionCard(
                          title: "Luyện tập",
                          subtitle: "8 bài tập mới",
                          icon: Icons.bolt,
                          color: AppColors.purple,
                          // 3. Gọi hàm callback khi bấm nút Luyện tập
                          onTap: widget.onNavigateToPractice,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==========================================
            // 3. PHẦN CUỐI (Tích hợp API)
            // ==========================================
            Container(
              padding: const EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: 40,
              ),
              decoration: const BoxDecoration(
                color: AppColors.bgLight, // Kế thừa nền của phần trên để mượt mà
              ),
              child: Column(
                children: [
                  // Khối trắng "Tiếp tục học"
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tiếp tục học",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.trending_up, color: AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Render dữ liệu từ API
                        FutureBuilder<List<SubjectProgressModel>>(
                          future: _progressFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    "Lỗi tải dữ liệu: ${snapshot.error}",
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text("Bạn chưa có tiến độ học tập nào."),
                                ),
                              );
                            }

                            final progressList = snapshot.data!;
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: progressList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = progressList[index];
                                // Luân phiên màu sắc giữa primary và green
                                final color = index % 2 == 0 ? AppColors.primary : AppColors.green;

                                return _buildSubjectProgressCard(
                                  item.subjectName.toUpperCase(), // VD: "ĐẠI SỐ"
                                  item.chapterName,               // VD: "Phương trình bậc 2"
                                  item.lessonName,                // VD: "Bài 3: Công thức nghiệm"
                                  item.completionPercent / 100,   // API trả 70 -> thành 0.7
                                  color,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Thẻ AI Gợi ý
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.pink, AppColors.purple], // Đảm bảo AppColors có các màu này
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.smart_toy_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "AI gợi ý cho bạn",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Bạn nên ôn lại Hệ phương trình vì độ chính xác giảm 15% so với tuần trước.",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  // =========================================================================
  // CÁC WIDGET CON (UI Components)
  // =========================================================================

  // 1. Thẻ Nhiệm vụ hàng ngày
  Widget _buildDailyTaskItem({
    required String title,
    required String xp,
    required bool isCompleted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.green : Colors.grey.shade300,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isCompleted ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                xp,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Thẻ Hành động nhanh (Có hỗ trợ bấm onTap)
  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Thẻ Tiến độ môn học
  Widget _buildSubjectProgressCard(
      String tag,
      String title,
      String subtitle,
      double progress,
      Color tagColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tagColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: tagColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(fontWeight: FontWeight.bold, color: tagColor),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: tagColor.withOpacity(0.2),
                  color: tagColor,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ==========================================
          // 1. HEADER (Phần màu xanh dương trên cùng)
          // ==========================================
          Container(
            padding: const EdgeInsets.only(
              top: 60,
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Xin chào, Minh! 👋",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Lớp 10 • Sẵn sàng học chưa?",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
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
                              color: AppColors.orange,
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
            color: AppColors.bgLight,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thẻ Mục tiêu hôm nay
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.track_changes,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Mục tiêu hôm nay",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "3/5 bài",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: Colors.grey.shade200,
                        color: AppColors.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Còn 2 bài nữa để hoàn thành mục tiêu!",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2 Nút Hành động nhanh
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        title: "Học bài mới",
                        subtitle: "12 bài đang chờ",
                        icon: Icons.psychology,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickActionCard(
                        title: "Luyện tập",
                        subtitle: "8 bài tập mới",
                        icon: Icons.bolt,
                        color: AppColors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ==========================================
          // 3. PHẦN CUỐI (Nền xanh dương chủ đạo như Figma)
          // ==========================================
          Container(
            padding: const EdgeInsets.only(
              top: 24,
              left: 20,
              right: 20,
              bottom: 40,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
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

                      // CẬP NHẬT: Thẻ có nền trong suốt
                      _buildSubjectProgressCard(
                        "ĐẠI SỐ",
                        "Phương trình bậc 2",
                        "Bài 3: Công thức nghiệm",
                        0.7,
                        AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _buildSubjectProgressCard(
                        "HÌNH HỌC",
                        "Đường tròn",
                        "Bài 2: Tiếp tuyến",
                        0.45,
                        AppColors.green,
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
                      colors: [AppColors.pink, AppColors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        // Khoảng cách từ icon đến viền
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          // Màu trắng trong suốt 30%
                          borderRadius: BorderRadius.circular(
                            16,
                          ), // Bo góc tròn
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
    );
  }

  // Widget con: Thẻ Hành động nhanh
  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
            padding: const EdgeInsets.all(8), // Khoảng cách từ icon đến viền
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3), // Màu trắng trong suốt 30%
              borderRadius: BorderRadius.circular(12), // Bo góc tròn
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
    );
  }

  // Widget con: CẬP NHẬT GIAO DIỆN THẺ MÔN HỌC BO GÓC + NỀN MÀU TRONG SUỐT
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
        // Màu nền nhạt (xanh dương nhạt, xanh lá nhạt)
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tagColor.withOpacity(0.2),
        ), // Viền nhẹ tạo khối
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

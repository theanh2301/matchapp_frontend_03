import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'quiz_screen.dart'; // Import màn hình Quiz

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HEADER (Màu tím)
            // ==========================================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.purple,
                // Bo 2 góc bên dưới giống với các tab khác (ví dụ HomeScreen)
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(
                top: 60,
                left: 24,
                right: 24,
                bottom: 40,
              ),
              // Tăng padding bottom lên 40 để có chỗ bo cong
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Luyện tập",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Rèn luyện kỹ năng giải toán",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. CÁC THẺ BÀI TẬP
            // ==========================================
            Transform.translate(
              offset: const Offset(0, -20),
              // Kéo khối này lên trên 20px để tạo hiệu ứng đè
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChallengeCard(
                      context: context,
                      icon: Icons.bolt,
                      iconBgColor: AppColors.orange,
                      title: "Thử thách hàng ngày",
                      subtitle: "5 câu hỏi nhanh",
                      time: "3 phút",
                      xp: "+50 XP",
                      badgeText: "Dễ",
                      badgeColor: AppColors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildChallengeCard(
                      context: context,
                      icon: Icons.adjust,
                      iconBgColor: AppColors.primary,
                      title: "Luyện theo chủ đề",
                      subtitle: "Đại số - Phương trình",
                      time: "10 phút",
                      xp: "+100 XP",
                      badgeText: "Trung bình",
                      badgeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    _buildChallengeCard(
                      context: context,
                      icon: Icons.emoji_events,
                      iconBgColor: AppColors.purple,
                      title: "Thách thức khó",
                      subtitle: "Đề thi Olympic",
                      time: "20 phút",
                      xp: "+200 XP",
                      badgeText: "Khó",
                      badgeColor: AppColors.purple,
                    ),

                    const SizedBox(height: 32),

                    // ==========================================
                    // 3. TIẾN ĐỘ THEO CHỦ ĐỀ
                    // ==========================================
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppColors.purple, // Đổi sang màu tím theo mẫu
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Tiến độ theo chủ đề",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        _buildSubjectProgressCard(
                          "Đại số",
                          0.75,
                          "45 bài đã làm",
                          "82%",
                          AppColors.primary,
                        ),
                        const SizedBox(height: 12), // Khoảng cách giữa các thẻ
                        _buildSubjectProgressCard(
                          "Hình học",
                          0.60,
                          "32 bài đã làm",
                          "78%",
                          AppColors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildSubjectProgressCard(
                          "Lượng giác",
                          0.40,
                          "18 bài đã làm",
                          "65%",
                          AppColors.orange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ==========================================
                    // 4. LỖI CẦN ÔN LẠI
                    // ==========================================
                    Row(
                      children: [
                        Icon(
                          Icons.bug_report_outlined,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Lỗi cần ôn lại",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildMistakeCard(
                      tag: "Phương trình bậc 2",
                      question: "Giải phương trình: x² - 5x + 6 = 0",
                      userAnswer: "x = 2",
                      correctAnswer: "x = 2 hoặc x = 3",
                    ),
                    const SizedBox(height: 16),
                    _buildMistakeCard(
                      tag: "Lượng giác",
                      question: "Tính sin(45°)",
                      userAnswer: "1/2",
                      correctAnswer: "√2/2",
                    ),

                    const SizedBox(height: 32),

                    // ==========================================
                    // 5. AI GỢI Ý LUYỆN TẬP
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8E44AD), Color(0xFFB03A2E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.psychology,
                                  color: AppColors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "AI gợi ý luyện tập",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Bạn nên luyện thêm Định lý Vi-et để nâng cao độ chính xác từ 65% lên 85%.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.purple,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                "Bắt đầu luyện tập",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET CON: Thẻ thử thách (Click để vào Quiz) ---
  Widget _buildChallengeCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String time,
    required String xp,
    required String badgeText,
    required Color badgeColor,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Chuyển sang màn hình Trắc nghiệm
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QuizScreen(title: title)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          xp,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }

  // --- WIDGET CON: Thanh tiến độ môn học ---
  Widget _buildSubjectProgressCard(
      String title,
      double progress,
      String subtitleLeft,
      String accuracy,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16), // Bo góc cho từng thẻ
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Viền mờ nhẹ
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200, // Màu nền của thanh
            color: color, // Màu chạy tiến độ
            minHeight: 8, // Tăng độ dày lên chút cho giống thiết kế
            borderRadius: BorderRadius.circular(10), // Bo tròn thanh
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtitleLeft,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              Row(
                children: [
                  const Text("Độ chính xác: ", style: TextStyle(fontSize: 12, color: Colors.black87)),
                  Text(
                    accuracy,
                    style: TextStyle(
                      color: color, // Đổi màu độ chính xác theo màu chủ đề (Cam cho lượng giác, Xanh cho hình, ...)
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON: Thẻ Lỗi cần ôn lại ---
  Widget _buildMistakeCard({
    required String tag,
    required String question,
    required String userAnswer,
    required String correctAnswer,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                "Bạn: ",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                userAnswer,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                "Đúng: ",
                style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                correctAnswer,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {}, // Xử lý khi bấm học lại
            child: const Row(
              children: [
                Text(
                  "Học lại khái niệm này ",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.arrow_right_alt, color: AppColors.primary, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

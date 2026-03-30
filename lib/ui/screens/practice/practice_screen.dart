import 'package:flutter/material.dart';
import 'package:learn_math_app_03/ui/screens/practice/practice_list_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/practice_model.dart';
import '../../../data/services/practice_service.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final PracticeService _practiceService = PracticeService();

  late Future<PracticeModel> _dailyStatsFuture;
  late Future<PracticeModel> _topicStatsFuture;
  late Future<PracticeModel> _challengeStatsFuture;

  final int currentUserId = 1;

  @override
  void initState() {
    super.initState();
    // Khởi tạo gọi API ngay khi màn hình vừa load
    _dailyStatsFuture = _practiceService.getPracticeStats('DAILY', currentUserId);
    _topicStatsFuture = _practiceService.getPracticeStats('TOPIC', currentUserId);
    _challengeStatsFuture = _practiceService.getPracticeStats('CHALLENGE', currentUserId);
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
            // 1. HEADER
            // ==========================================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.purple,
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
            // 2. CÁC THẺ BÀI TẬP (Truyền practiceType & Future)
            // ==========================================
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChallengeCard(
                      context: context,
                      practiceType: 'DAILY',
                      futureStats: _dailyStatsFuture,
                      icon: Icons.calendar_today,
                      iconBgColor: AppColors.orange,
                      title: "Luyện theo ngày",
                      subtitle: "Học đều đặn mỗi ngày để tiến bộ",
                      themeColor: AppColors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildChallengeCard(
                      context: context,
                      practiceType: 'TOPIC',
                      futureStats: _topicStatsFuture,
                      icon: Icons.adjust,
                      iconBgColor: AppColors.primary,
                      title: "Luyện theo chủ đề",
                      subtitle: "Rèn luyện chuyên sâu từng chủ đề",
                      themeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    _buildChallengeCard(
                      context: context,
                      practiceType: 'CHALLENGE',
                      futureStats: _challengeStatsFuture,
                      icon: Icons.emoji_events,
                      iconBgColor: AppColors.purple,
                      title: "Thử thách",
                      subtitle: "Thách thức bản thân với các đề khó",
                      themeColor: AppColors.purple,
                    ),

                    const SizedBox(height: 32),

                    // ==========================================
                    // 3. TIẾN ĐỘ THEO CHỦ ĐỀ
                    // ==========================================
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppColors.purple,
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
                        _buildSubjectProgressCard("Đại số", 0.75, "45 bài đã làm", "82%", AppColors.primary),
                        const SizedBox(height: 12),
                        _buildSubjectProgressCard("Hình học", 0.60, "32 bài đã làm", "78%", AppColors.green),
                        const SizedBox(height: 12),
                        _buildSubjectProgressCard("Lượng giác", 0.40, "18 bài đã làm", "65%", AppColors.orange),
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
                                child: const Icon(Icons.psychology, color: AppColors.white, size: 24),
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
                            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.purple,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text("Bắt đầu luyện tập", style: TextStyle(fontWeight: FontWeight.bold)),
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

  // --- CẬP NHẬT: Thêm practiceType và FutureBuilder vào Card ---
  Widget _buildChallengeCard({
    required BuildContext context,
    required String practiceType,
    required Future<PracticeModel> futureStats,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required Color themeColor,
  }) {
    return FutureBuilder<PracticeModel>(
        future: futureStats,
        builder: (context, snapshot) {

          // Giá trị mặc định khi đang tải hoặc lỗi
          String displayProgressText = "Đang tải...";
          double displayProgressValue = 0.0;

          // Cập nhật giá trị khi lấy data thành công
          if (snapshot.hasData) {
            final data = snapshot.data!;
            displayProgressText = "${data.progressText} đề hoàn thành";
            displayProgressValue = data.progressPercent;
          }

          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // Truyền practiceType sang màn hình danh sách để filter
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PracticeListScreen(
                        title: title,
                        subtitle: subtitle,
                        themeColor: themeColor,
                        headerIcon: icon,
                        practiceType: practiceType,
                        // Bạn cần cập nhật file PracticeListScreen để nhận thêm param practiceType này nhé
                        // practiceType: practiceType,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: AppColors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey.shade400),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  displayProgressText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "${(displayProgressValue * 100).toInt()}%",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: displayProgressValue,
                              backgroundColor: Colors.grey.shade200,
                              color: themeColor,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  // --- WIDGET CON: Thanh tiến độ môn học (Giữ nguyên) ---
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
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
                      color: color,
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

  // --- WIDGET CON: Thẻ Lỗi cần ôn lại (Giữ nguyên) ---
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
            onTap: () {},
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
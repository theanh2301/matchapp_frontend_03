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

  // --- MOCK DATA: Dữ liệu mẫu cho phần Đề dưới 70% ---
  // (Sau này bạn có thể thay thế bằng dữ liệu gọi từ API)
  final List<Map<String, dynamic>> _weakTests = [
    {
      "testName": "Phương trình bậc 2",
      "topic": "Đại số",
      "accuracy": 0.55, // 55%
      "mistakes": [
        {
          "question": "Giải phương trình: x² - 5x + 6 = 0",
          "userAnswer": "x = 2",
          "correctAnswer": "x = 2 hoặc x = 3"
        },
        {
          "question": "Tính nghiệm kép của: x² - 4x + 4 = 0",
          "userAnswer": "x = 4",
          "correctAnswer": "x = 2"
        }
      ]
    },
    {
      "testName": "Đề ôn tập Hệ thức lượng",
      "topic": "Hình học",
      "accuracy": 0.65, // 65%
      "mistakes": [
        {
          "question": "Tính sin(45°)",
          "userAnswer": "1/2",
          "correctAnswer": "√2/2"
        }
      ]
    }
  ];

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
            // 1. HEADER (Giữ nguyên)
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
            // 2. CÁC THẺ BÀI TẬP (Giữ nguyên)
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
                    // 3 & 4 (GỘP): ĐỀ CẦN CẢI THIỆN & LỖI SAI (MỚI)
                    // ==========================================
                    Row(
                      children: [
                        Icon(
                          Icons.query_stats,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Đề cần cải thiện",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Duyệt qua danh sách các đề yếu để render UI
                    ..._weakTests.map((test) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildExpandableWeakTestCard(test),
                    )),

                    const SizedBox(height: 16),

                    // ==========================================
                    // 5. AI GỢI Ý LUYỆN TẬP (Giữ nguyên)
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

  // --- WIDGET CON: Thẻ bài tập (Giữ nguyên không đổi) ---
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
          String displayProgressText = "Đang tải...";
          double displayProgressValue = 0.0;

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PracticeListScreen(
                        title: title,
                        subtitle: subtitle,
                        themeColor: themeColor,
                        headerIcon: icon,
                        practiceType: practiceType,
                        userId: currentUserId,
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
        });
  }

  // --- WIDGET CON MỚI: Thẻ Đề Yếu có thể mở rộng ---
  Widget _buildExpandableWeakTestCard(Map<String, dynamic> testData) {
    double accuracy = testData['accuracy'];
    int percent = (accuracy * 100).toInt();
    List mistakes = testData['mistakes'];

    return Container(
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
      // Sử dụng Theme để ẩn 2 đường gạch viền mặc định của ExpansionTile khi mở rộng
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          title: Text(
            testData['testName'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "Chủ đề: ${testData['topic']} • ${mistakes.length} câu sai",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$percent%",
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          // Các phần tử xổ xuống (danh sách các câu sai)
          children: mistakes.map((mistake) {
            return _buildMistakeDetailItem(
              question: mistake['question'],
              userAnswer: mistake['userAnswer'],
              correctAnswer: mistake['correctAnswer'],
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- WIDGET CON MỚI: Chi tiết từng câu sai bên trong ExpansionTile ---
  Widget _buildMistakeDetailItem({
    required String question,
    required String userAnswer,
    required String correctAnswer,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.close, color: Colors.red, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "Bạn chọn: $userAnswer",
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "Đáp án: $correctAnswer",
                  style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:learn_math_app_03/data/services/exam_service.dart';
import 'package:learn_math_app_03/ui/screens/practice/practice_list_screen.dart';
import 'package:learn_math_app_03/ui/screens/practice/exam_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/practice_model.dart';
import '../../../data/models/practice_list_model.dart';
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

  // Future chứa danh sách các đề yếu (gọi API weak)
  late Future<List<PracticeListModel>> _weakTestsFuture;

  final int currentUserId = 1;

  @override
  void initState() {
    super.initState();
    _dailyStatsFuture = _practiceService.getPracticeStats('DAILY', currentUserId);
    _topicStatsFuture = _practiceService.getPracticeStats('TOPIC', currentUserId);
    _challengeStatsFuture = _practiceService.getPracticeStats('CHALLENGE', currentUserId);

    // Gọi API lấy danh sách đề cần cải thiện
    _weakTestsFuture = _practiceService.getWeakPractices('TOPIC', currentUserId);
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
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Luyện tập", style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Rèn luyện kỹ năng giải toán", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),

            // ==========================================
            // 2. CÁC THẺ BÀI TẬP
            // ==========================================
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChallengeCard(
                      context: context, practiceType: 'DAILY', futureStats: _dailyStatsFuture,
                      icon: Icons.calendar_today, iconBgColor: AppColors.orange,
                      title: "Luyện theo ngày", subtitle: "Học đều đặn mỗi ngày để tiến bộ", themeColor: AppColors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildChallengeCard(
                      context: context, practiceType: 'TOPIC', futureStats: _topicStatsFuture,
                      icon: Icons.adjust, iconBgColor: AppColors.primary,
                      title: "Luyện theo chủ đề", subtitle: "Rèn luyện chuyên sâu từng chủ đề", themeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    _buildChallengeCard(
                      context: context, practiceType: 'CHALLENGE', futureStats: _challengeStatsFuture,
                      icon: Icons.emoji_events, iconBgColor: AppColors.purple,
                      title: "Thử thách", subtitle: "Thách thức bản thân với các đề khó", themeColor: AppColors.purple,
                    ),

                    const SizedBox(height: 32),

                    // ==========================================
                    // 3. ĐỀ CẦN CẢI THIỆN (TỪ API)
                    // ==========================================
                    Row(
                      children: [
                        Icon(Icons.query_stats, color: Colors.red.shade400, size: 20),
                        const SizedBox(width: 8),
                        const Text("Đề cần cải thiện", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    FutureBuilder<List<PracticeListModel>>(
                      future: _weakTestsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(),
                              )
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("Lỗi tải dữ liệu: ${snapshot.error}", style: const TextStyle(color: Colors.red))
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          // Hiển thị giao diện khi không có đề yếu nào
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.green.shade200)
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.check_circle_outline, size: 40, color: Colors.green.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  "Tuyệt vời! Bạn không có đề nào dưới mức trung bình.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }

                        // Hiển thị danh sách WeakPracticeCard nếu có dữ liệu
                        return Column(
                          children: snapshot.data!.map((practice) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: WeakPracticeCard(
                              practice: practice,
                              userId: currentUserId,
                            ),
                          )).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==========================================
                    // 4. AI GỢI Ý LUYỆN TẬP (ĐÃ KHÔI PHỤC)
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

                    const SizedBox(height: 20), // Thêm khoảng trống cuối màn hình
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Khôi phục lại Widget buildCard của bạn
  Widget _buildChallengeCard({
    required BuildContext context, required String practiceType, required Future<PracticeModel> futureStats,
    required IconData icon, required Color iconBgColor, required String title,
    required String subtitle, required Color themeColor,
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
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey.shade400),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(displayProgressText, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                                Text("${(displayProgressValue * 100).toInt()}%", style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold)),
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
}
// =====================================================================
// WIDGET THẺ ĐỀ CẦN CẢI THIỆN
// =====================================================================
class WeakPracticeCard extends StatefulWidget {
  final PracticeListModel practice;
  final int userId;

  const WeakPracticeCard({super.key, required this.practice, required this.userId});

  @override
  State<WeakPracticeCard> createState() => _WeakPracticeCardState();
}

class _WeakPracticeCardState extends State<WeakPracticeCard> {
  final PracticeListService _practiceListService = PracticeListService();
  bool _isExpanded = false;

  Future<List<dynamic>>? _wrongQuestionsFuture;

  void _onExpansionChanged(bool expanded) {
    setState(() {
      _isExpanded = expanded;
      if (expanded && _wrongQuestionsFuture == null) {
        _wrongQuestionsFuture = _practiceListService.getWrongQuestionsDetail(widget.practice.id, widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Thêm viền màu nổi bật bên trái
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Color(0xFFFF2A5F), width: 6), // Viền trái màu đỏ hồng giống thiết kế
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              onExpansionChanged: _onExpansionChanged,
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),

              // ==============================
              // HEADER CỦA BÀI LUYỆN TẬP
              // ==============================
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge tên bài tập (VD: Phương trình bậc 2)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8EC), // Nền hồng nhạt
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.practice.title,
                      style: const TextStyle(
                        color: Color(0xFFFF2A5F), // Chữ đỏ hồng
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dòng thống kê tổng quan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Đã làm: ${widget.practice.totalAnswered}/${widget.practice.totalQuestions} câu",
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          "${widget.practice.correctPercent}%",
                          style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ==============================
              // NỘI DUNG XỔ XUỐNG (CÁC CÂU SAI)
              // ==============================
              children: [
                if (_isExpanded && _wrongQuestionsFuture != null)
                  FutureBuilder<List<dynamic>>(
                    future: _wrongQuestionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Text("Lỗi tải câu sai: ${snapshot.error}");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("Không tìm thấy dữ liệu câu sai.");
                      }

                      return Column(
                        children: [
                          // 1. Danh sách các câu hỏi làm sai
                          ...snapshot.data!.map((mistake) {
                            return _buildMistakeDetailItem(
                              // Thay bằng các tên biến mới đã được cập nhật trong Model
                              question: mistake.questionContent,
                              userAnswer: mistake.userAnswerContent,
                              correctAnswer: mistake.correctAnswerContent,
                            );
                          }).toList(),

                          const SizedBox(height: 24),

                          // 2. Nút "Học lại khái niệm này" ở dưới cùng
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuizScreen(
                                    practiceId: widget.practice.id,
                                    title: "Làm lại: ${widget.practice.title}",
                                    userId: widget.userId,
                                    isRetryMistakes: true,
                                    timeLimit: widget.practice.timeLimit,
                                  ),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Học lại khái niệm này",
                                  style: TextStyle(
                                    color: Color(0xFF6C47FF), // Màu tím đậm giống thiết kế
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_right_alt, color: Color(0xFF6C47FF)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget hiển thị từng câu sai
  Widget _buildMistakeDetailItem({required String question, required String userAnswer, required String correctAnswer}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề câu hỏi
          Text(
            "Giải phương trình: $question",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),

          // Khung xám chứa đáp án
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC), // Nền xám nhạt
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Hàng "Bạn:"
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 60,
                      child: Text("Bạn:", style: TextStyle(color: Color(0xFFFF2A5F), fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    Expanded(
                      child: Text(userAnswer, style: const TextStyle(color: Color(0xFF475569), fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Hàng "Đúng:"
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 60,
                      child: Text("Đúng:", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    Expanded(
                      child: Text(correctAnswer, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

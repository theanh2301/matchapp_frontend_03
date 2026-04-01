import 'package:flutter/material.dart';
import 'package:learn_math_app_03/data/models/practice_list_model.dart';
import 'package:learn_math_app_03/data/services/practice_list_service.dart';
import '../../../core/theme/app_colors.dart';
import 'exam_screen.dart';

class PracticeListScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color themeColor;
  final IconData headerIcon;
  final String practiceType;
  final int userId; // Thêm userId để gọi API lấy tiến độ cá nhân

  const PracticeListScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.headerIcon,
    required this.practiceType,
    required this.userId, // Bắt buộc truyền userId từ màn hình trước
  });

  @override
  State<PracticeListScreen> createState() => _PracticeListScreenState();
}

class _PracticeListScreenState extends State<PracticeListScreen> {
  final PracticeListService _practiceService = PracticeListService();
  late Future<List<PracticeListModel>> _futurePractices;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futurePractices = _practiceService.getPracticeOverview(
        widget.practiceType,
        widget.userId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          // ==========================================
          // 1. HEADER (Giữ nguyên giao diện của bạn)
          // ==========================================
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            backgroundColor: widget.themeColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.themeColor == AppColors.orange
                        ? [const Color(0xFFFFB75E), const Color(0xFFED8F03)]
                        : [widget.themeColor.withOpacity(0.7), widget.themeColor],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          child: Icon(
                            widget.headerIcon,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // 2. DANH SÁCH BÀI TẬP TỪ API
          // ==========================================
          FutureBuilder<List<PracticeListModel>>(
            future: _futurePractices,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}')),
                );
              }

              final items = snapshot.data ?? [];

              if (items.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Hiện chưa có bài tập nào cho độ khó này.')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.only(
                  top: 24,
                  left: 24,
                  right: 24,
                  bottom: 40,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildPracticeCard(
                          context,
                          index + 1,
                          item,
                          widget.themeColor,
                        ),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // WIDGET CON: Xây dựng từng thẻ bài tập lấy từ Model
  Widget _buildPracticeCard(
      BuildContext context,
      int index,
      PracticeListModel item,
      Color themeColor,
      ) {

    // --- BẮT ĐẦU LOGIC XỬ LÝ MÀU SẮC DỰA VÀO TIẾN ĐỘ ---
    Color cardColor = Colors.white;
    Color borderColor = Colors.transparent;
    Color iconBgColor = themeColor;

    if (item.isCompleted) {
      // Đã làm xong tất cả câu hỏi
      cardColor = Colors.green.shade50;
      borderColor = Colors.green.shade300;
      iconBgColor = Colors.green;
    } else if (item.isStarted) {
      // Đang làm dở dang
      cardColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade300;
      iconBgColor = Colors.orange;
    }

    // Hiển thị % chính xác hoặc '--' nếu chưa làm
    String scoreDisplay = item.isStarted ? "${item.correctPercent}%" : "--";
    Color scoreColor = item.isCompleted
        ? Colors.green.shade700
        : (item.isStarted ? Colors.orange.shade700 : Colors.grey.shade400);
    // --- KẾT THÚC LOGIC MÀU SẮC ---

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                QuizScreen(
                  practiceId: item.id,
                  title: item.title,
                  userId: widget.userId,
                  timeLimit: item.timeLimit,
                ),
          ),
        );

        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor, // Màu nền theo tiến độ
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5), // Viền nổi bật nếu đã làm
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
            // CỘT TRÁI: Khung số thứ tự / Trạng thái
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBgColor, // Đổi màu icon theo trạng thái
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: item.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 28) // Hiện dấu tick nếu xong
                  : Text(
                index.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // CỘT GIỮA: Thông tin bài tập
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Hàng thông tin phụ
                  Row(
                    children: [
                      Text(
                        "${item.totalQuestions} câu",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        "${item.timeLimit}p",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        "+${item.totalXp} XP",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  // Thêm thanh tiến độ nhỏ nếu đang làm dở
                  if (item.isStarted && !item.isCompleted) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: item.totalAnswered / item.totalQuestions,
                            backgroundColor: Colors.orange.shade100,
                            color: Colors.orange,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${item.totalAnswered}/${item.totalQuestions}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),

            // CỘT PHẢI CÙNG: Điểm số / % Đúng
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                children: [
                  Text(
                    scoreDisplay,
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  if (item.isStarted)
                    Text(
                      "Chính xác",
                      style: TextStyle(
                        color: scoreColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
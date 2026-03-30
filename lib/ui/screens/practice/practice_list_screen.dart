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

  const PracticeListScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.headerIcon,
    required this.practiceType,
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
    // String practiceType = _getType(widget.practiceType);

    _futurePractices = _practiceService.getPracticeOverview(widget.practiceType);
  }

  /*String _getType(String type) {
    switch (type) {
      case 'DAILY':
        return 'EASY';
      case 'TOPIC':
        return 'MEDIUM';
      case 'CHALLENGE':
        return 'HARD';
      default:
        return 'EASY'; // Mặc định nếu có lỗi truyền data
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          // ==========================================
          // 1. HEADER (Giữ nguyên giao diện đẹp của bạn)
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
              // Đang tải dữ liệu
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // Lỗi kết nối hoặc lỗi server
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}')),
                );
              }

              final items = snapshot.data ?? [];

              // Trống dữ liệu
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Hiện chưa có bài tập nào cho độ khó này.')),
                );
              }

              // Có dữ liệu, render ra danh sách SliverList
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
                          index + 1, // Hiển thị số thứ tự 1, 2, 3...
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
    // Tạm thời fix cứng giá trị bestScore vì API chưa hỗ trợ.
    // Nếu sau này API có trường này, bạn chỉ cần gọi item.bestScore là xong.
    String bestScoreDisplay = "--";
    Color scoreColor = Colors.grey.shade400;

    return GestureDetector(
      onTap: () {
        // Truyền ID bài tập (item.id) sang màn hình QuizScreen để load đúng câu hỏi
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizScreen(practiceId: item.id, title: item.title)), // Truyền id vào đây sau này nhé
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
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
            // CỘT TRÁI: Khung số thứ tự
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
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
                  Row(
                    children: [
                      Text(
                        "${item.totalQuestions} câu hỏi",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${item.timeLimit} phút",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
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
                ],
              ),
            ),
            const SizedBox(width: 16),

            // CỘT PHẢI CÙNG: Điểm số
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                bestScoreDisplay,
                style: TextStyle(
                  color: scoreColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
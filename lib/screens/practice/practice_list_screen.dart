import 'package:flutter/material.dart';
import 'package:learn_math_app_03/screens/practice/exam_screen.dart';
import '../../theme/app_colors.dart';
import '../learn/game/quiz_card.dart';
// import 'exam_screen.dart'; // Bạn import màn hình Quiz thực tế của bạn vào đây

// MÔ HÌNH DỮ LIỆU BÀI TẬP
class PracticeItem {
  final String title;
  final String subtitle;
  final String questionCount;
  final String time;
  final String xp;
  final String bestScore; // Ví dụ: "85%", "45%", "--"

  PracticeItem({
    required this.title,
    required this.subtitle,
    required this.questionCount,
    required this.time,
    required this.xp,
    required this.bestScore,
  });
}

class PracticeListScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color themeColor;
  final IconData headerIcon;

  const PracticeListScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.headerIcon,
  });

  @override
  Widget build(BuildContext context) {
    // TẠO DỮ LIỆU MẪU ĐÃ BỎ ĐI CÁC TRƯỜNG KHÔNG CẦN THIẾT
    final List<PracticeItem> practiceItems = [
      PracticeItem(
        title: "Bài ngày 1",
        subtitle: "Kiến thức cơ bản về phương trình",
        questionCount: "10 câu hỏi",
        time: "5 phút",
        xp: "+50 XP",
        bestScore: "85%",
      ),
      PracticeItem(
        title: "Bài ngày 2",
        subtitle: "Hệ phương trình bậc nhất",
        questionCount: "12 câu hỏi",
        time: "7 phút",
        xp: "+60 XP",
        bestScore: "92%",
      ),
      PracticeItem(
        title: "Bài ngày 3",
        subtitle: "Phương trình bậc 2 nâng cao",
        questionCount: "15 câu hỏi",
        time: "8 phút",
        xp: "+70 XP",
        bestScore: "45%", // Dưới 60% -> Sẽ hiện màu đỏ
      ),
      PracticeItem(
        title: "Bài ngày 4",
        subtitle: "Bất phương trình và ứng dụng",
        questionCount: "15 câu hỏi",
        time: "10 phút",
        xp: "+80 XP",
        bestScore: "--", // Chưa làm
      ),
      PracticeItem(
        title: "Bài ngày 5",
        subtitle: "Tổng hợp kiến thức tuần 1",
        questionCount: "20 câu hỏi",
        time: "15 phút",
        xp: "+100 XP",
        bestScore: "--",
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          // ==========================================
          // 1. HEADER (SliverAppBar có Gradient)
          // ==========================================
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            backgroundColor: themeColor,
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
                    colors: themeColor == AppColors.orange
                        ? [const Color(0xFFFFB75E), const Color(0xFFED8F03)]
                        : [themeColor.withOpacity(0.7), themeColor],
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
                            headerIcon,
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
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
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
          // 2. DANH SÁCH BÀI TẬP
          // ==========================================
          SliverPadding(
            padding: const EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: 40,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = practiceItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildPracticeCard(
                    context,
                    index + 1,
                    item,
                    themeColor,
                  ),
                );
              }, childCount: practiceItems.length),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET CON: Xây dựng từng thẻ bài tập
  Widget _buildPracticeCard(
    BuildContext context,
    int index,
    PracticeItem item,
    Color themeColor,
  ) {
    // Tính toán màu sắc cho điểm số (% hoàn thành)
    Color scoreColor = Colors.grey.shade400; // Mặc định cho "--"
    if (item.bestScore != "--") {
      // Ép kiểu chuỗi "85%" thành số nguyên 85 để so sánh
      int scoreValue = int.tryParse(item.bestScore.replaceAll('%', '')) ?? 0;
      if (scoreValue >= 60) {
        scoreColor = Colors.green; // Trên 60% xanh
      } else {
        scoreColor = Colors.red; // Dưới 60% đỏ
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizScreen(title: title)),
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
            // CỘT TRÁI: Khung số thứ tự bo góc vuông
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

            // CỘT GIỮA: Tiêu đề, Phụ đề và Các thông số (Cùng một khối)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dòng 1: Tiêu đề (VD: Bài ngày 1)
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Dòng 2: Phụ đề (VD: Kiến thức cơ bản...)
                  Text(
                    item.subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),

                  // Dòng 3: Câu hỏi + Thời gian + XP (Nằm cùng khối với phụ đề)
                  Row(
                    children: [
                      // Số câu hỏi
                      Text(
                        item.questionCount,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Thời gian
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.time,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),

                      const Spacer(),

                      // Điểm XP
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        item.xp,
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

            // CỘT PHẢI CÙNG: Điểm số % hoàn thành
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                item.bestScore,
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

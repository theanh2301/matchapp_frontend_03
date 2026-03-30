import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_colors.dart';



class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HEADER (Màu xanh lá)
            // ==========================================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.green, // Màu xanh lá chủ đạo của màn hình Tiến độ
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tiến độ",
                    style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Theo dõi quá trình học tập của bạn",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. LƯỚI THỐNG KÊ TỔNG QUAN
            // ==========================================
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 4 Thẻ thống kê
                    Row(
                      children: [
                        Expanded(child: _buildStatCard(icon: Icons.track_changes, iconBg: AppColors.primary.withOpacity(0.1), iconColor: AppColors.primary, value: "38", label: "Bài đã học")),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard(icon: Icons.stars_rounded, iconBg: AppColors.green.withOpacity(0.1), iconColor: AppColors.green, value: "3,450", label: "Tổng XP")),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard(icon: Icons.bar_chart, iconBg: AppColors.purple.withOpacity(0.1), iconColor: AppColors.purple, value: "78%", label: "Độ chính xác")),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard(icon: Icons.calendar_month_outlined, iconBg: AppColors.orange.withOpacity(0.1), iconColor: AppColors.orange, value: "28", label: "Ngày học")),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ==========================================
                    // 3. BIỂU ĐỒ HOẠT ĐỘNG (Sử dụng fl_chart)
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.show_chart, color: AppColors.green, size: 20),
                                  const SizedBox(width: 8),
                                  const Text("Hoạt động", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: AppColors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  children: [
                                    const Text("Tuần", style: TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Text("Tháng", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Khối vẽ biểu đồ
                          SizedBox(
                            height: 150, // Chiều cao biểu đồ
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 100, // Giá trị cột cao nhất
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                                        String text;
                                        switch (value.toInt()) {
                                          case 0: text = 'T2'; break;
                                          case 1: text = 'T3'; break;
                                          case 2: text = 'T4'; break;
                                          case 3: text = 'T5'; break;
                                          case 4: text = 'T6'; break;
                                          case 5: text = 'T7'; break;
                                          case 6: text = 'CN'; break;
                                          default: text = ''; break;
                                        }
                                        return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: Text(text, style: style));
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Ẩn cột số bên trái
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: const FlGridData(show: false), // Ẩn đường kẻ lưới ngang dọc
                                borderData: FlBorderData(show: false), // Ẩn viền bao quanh biểu đồ
                                barGroups: [
                                  // Data cột T2, T3, ...
                                  _makeBarData(0, 50),
                                  _makeBarData(1, 85),
                                  _makeBarData(2, 60),
                                  _makeBarData(3, 70),
                                  _makeBarData(4, 90),
                                  _makeBarData(5, 65),
                                  _makeBarData(6, 80),
                                ],
                              ),
                            ),
                          ),

                          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),

                          Center(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                                children: [
                                  TextSpan(text: "Tổng tuần này: "),
                                  TextSpan(text: "1,220 XP", style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ==========================================
                    // 4. ĐÁNH GIÁ NĂNG LỰC
                    // ==========================================
                    Row(
                      children: [
                        Icon(Icons.psychology_alt, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text("Đánh giá năng lực", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSkillCard(title: "Đại số", badgeText: "Khá", badgeColor: AppColors.primary, progress: 0.75, changeText: "+5% tuần này", changeColor: AppColors.green),
                    const SizedBox(height: 12),
                    _buildSkillCard(title: "Hình học", badgeText: "Trung bình", badgeColor: AppColors.orange, progress: 0.60, changeText: "+3% tuần này", changeColor: AppColors.green),
                    const SizedBox(height: 12),
                    _buildSkillCard(title: "Lượng giác", badgeText: "Trung bình", badgeColor: AppColors.orange, progress: 0.55, changeText: "-2% tuần này", changeColor: Colors.red),
                    const SizedBox(height: 12),
                    _buildSkillCard(title: "Hàm số", badgeText: "Yếu", badgeColor: Colors.red, progress: 0.35, changeText: "0% tuần này", changeColor: Colors.grey),

                    const SizedBox(height: 32),

                    // ==========================================
                    // 5. THÀNH TÍCH
                    // ==========================================
                    Row(
                      children: [
                        Icon(Icons.emoji_events_outlined, color: AppColors.orange, size: 20),
                        const SizedBox(width: 8),
                        const Text("Thành tích", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),

                    GridView.count(
                      shrinkWrap: true, // Quan trọng: Để GridView nằm gọn trong SingleChildScrollView
                      physics: const NeverScrollableScrollPhysics(), // Tắt cuộn của GridView
                      crossAxisCount: 3, // Số cột (3 cột)
                      mainAxisSpacing: 12, // Khoảng cách dọc giữa các hàng
                      crossAxisSpacing: 12, // Khoảng cách ngang giữa các cột
                      childAspectRatio: 1.1, // Tỷ lệ chiều rộng / chiều cao của thẻ (Điều chỉnh số này nếu bạn muốn thẻ vuông hơn hoặc chữ nhật hơn)
                      children: [
                        _buildAchievementCard(
                            iconPath: 'assets/icons/fire.png',
                            iconFallback: Icons.local_fire_department,
                            color: Colors.orange,
                            text: "Streak 7 ngày",
                            isAchieved: true
                        ),
                        _buildAchievementCard(
                            iconPath: 'assets/icons/star.png',
                            iconFallback: Icons.star,
                            color: Colors.amber,
                            text: "1000 XP",
                            isAchieved: true
                        ),
                        _buildAchievementCard(
                            iconPath: 'assets/icons/target.png',
                            iconFallback: Icons.track_changes,
                            color: AppColors.orange,
                            text: "50 bài hoàn thành",
                            isAchieved: true
                        ),
                        _buildAchievementCard(
                            iconPath: 'assets/icons/trophy.png',
                            iconFallback: Icons.emoji_events,
                            color: Colors.grey,
                            text: "100% độ chính xác",
                            isAchieved: false
                        ),
                        _buildAchievementCard(
                            iconPath: 'assets/icons/diamond.png',
                            iconFallback: Icons.diamond,
                            color: Colors.grey,
                            text: "Streak 30 ngày",
                            isAchieved: false
                        ),
                        _buildAchievementCard(
                            iconPath: 'assets/icons/crown.png',
                            iconFallback: Icons.workspace_premium,
                            color: Colors.grey,
                            text: "Top 10 tuần",
                            isAchieved: false
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ==========================================
                    // 6. PHÂN TÍCH AI (Thẻ dưới cùng)
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF651FFF)], // Xanh dương sang tím
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.psychology, color: AppColors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.bar_chart, color: AppColors.green, size: 18),
                                    const SizedBox(width: 6),
                                    const Text("Phân tích AI", style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: const TextSpan(
                                    style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                                    children: [
                                      TextSpan(text: "Bạn đã tiến bộ "),
                                      TextSpan(text: "+12% tuần này", style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "! Năng lực "),
                                      TextSpan(text: "Đại số ", style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "tăng mạnh. Tiếp tục duy trì nhé!"),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- HÀM TẠO CỘT CHO BIỂU ĐỒ BAR CHART ---
  BarChartGroupData _makeBarData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.green,
          width: 24, // Độ rộng của cột
          borderRadius: BorderRadius.circular(6), // Bo tròn đỉnh cột
          backDrawRodData: BackgroundBarChartRodData(
            show: false, // Ẩn phần nền mờ đằng sau cột
          ),
        ),
      ],
    );
  }

  // --- WIDGET CON: Thẻ thống kê nhỏ ---
  Widget _buildStatCard({required IconData icon, required Color iconBg, required Color iconColor, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    );
  }

  // --- WIDGET CON: Thẻ đánh giá năng lực ---
  Widget _buildSkillCard({
    required String title,
    required String badgeText,
    required Color badgeColor,
    required double progress,
    required String changeText,
    required Color changeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(changeText, style: TextStyle(color: changeColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: badgeColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON: Thẻ Huy hiệu thành tích ---
  Widget _buildAchievementCard({
    String? iconPath, // Dùng ảnh asset (nếu có)
    required IconData iconFallback, // Icon dự phòng
    required Color color,
    required String text,
    required bool isAchieved
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), // Điều chỉnh padding
      decoration: BoxDecoration(
        color: isAchieved ? color : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        // Gradient mượt hơn nếu có
        gradient: isAchieved
            ? LinearGradient(
            colors: [color.withOpacity(0.9), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
        )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Ép nội dung ra giữa thẻ
        children: [
          // Nếu bạn đã xuất các icon 3D ra file ảnh (.png) thì tải chúng lên thư mục assets và dùng dòng dưới:
          // Image.asset(iconPath!, width: 32, height: 32),

          // Tạm thời dùng Icon mặc định của Flutter nếu bạn chưa có file ảnh
          Icon(iconFallback, color: isAchieved ? Colors.white : Colors.grey.shade400, size: 32),

          const SizedBox(height: 8),

          // Bao bọc text bằng Expanded hoặc Flexible nếu chữ quá dài
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isAchieved ? Colors.white : Colors.grey.shade500,
              fontSize: 10.5, // Chữ nhỏ lại một chút để không bị tràn dòng
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
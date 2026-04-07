import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/services/dashboard_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  final int userId = 1;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final int userId = 1;
  final DashboardService _service = DashboardService();
  DashboardResponse? _dashboardData;
  bool _isLoading = true;

  late DateTime _currentSelectedDate;

  @override
  void initState() {
    super.initState();
    _currentSelectedDate = DateTime.now(); // Mặc định lấy ngày hôm nay
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _service.getDashboardData(
        widget.userId,
        _currentSelectedDate,
      );
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      // Khi có lỗi API, reset data về null để UI tự hiển thị số 0
      setState(() {
        _dashboardData = null;
        _isLoading = false;
      });
      // Hiển thị thông báo lỗi thân thiện thay vì làm hỏng màn hình
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không thể tải dữ liệu. Đang hiển thị mặc định."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // --- HÀM XỬ LÝ CHUYỂN TUẦN ---
  void _previousWeek() {
    setState(() {
      _currentSelectedDate = _currentSelectedDate.subtract(
        const Duration(days: 7),
      );
    });
    _fetchData();
  }

  void _nextWeek() {
    // Có thể chặn không cho xem tuần tương lai nếu muốn
    if (_currentSelectedDate
        .add(const Duration(days: 7))
        .isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chưa có dữ liệu cho tuần tương lai!")),
      );
      return;
    }
    setState(() {
      _currentSelectedDate = _currentSelectedDate.add(const Duration(days: 7));
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
      // Bỏ đoạn check _errorMessage đi, luôn gọi _buildContent để render UI mặc định
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    // Sử dụng null-aware để lấy dữ liệu an toàn
    final stats = _dashboardData?.stats;
    final weeklyXp = _dashboardData?.weeklyXp ?? [];

    // Tính tổng XP trong tuần (nếu list rỗng thì trả về 0)
    int totalXpThisWeek = weeklyXp.isEmpty
        ? 0
        : weeklyXp.fold(0, (sum, item) => sum + item.totalXp);

    // Tìm mức XP cao nhất để cấu hình trục Y cho biểu đồ
    double maxY = 100; // Giá trị mặc định
    if (weeklyXp.isNotEmpty) {
      double maxDataY = weeklyXp.map((e) => e.totalXp.toDouble()).reduce(max);
      if (maxDataY > 0) maxY = maxDataY * 1.2;
    }

    // Xác định số cột biểu đồ: Nếu có dữ liệu thì lấy độ dài list, nếu không thì mặc định 7 ngày
    int chartLength = weeklyXp.isNotEmpty ? weeklyXp.length : 7;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.green, // AppColors.green
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
                  "Tiến độ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Theo dõi quá trình học tập của bạn",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // 2. LƯỚI THỐNG KÊ TỔNG QUAN
          Transform.translate(
            offset: const Offset(0, -20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.track_changes,
                          iconBg: Colors.blue.withOpacity(0.1),
                          iconColor: Colors.blue,
                          // Gán giá trị mặc định là 0 nếu stats null
                          value: "${stats?.totalLesson ?? 0}",
                          label: "Bài đã học",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.stars_rounded,
                          iconBg: Colors.green.withOpacity(0.1),
                          iconColor: Colors.green,
                          value: "${stats?.totalXP ?? 0}",
                          label: "Tổng XP",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.local_fire_department,
                          iconBg: Colors.orange.withOpacity(0.1),
                          iconColor: Colors.orange,
                          value: "${stats?.streakDay ?? 0}",
                          label: "Ngày Streak",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.calendar_month_outlined,
                          iconBg: Colors.purple.withOpacity(0.1),
                          iconColor: Colors.purple,
                          value: "${stats?.totalStudyDay ?? 0}",
                          label: "Ngày học",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 3. BIỂU ĐỒ HOẠT ĐỘNG
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.show_chart,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Hoạt động",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // NÚT CHUYỂN TUẦN
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: _previousWeek,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Tuần này",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: _nextWeek,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // KHỐI VẼ BIỂU ĐỒ
                        GestureDetector(
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity! > 0) {
                              _previousWeek();
                            } else if (details.primaryVelocity! < 0) {
                              _nextWeek();
                            }
                          },
                          child: SizedBox(
                            height: 150,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxY,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        '${rod.toY.round()} XP',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        const style = TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        );
                                        int index = value.toInt();
                                        if (index < 0 || index >= chartLength) {
                                          return const SizedBox.shrink();
                                        }

                                        String text = '';
                                        if (weeklyXp.isNotEmpty) {
                                          DateTime date = DateTime.parse(weeklyXp[index].date);
                                          text = _getWeekdayString(date.weekday);
                                        } else {
                                          // Hiển thị T2 -> CN nếu mảng API rỗng
                                          text = _getWeekdayString(index + 1);
                                        }

                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          space: 10,
                                          child: Text(text, style: style),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(chartLength, (index) {
                                  // Nếu có dữ liệu thì lấy, không thì biểu đồ trả về 0
                                  double yValue = weeklyXp.isNotEmpty
                                      ? weeklyXp[index].totalXp.toDouble()
                                      : 0.0;
                                  return _makeBarData(index, yValue);
                                }),
                              ),
                            ),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1, color: Colors.black12),
                        ),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(text: "Tổng tuần: "),
                                TextSpan(
                                  text: "$totalXpThisWeek XP",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==========================================
                  // 4. ĐÁNH GIÁ NĂNG LỰC
                  // ==========================================
                  Row(
                    children: [
                      Icon(
                        Icons.psychology_alt,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Đánh giá năng lực",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Các phần đánh giá năng lực bên dưới hoàn toàn có thể truyền giá trị 0
                  // thông qua các logic lấy dữ liệu tương tự ở đây trong tương lai.
                  _buildSkillCard(
                    title: "Đại số",
                    badgeText: "Khá",
                    badgeColor: AppColors.primary,
                    progress: 0.75,
                    changeText: "+5% tuần này",
                    changeColor: AppColors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildSkillCard(
                    title: "Hình học",
                    badgeText: "Trung bình",
                    badgeColor: AppColors.orange,
                    progress: 0.60,
                    changeText: "+3% tuần này",
                    changeColor: AppColors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildSkillCard(
                    title: "Lượng giác",
                    badgeText: "Trung bình",
                    badgeColor: AppColors.orange,
                    progress: 0.55,
                    changeText: "-2% tuần này",
                    changeColor: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _buildSkillCard(
                    title: "Hàm số",
                    badgeText: "Yếu",
                    badgeColor: Colors.red,
                    progress: 0.35,
                    changeText: "0% tuần này",
                    changeColor: Colors.grey,
                  ),

                  const SizedBox(height: 32),

                  // ==========================================
                  // 5. THÀNH TÍCH
                  // ==========================================
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        color: AppColors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Thành tích",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildAchievementCard(
                        iconPath: 'assets/icons/fire.png',
                        iconFallback: Icons.local_fire_department,
                        color: Colors.orange,
                        text: "Streak 7 ngày",
                        isAchieved: true,
                      ),
                      _buildAchievementCard(
                        iconPath: 'assets/icons/star.png',
                        iconFallback: Icons.star,
                        color: Colors.amber,
                        text: "1000 XP",
                        isAchieved: true,
                      ),
                      _buildAchievementCard(
                        iconPath: 'assets/icons/target.png',
                        iconFallback: Icons.track_changes,
                        color: AppColors.orange,
                        text: "50 bài hoàn thành",
                        isAchieved: true,
                      ),
                      _buildAchievementCard(
                        iconPath: 'assets/icons/trophy.png',
                        iconFallback: Icons.emoji_events,
                        color: Colors.grey,
                        text: "100% độ chính xác",
                        isAchieved: false,
                      ),
                      _buildAchievementCard(
                        iconPath: 'assets/icons/diamond.png',
                        iconFallback: Icons.diamond,
                        color: Colors.grey,
                        text: "Streak 30 ngày",
                        isAchieved: false,
                      ),
                      _buildAchievementCard(
                        iconPath: 'assets/icons/crown.png',
                        iconFallback: Icons.workspace_premium,
                        color: Colors.grey,
                        text: "Top 10 tuần",
                        isAchieved: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // 6. PHÂN TÍCH AI
                  // ==========================================
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF651FFF)],
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
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.psychology,
                            color: AppColors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.bar_chart,
                                    color: AppColors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Phân tích AI",
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(text: "Bạn đã tiến bộ "),
                                    TextSpan(
                                      text: "+12% tuần này",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: "! Năng lực "),
                                    TextSpan(
                                      text: "Đại số ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "tăng mạnh. Tiếp tục duy trì nhé!",
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
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.green,
          width: 24,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: Colors.grey.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  String _getWeekdayString(int weekday) {
    switch (weekday) {
      case 1:
        return 'T2';
      case 2:
        return 'T3';
      case 3:
        return 'T4';
      case 4:
        return 'T5';
      case 5:
        return 'T6';
      case 6:
        return 'T7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

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
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    changeText,
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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

  Widget _buildAchievementCard({
    String? iconPath,
    required IconData iconFallback,
    required Color color,
    required String text,
    required bool isAchieved,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isAchieved ? color : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        gradient: isAchieved
            ? LinearGradient(
          colors: [color.withOpacity(0.9), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconFallback,
            color: isAchieved ? Colors.white : Colors.grey.shade400,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isAchieved ? Colors.white : Colors.grey.shade500,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
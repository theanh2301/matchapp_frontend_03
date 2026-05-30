import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import '../../../core/theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/performance_model.dart'; // Import Model mới
import '../../../data/services/dashboard_service.dart';
import '../../../data/services/performance_service.dart'; // Import Service mới

class ProgressScreen extends StatefulWidget {
  final int userId;
  final int gradeId;

  const ProgressScreen({
    super.key,
    required this.userId,
    required this.gradeId,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // Services
  final DashboardService _dashboardService = DashboardService();
  final PerformanceService _performanceService = PerformanceService();

  // States
  DashboardResponse? _dashboardData;
  bool _isLoadingDashboard = true;
  late DateTime _currentSelectedDate;

  // States cho Đánh giá năng lực
  bool _isSubjectMode = true; // true = Xem theo môn, false = Xem theo dạng
  bool _isLoadingPerformance = true;
  List<SubjectPerformanceModel> _subjectPerformances = [];
  List<TypePerformanceModel> _typePerformances = [];

  @override
  void initState() {
    super.initState();
    _currentSelectedDate = DateTime.now();
    _fetchDashboardData();
    _fetchPerformanceData(); // Gọi API hiệu suất khi khởi tạo
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoadingDashboard = true);
    try {
      final data = await _dashboardService.getDashboardData(
        widget.userId,
        _currentSelectedDate,
      );
      setState(() {
        _dashboardData = data;
        _isLoadingDashboard = false;
      });
    } catch (e) {
      setState(() => _isLoadingDashboard = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không thể tải dữ liệu Dashboard."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Hàm gọi API Đánh giá năng lực dựa trên Tab đang chọn
  Future<void> _fetchPerformanceData() async {
    setState(() => _isLoadingPerformance = true);
    try {
      if (_isSubjectMode) {
        final data = await _performanceService.getSubjectPerformance(
          widget.userId,
        );
        setState(() {
          _subjectPerformances = data;
          _isLoadingPerformance = false;
        });
      } else {
        final data = await _performanceService.getTypePerformance(
          widget.userId,
        );
        setState(() {
          _typePerformances = data;
          _isLoadingPerformance = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingPerformance = false);
      debugPrint("Lỗi tải Performance: $e");
    }
  }

  // Chuyển đổi Tab
  void _togglePerformanceMode(bool isSubject) {
    if (_isSubjectMode == isSubject) return; // Không gọi lại nếu bấm cùng tab
    setState(() => _isSubjectMode = isSubject);
    _fetchPerformanceData();
  }

  void _previousWeek() {
    setState(
      () => _currentSelectedDate = _currentSelectedDate.subtract(
        const Duration(days: 7),
      ),
    );
    _fetchDashboardData();
  }

  void _nextWeek() {
    if (_currentSelectedDate
        .add(const Duration(days: 7))
        .isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chưa có dữ liệu cho tuần tương lai!")),
      );
      return;
    }
    setState(
      () => _currentSelectedDate = _currentSelectedDate.add(
        const Duration(days: 7),
      ),
    );
    _fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: _isLoadingDashboard && _dashboardData == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final horizontalPadding = Responsive.horizontalPadding(context);
    final stats = _dashboardData?.stats;
    final weeklyXp = _dashboardData?.weeklyXp ?? [];

    int totalXpThisWeek = weeklyXp.isEmpty
        ? 0
        : weeklyXp.fold(0, (sum, item) => sum + item.totalXp);
    double maxY = 100;
    if (weeklyXp.isNotEmpty) {
      double maxDataY = weeklyXp.map((e) => e.totalXp.toDouble()).reduce(max);
      if (maxDataY > 0) maxY = maxDataY * 1.2;
    }
    int chartLength = weeklyXp.isNotEmpty ? weeklyXp.length : 7;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header xanh
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.only(
              top: Responsive.headerTopPadding(context),
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: 40,
            ),
            child: Responsive.centered(
              context: context,
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
          ),

          Transform.translate(
            offset: const Offset(0, -20),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Responsive.centered(
                context: context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 4 Thẻ Stat
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.track_changes,
                            iconBg: Colors.blue.withOpacity(0.1),
                            iconColor: Colors.blue,
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

                    // Chart
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
                          GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity! > 0)
                                _previousWeek();
                              else if (details.primaryVelocity! < 0)
                                _nextWeek();
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
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) =>
                                              BarTooltipItem(
                                                '${rod.toY.round()} XP',
                                                const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                              const style = TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              );
                                              int index = value.toInt();
                                              if (index < 0 ||
                                                  index >= chartLength)
                                                return const SizedBox.shrink();
                                              String text = '';
                                              if (weeklyXp.isNotEmpty) {
                                                DateTime date = DateTime.parse(
                                                  weeklyXp[index].date,
                                                );
                                                text = _getWeekdayString(
                                                  date.weekday,
                                                );
                                              } else {
                                                text = _getWeekdayString(
                                                  index + 1,
                                                );
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
                                  barGroups: List.generate(
                                    chartLength,
                                    (index) => _makeBarData(
                                      index,
                                      weeklyXp.isNotEmpty
                                          ? weeklyXp[index].totalXp.toDouble()
                                          : 0.0,
                                    ),
                                  ),
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
                    const SizedBox(height: 32),

                    // ==========================================
                    // KHU VỰC ĐÁNH GIÁ NĂNG LỰC DYNAMIC
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        // Toggle Switch
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => _togglePerformanceMode(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isSubjectMode
                                        ? AppColors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: _isSubjectMode
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    "Môn học",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _isSubjectMode
                                          ? AppColors.primary
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Hiển thị nội dung dựa trên Loading & Dữ liệu
                    if (_isLoadingPerformance)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_isSubjectMode)
                      // Giao diện Môn Học
                      _subjectPerformances.isEmpty
                          ? const Center(
                              child: Text(
                                "Chưa có dữ liệu đánh giá môn học",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : Column(
                              children: _subjectPerformances.map((item) {
                                Color levelColor = _getLevelColor(item.level);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildSkillCard(
                                    title: item.subject,
                                    badgeText: item.level,
                                    badgeColor: levelColor,
                                    progress:
                                        item.accuracy / 100, // Đưa về 0.0 - 1.0
                                    changeText:
                                        "${item.weeklyChange >= 0 ? '+' : ''}${item.weeklyChange}% tuần này",
                                    changeColor: item.weeklyChange >= 0
                                        ? AppColors.green
                                        : Colors.red,
                                  ),
                                );
                              }).toList(),
                            )
                    else
                      // Giao diện Loại Bài Tập
                      _typePerformances.isEmpty
                          ? const Center(
                              child: Text(
                                "Chưa có dữ liệu chi tiết bài tập",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : Column(
                              children: _typePerformances.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildSkillCard(
                                    title: item.type,
                                    // Dạng bài tập không có Level, chỉ show điểm/XP
                                    badgeText: null,
                                    badgeColor: AppColors.primary,
                                    progress: item.score / 100 > 1
                                        ? 1.0
                                        : item.score /
                                              100, // Cắt thanh % tối đa ở 1.0
                                    overrideValueText:
                                        "${item.score}", // Hiển thị số XP thay vì %
                                    changeText: null,
                                    changeColor: Colors.transparent,
                                  ),
                                );
                              }).toList(),
                            ),

                    const SizedBox(height: 32),

                    // ==========================================
                    // GIỮ NGUYÊN THÀNH TÍCH VÀ AI ANALYSIS
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
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: Responsive.isCompact(context)
                          ? 2
                          : (Responsive.isTablet(context) ? 4 : 3),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: Responsive.isTablet(context)
                          ? 1.05
                          : 0.95,
                      children: [
                        _buildAchievementCard(
                          iconFallback: Icons.local_fire_department,
                          color: Colors.orange,
                          text: "Streak 7 ngày",
                          isAchieved: true,
                        ),
                        _buildAchievementCard(
                          iconFallback: Icons.star,
                          color: Colors.amber,
                          text: "1000 XP",
                          isAchieved: true,
                        ),
                        _buildAchievementCard(
                          iconFallback: Icons.track_changes,
                          color: AppColors.orange,
                          text: "50 bài hoàn thành",
                          isAchieved: true,
                        ),
                        _buildAchievementCard(
                          iconFallback: Icons.emoji_events,
                          color: Colors.grey,
                          text: "100% độ chính xác",
                          isAchieved: false,
                        ),
                        _buildAchievementCard(
                          iconFallback: Icons.diamond,
                          color: Colors.grey,
                          text: "Streak 30 ngày",
                          isAchieved: false,
                        ),
                        _buildAchievementCard(
                          iconFallback: Icons.workspace_premium,
                          color: Colors.grey,
                          text: "Top 10 tuần",
                          isAchieved: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Phân tích AI
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
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.bar_chart,
                                      color: AppColors.green,
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
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
                                        text:
                                            "tăng mạnh. Tiếp tục duy trì nhé!",
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
          ),
        ],
      ),
    );
  }

  // Hàm helper lấy màu theo xếp loại
  Color _getLevelColor(String level) {
    if (level.toLowerCase() == 'khá' || level.toLowerCase() == 'giỏi')
      return AppColors.primary;
    if (level.toLowerCase() == 'trung bình') return AppColors.orange;
    return Colors.red;
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
    String? badgeText,
    required Color badgeColor,
    required double progress,
    String? overrideValueText,
    String? changeText,
    Color? changeColor,
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (badgeText != null) ...[
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
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    overrideValueText ?? "${(progress * 100).toInt()}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (changeText != null) ...[
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
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
            size: 28,
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isAchieved ? Colors.white : Colors.grey.shade500,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

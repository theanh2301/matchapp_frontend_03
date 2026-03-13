import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../auth/auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER (Hồ sơ)
            // ==========================================
            Stack(
              children: [
                // Khối nền tím bo góc dưới
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primary, // Hoặc AppColors.purple tùy vào theme bạn đang dùng
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hồ sơ", style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Quản lý tài khoản và cài đặt", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),

                // ==========================================
                // 2. KHỐI THÔNG TIN NGƯỜI DÙNG & THỐNG KÊ (Nổi lên trên)
                // ==========================================
                Container(
                  margin: const EdgeInsets.only(top: 130, left: 24, right: 24), // Đẩy thẻ này xuống 130px để đè lên ranh giới màu tím
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      // Avatar & Tên
                      Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(color: AppColors.purple, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: const Text("M", style: TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Mai Thế Anh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("minh.nguyen@email.com", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildTag("Lớp 10A1", AppColors.primary),
                                    const SizedBox(width: 8),
                                    _buildTag("Premium", AppColors.purple, icon: Icons.workspace_premium),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1, color: Colors.black12),
                      ),
                      // 3 Cột Thống kê nhanh
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickStat("3,450", "Tổng XP"),
                          _buildQuickStat("38", "Bài đã học"),
                          _buildQuickStat("7", "Streak"),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
/*
            // ==========================================
            // 3. MỤC TIÊU HỌC TẬP
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Mục tiêu học tập", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildGoalRow("Bài học mỗi ngày", "5 bài"),
                    const SizedBox(height: 12),
                    _buildGoalRow("XP mỗi ngày", "500 XP"),
                    const SizedBox(height: 12),
                    _buildGoalRow("Thời gian học", "30 phút/ngày"),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {},
                        child: const Text("Chỉnh sửa mục tiêu", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),*/

            // ==========================================
            // 4. DANH SÁCH MENU (Cài đặt, Thông báo...)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildMenuButton(icon: Icons.person_outline, iconColor: AppColors.primary, title: "Thông tin cá nhân"),
                  const SizedBox(height: 12),
                  _buildMenuButton(icon: Icons.emoji_events_outlined, iconColor: AppColors.purple, title: "Thành tích"),
                  const SizedBox(height: 12),
                  _buildMenuButton(icon: Icons.star_border, iconColor: Colors.amber, title: "Xếp hạng", trailingText: "#156"),
                  const SizedBox(height: 12),
                  _buildMenuButton(icon: Icons.notifications_none, iconColor: Colors.grey.shade600, title: "Thông báo"),
                  const SizedBox(height: 12),
                  _buildMenuButton(icon: Icons.settings_outlined, iconColor: Colors.grey.shade600, title: "Cài đặt"),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ==========================================
            // 5. BANNER TÀI KHOẢN PREMIUM
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFA000), Color(0xFFFF6D00)], // Màu cam
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.workspace_premium, color: AppColors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Tài khoản Premium", style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                            "Truy cập không giới hạn tất cả tính năng AI và nội dung học tập cao cấp",
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          _buildPremiumFeatureCheck("Lộ trình học cá nhân hóa"),
                          const SizedBox(height: 4),
                          _buildPremiumFeatureCheck("AI trợ lý không giới hạn"),
                          const SizedBox(height: 4),
                          _buildPremiumFeatureCheck("Bài tập nâng cao"),
                          const SizedBox(height: 16),
                          const Text("Còn 23 ngày • Gia hạn ngay", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ==========================================
            // 6. NÚT ĐĂNG XUẤT
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade300, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  // Hiện hộp thoại xác nhận trước khi đăng xuất
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Đăng xuất"),
                      content: const Text("Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?"),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx), // Đóng hộp thoại
                          child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () {
                            // 1. Đóng hộp thoại
                            Navigator.pop(ctx);

                            // 2. Chuyển về màn hình AuthScreen và xóa toàn bộ lịch sử trang
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const AuthScreen()),
                                  (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text("Đăng xuất", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Đăng xuất", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text("Phiên bản 1.0.0", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HÀM WIDGET CON DÙNG CHUNG ---

  // Tag hiển thị Lớp và Premium
  Widget _buildTag(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Cột số liệu thống kê (Tổng XP, Số bài...)
  Widget _buildQuickStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }

 /* // Dòng mục tiêu học tập (Trái: Nhãn, Phải: Giá trị)
  Widget _buildGoalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }*/

  // Nút bấm Menu dạng danh sách
  Widget _buildMenuButton({required IconData icon, required Color iconColor, required String title, String? trailingText}) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {}, // Action khi bấm vào menu
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              if (trailingText != null)
                Text(trailingText, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // Dòng check xanh trong banner Premium
  Widget _buildPremiumFeatureCheck(String text) {
    return Row(
      children: [
        const Icon(Icons.check, color: AppColors.white, size: 14),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: AppColors.white, fontSize: 12)),
      ],
    );
  }
}
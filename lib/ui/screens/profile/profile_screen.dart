import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/auth_service.dart';
import '../auth/auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  final int userId;
  final int gradeId;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.gradeId,
  });

  @override
  Widget build(BuildContext context) {
    final String gradeText = AuthService.gradeId != null ? "Lớp ${AuthService.gradeId}" : "Lớp 10";
    final String roleText = AuthService.role == 'PREMIUM' ? "Premium" : (AuthService.role ?? "USER");
    final String nameText = AuthService.userId != null ? "Học sinh ${AuthService.userId}" : "Người dùng mới";
    final String initialChar = nameText.isNotEmpty ? nameText[0].toUpperCase() : "U";

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
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
                Container(
                  margin: const EdgeInsets.only(top: 130, left: 24, right: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(color: AppColors.purple, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text(initialChar, style: const TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nameText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("student@email.com", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildTag(gradeText, AppColors.primary),
                                    const SizedBox(width: 8),
                                    _buildTag(roleText, AppColors.purple, icon: roleText == "Premium" ? Icons.workspace_premium : Icons.person),
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
            if (roleText != "Premium")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA000), Color(0xFFFF6D00)],
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
                            const Text("Nâng cấp ngay", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),
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
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Đăng xuất"),
                      content: const Text("Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?"),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await AuthService.logout();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const AuthScreen()),
                                    (Route<dynamic> route) => false,
                              );
                            }
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

  Widget _buildQuickStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuButton({required IconData icon, required Color iconColor, required String title, String? trailingText}) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
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
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/services/profile_service.dart';
import '../auth/auth_screen.dart';
import 'user_info_screen.dart'; // Import màn hình mới

class ProfileScreen extends StatefulWidget {
  final int userId;
  final int gradeId;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.gradeId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  ProfileResponse? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _profileService.getProfile(widget.userId);
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      // Ẩn lỗi, để UI vẫn render với dữ liệu null (trống/mặc định)
      setState(() {
        _isLoading = false;
      });
      debugPrint("Lỗi tải Profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Không chặn màn hình bằng lỗi nữa, thay vào đó hiển thị vòng xoay mờ hoặc bỏ qua
    // Map dữ liệu từ API (nếu null thì lấy mặc định)
    final String gradeText = _profileData?.gradeName ?? "Lớp ${widget.gradeId}";
    final bool isPremium = _profileData?.isPremium ?? false;
    final String roleText = isPremium ? "Premium" : "Học sinh";
    final String nameText = _profileData?.fullName ?? "Chưa có tên";
    final String emailText = _profileData?.email ?? "Chưa cập nhật email";
    final String initialChar = nameText.isNotEmpty && nameText != "Chưa có tên" ? nameText[0].toUpperCase() : "U";

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Background Header
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

                // Thẻ thông tin User
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
                          // Avatar
                          _profileData?.avatarUrl != null && _profileData!.avatarUrl!.isNotEmpty
                              ? CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage(_profileData!.avatarUrl!),
                            backgroundColor: Colors.grey.shade200,
                          )
                              : Container(
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
                                Text(nameText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(emailText, style: TextStyle(color: Colors.grey.shade600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildTag(gradeText, AppColors.primary),
                                    const SizedBox(width: 8),
                                    _buildTag(roleText, isPremium ? Colors.amber.shade700 : AppColors.purple, icon: isPremium ? Icons.workspace_premium : Icons.person),
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
                      // Thống kê nhanh
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickStat("${_profileData?.totalXp ?? 0}", "Tổng XP"),
                          _buildQuickStat("${_profileData?.totalLesson ?? 0}", "Bài đã học"),
                          _buildQuickStat("${_profileData?.streakDay ?? 0}", "Streak"),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Menu chức năng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildMenuButton(
                      icon: Icons.person_outline,
                      iconColor: AppColors.primary,
                      title: "Thông tin cá nhân",
                      onTap: () {
                        // Đẩy sang trang UserInfoScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserInfoScreen(
                              userId: widget.userId,
                              gradeId: widget.gradeId,
                            ),
                          ),
                        ).then((_) {
                          // Gọi lại API khi quay về để update UI nếu có thay đổi
                          _fetchProfileData();
                        });
                      }
                  ),
                  const SizedBox(height: 12),
                  _buildMenuButton(icon: Icons.emoji_events_outlined, iconColor: AppColors.purple, title: "Thành tích", onTap: () {}),
                  const SizedBox(height: 12),
                  _buildMenuButton(icon: Icons.notifications_none, iconColor: Colors.grey.shade600, title: "Thông báo", onTap: () {}),
                  const SizedBox(height: 12),
                  _buildMenuButton(icon: Icons.settings_outlined, iconColor: Colors.grey.shade600, title: "Cài đặt", onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Ẩn Banner Premium nếu user đã là Premium
            if (!isPremium)
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

            // Nút Đăng xuất
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
    // Giữ nguyên như cũ
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
          Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label) {
    // Giữ nguyên như cũ
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }

  // ĐÃ THÊM ONTAP VÀO ĐÂY
  Widget _buildMenuButton({required IconData icon, required Color iconColor, required String title, String? trailingText, VoidCallback? onTap}) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
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
    // Giữ nguyên như cũ
    return Row(
      children: [
        const Icon(Icons.check, color: AppColors.white, size: 14),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: AppColors.white, fontSize: 12)),
      ],
    );
  }
}
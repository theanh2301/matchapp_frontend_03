import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/auth_service.dart';
import '../../widget/robot_mascot.dart';
import '../main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Biến lưu trữ ID lớp được chọn (từ 6 đến 12)
  int? _selectedClassId;

  void _handleAuth() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isLogin) {
        await AuthService.login(
          _emailController.text.trim(),
          _passController.text.trim(),
        );
        if (mounted) {
          _showSnackBar("Đăng nhập thành công!", AppColors.green);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
                (Route<dynamic> route) => false,
          );
        }
      } else {
        // LƯU Ý: Bạn cần cập nhật hàm register trong AuthService để nhận thêm tham số classId
        await AuthService.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passController.text.trim(),
          _confirmPassController.text.trim(),
          _selectedClassId!, // Truyền ID lớp vào đây
        );
        if (mounted) {
          _showSnackBar("Đăng ký thành công! Mời bạn đăng nhập.", AppColors.green);
          setState(() {
            isLogin = true;
            _passController.clear();
            _confirmPassController.clear();
            _selectedClassId = null; // Reset lại trường chọn lớp
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll("Exception: ", ""));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text("Lỗi", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(msg, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Đóng", style: TextStyle(color: AppColors.primary)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgLight, AppColors.robotMouthBgLight, AppColors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              children: [
                const RobotMascot(size: 100, isWhiteStyle: false),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthToggleSwitch(
                          isLogin: isLogin,
                          onToggle: (value) => setState(() {
                            isLogin = value;
                            _formKey.currentState?.reset();
                            _selectedClassId = null; // Reset lại dropdown khi chuyển tab
                          }),
                        ),
                        const SizedBox(height: 30),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              if (!isLogin) ...[
                                CustomTextField(
                                  controller: _nameController,
                                  icon: Icons.person_outline,
                                  hint: "Họ và tên",
                                  validator: (val) => val!.isEmpty ? "Vui lòng nhập họ tên" : null,
                                ),
                                const SizedBox(height: 16),

                                // === Thêm CustomDropdownField cho việc chọn lớp ===
                                CustomDropdownField<int>(
                                  value: _selectedClassId,
                                  hint: "Chọn lớp",
                                  icon: Icons.school_outlined,
                                  items: [6, 7, 8, 9, 10, 11, 12]
                                      .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text("Lớp $e", style: const TextStyle(fontSize: 15)),
                                  ))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedClassId = val;
                                    });
                                  },
                                  validator: (val) => val == null ? "Vui lòng chọn lớp của bạn" : null,
                                ),
                                const SizedBox(height: 16),
                              ],
                              CustomTextField(
                                controller: _emailController,
                                icon: Icons.email_outlined,
                                hint: "Email",
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val!.isEmpty) return "Vui lòng nhập email";
                                  if (!val.contains('@')) return "Email không hợp lệ";
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _passController,
                                icon: Icons.lock_outline,
                                hint: "Mật khẩu",
                                isPassword: true,
                                validator: (val) => val!.length < 6 ? "Mật khẩu tối thiểu 6 ký tự" : null,
                              ),
                              if (!isLogin) ...[
                                const SizedBox(height: 16),
                                CustomTextField(
                                  controller: _confirmPassController,
                                  icon: Icons.lock_outline,
                                  hint: "Nhập lại mật khẩu",
                                  isPassword: true,
                                  validator: (val) {
                                    if (val!.isEmpty) return "Vui lòng xác nhận mật khẩu";
                                    if (val != _passController.text) return "Mật khẩu không khớp";
                                    return null;
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isLogin) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text("Quên mật khẩu?", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ] else
                          const SizedBox(height: 24),
                        PrimaryGradientButton(
                          text: isLogin ? "Đăng nhập" : "Đăng ký",
                          isLoading: _isLoading,
                          onPressed: _handleAuth,
                        ),
                        const SizedBox(height: 30),
                        const SocialLoginSection(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const TermsAndPolicyText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// === WIDGET MỚI: CustomDropdownField ===
// Copy phong cách thiết kế từ CustomTextField để giao diện đồng bộ 100%
class CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String hint;
  final IconData icon;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.icon,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade300)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon, color: Colors.grey.shade400, size: 22),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade400, size: 20),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        )
            : null,
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade300)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      ),
    );
  }
}

class PrimaryGradientButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const PrimaryGradientButton({super.key, required this.text, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]),
        boxShadow: [
          BoxShadow(color: AppColors.gradientStart.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

class AuthToggleSwitch extends StatelessWidget {
  final bool isLogin;
  final Function(bool) onToggle;

  const AuthToggleSwitch({super.key, required this.isLogin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          _buildToggleBtn("Đăng nhập", true),
          _buildToggleBtn("Đăng ký", false),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool targetValue) {
    final isActive = isLogin == targetValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onToggle(targetValue),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isActive ? AppColors.primary : Colors.grey.shade500),
          ),
        ),
      ),
    );
  }
}

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("Hoặc tiếp tục với", style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            ),
            Expanded(child: Divider(color: Colors.grey.shade200)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildSocialBtn("Google", Icons.g_mobiledata, Colors.red)),
            const SizedBox(width: 16),
            Expanded(child: _buildSocialBtn("Facebook", Icons.facebook, Colors.blue)),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialBtn(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800, fontSize: 14)),
        ],
      ),
    );
  }
}

class TermsAndPolicyText extends StatelessWidget {
  const TermsAndPolicyText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.6),
          children: [
            TextSpan(text: "Bằng cách tiếp tục, bạn đồng ý với\n"),
            TextSpan(text: "Điều khoản dịch vụ", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
            TextSpan(text: " và "),
            TextSpan(text: "Chính sách bảo mật", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/services/profile_service.dart';

class UserInfoScreen extends StatefulWidget {
  final int userId;
  final int gradeId;

  const UserInfoScreen({super.key, required this.userId, required this.gradeId});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  // Controllers cho form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();

  int? _selectedGradeId;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    setState(() => _isLoading = true);
    try {
      final info = await _profileService.getUserInfo(widget.userId);

      // Gán dữ liệu vào TextControllers
      _nameController.text = info.fullName ?? '';
      _emailController.text = info.email ?? '';
      _phoneController.text = info.phone ?? '';
      _dobController.text = info.dob ?? '';
      _avatarUrlController.text = info.avatarUrl ?? '';

      _selectedGradeId = widget.gradeId;

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Lỗi tải UserInfo: $e");
    }
  }

  // HÀM MỚI: Hiển thị bộ chọn ngày của Flutter
  Future<void> _selectDate(BuildContext context) async {
    if (!_isEditing) return; // Chỉ cho phép chọn khi đang bật chế độ chỉnh sửa

    DateTime initialDate = DateTime.now();

    // Nếu đã có ngày sinh cũ thì parse nó ra để chọn làm mốc mặc định
    if (_dobController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_dobController.text);
      } catch (e) {
        debugPrint("Lỗi parse ngày: $e");
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900), // Cho phép chọn từ năm 1900
      lastDate: DateTime.now(),  // Không cho chọn ngày trong tương lai
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary, // Đổi màu bộ chọn theo màu chủ đạo của app
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Format lại đúng chuẩn YYYY-MM-DD để gửi lên backend Spring Boot
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final request = UpdateUserInfoRequest(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      dob: _dobController.text.trim(),
      gradeId: _selectedGradeId,
      avatarUrl: _avatarUrlController.text.trim(),
    );

    try {
      await _profileService.updateUserInfo(widget.userId, request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật thông tin thành công!"), backgroundColor: AppColors.green),
        );
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text("Thông tin cá nhân", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Họ và tên", _nameController, icon: Icons.person),
              const SizedBox(height: 16),
              _buildTextField("Email", _emailController, icon: Icons.email, isEmail: true),
              const SizedBox(height: 16),
              _buildTextField("Số điện thoại", _phoneController, icon: Icons.phone, isPhone: true),
              const SizedBox(height: 16),

              // ĐÃ SỬA: Form nhập Ngày sinh (Khóa bàn phím và gọi popup DatePicker)
              _buildTextField(
                "Ngày sinh",
                _dobController,
                icon: Icons.calendar_today,
                readOnly: true, // Không cho hiện bàn phím ảo
                onTap: () => _selectDate(context), // Mở lịch khi bấm vào
              ),

              const SizedBox(height: 16),
              _buildTextField("Link Avatar", _avatarUrlController, icon: Icons.image),
              const SizedBox(height: 16),

              // Grade Dropdown
              const Text("Lớp học", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedGradeId,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.school, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
                ),
                items: List.generate(12, (index) => index + 1).map((grade) {
                  return DropdownMenuItem(value: grade, child: Text("Lớp $grade"));
                }).toList(),
                onChanged: _isEditing ? (val) => setState(() => _selectedGradeId = val) : null,
              ),

              const SizedBox(height: 32),

              // Nút bấm Chỉnh sửa / Lưu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditing ? AppColors.green : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving
                      ? null
                      : () {
                    if (_isEditing) {
                      _submitUpdate();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                      _isEditing ? "Lưu thông tin" : "Chỉnh sửa",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ),
              ),

              // Nút Hủy (Chỉ hiện khi đang sửa)
              if (_isEditing) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      setState(() => _isEditing = false);
                      _fetchUserInfo(); // Tải lại data gốc
                    },
                    child: const Text("Hủy", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // ĐÃ CẬP NHẬT: Thêm biến readOnly và sự kiện onTap
  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        required IconData icon,
        bool isEmail = false,
        bool isPhone = false,
        bool readOnly = false,
        VoidCallback? onTap,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          readOnly: readOnly, // Nếu là true, bàn phím ảo sẽ không nhảy lên
          onTap: onTap,       // Bắt sự kiện chạm vào textfield
          keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
          ),
        ),
      ],
    );
  }
}
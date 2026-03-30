import 'package:flutter/material.dart';
import 'package:learn_math_app_03/ui/screens/practice/practice_screen.dart';
import 'package:learn_math_app_03/ui/screens/profile/profile_screen.dart';
import 'package:learn_math_app_03/ui/screens/progress/progress_screen.dart';
import '../../core/theme/app_colors.dart';
import 'home/home_screen.dart';
import 'learn/subjects_screen.dart'; // Import file HomeScreen mới tách

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình tương ứng với từng Tab
  final List<Widget> _screens = [
    const HomeScreen(),      // Tab 0: Trang chủ (Đã được tách ra file riêng)
    const LearnScreen(),
    const PracticeScreen(),
    const ProgressScreen(),
    const ProfileScreen()// Tab 4: Cá nhân
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Trang chủ"),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: "Học"),
            BottomNavigationBarItem(icon: Icon(Icons.bolt_rounded), label: "Luyện tập"),
            BottomNavigationBarItem(icon: Icon(Icons.trending_up_rounded), label: "Tiến độ"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: "Cá nhân"),
          ],
        ),
      ),
    );
  }
}
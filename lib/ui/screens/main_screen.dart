import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learn_math_app_03/ui/screens/practice/practice_screen.dart';
import 'package:learn_math_app_03/ui/screens/profile/profile_screen.dart';
import 'package:learn_math_app_03/ui/screens/progress/progress_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';
import 'ai/ai_chat_screen.dart';
import 'auth/auth_screen.dart';
import 'home/home_screen.dart';
import 'learn/subjects_screen.dart';
import '../utils/responsive.dart';

class MainScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final String className;

  const MainScreen({
    super.key,
    this.userId = 1,
    this.userName = 'Học sinh',
    this.className = 'Lớp 10',
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late List<Widget> _screens;
  Timer? _sessionTimer;

  bool get _showGlobalAiButton => _currentIndex != 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkSessionExpired(),
    );

    int currentUserId = AuthService.userId ?? widget.userId;
    int currentGradeId = AuthService.gradeId ?? 10;
    String currentClassName = AuthService.gradeId != null
        ? "Lớp ${AuthService.gradeId}"
        : widget.className;
    String currentUserName = AuthService.userId != null
        ? "ID: $currentUserId"
        : widget.userName;

    _screens = [
      HomeScreen(
        userId: currentUserId,
        userName: currentUserName,
        className: currentClassName,
        onNavigateToLearn: () {
          setState(() {
            _currentIndex = 1;
          });
        },
        onNavigateToPractice: () {
          setState(() {
            _currentIndex = 2;
          });
        },
      ),
      LearnScreen(userId: currentUserId, gradeId: currentGradeId),
      PracticeScreen(userId: currentUserId, gradeId: currentGradeId),
      ProgressScreen(userId: currentUserId, gradeId: currentGradeId),
      ProfileScreen(userId: currentUserId, gradeId: currentGradeId),
    ];
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkSessionExpired();
    }
  }

  Future<void> _checkSessionExpired() async {
    if (!await AuthService.isSessionExpired()) return;
    await AuthService.logout();

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  void _openGlobalAiChat() {
    final currentUserId = AuthService.userId ?? widget.userId;
    final screenName = switch (_currentIndex) {
      0 => 'Home',
      1 => 'Learn',
      2 => 'Practice overview',
      3 => 'Progress',
      _ => 'Main',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AiChatScreen(userId: currentUserId, context: '$screenName screen.'),
      ),
    );
  }

  Widget? _buildGlobalAiButton() {
    if (!_showGlobalAiButton) return null;

    return FloatingActionButton(
      tooltip: 'Hỏi AI',
      heroTag: 'global_ai_chat_button',
      onPressed: _openGlobalAiChat,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      child: const Icon(Icons.smart_toy_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    if (isTablet) {
      return Scaffold(
        backgroundColor: AppColors.bgLight,
        floatingActionButton: _buildGlobalAiButton(),
        body: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  minWidth: 86,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: AppColors.white,
                  selectedIconTheme: const IconThemeData(
                    color: AppColors.primary,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: Colors.grey.shade400,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_filled),
                      label: Text("Trang chá»§"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book_rounded),
                      label: Text("Há»c"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bolt_rounded),
                      label: Text("Luyá»‡n táº­p"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.trending_up_rounded),
                      label: Text("Tiáº¿n Ä‘á»™"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      label: Text("CÃ¡ nhÃ¢n"),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: _screens[_currentIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      floatingActionButton: _buildGlobalAiButton(),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
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
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Trang chủ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: "Học",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bolt_rounded),
              label: "Luyện tập",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_rounded),
              label: "Tiến độ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: "Cá nhân",
            ),
          ],
        ),
      ),
    );
  }
}

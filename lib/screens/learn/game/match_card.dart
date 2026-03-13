import 'dart:async';
import 'dart:ui'; // Thêm thư viện này để dùng hiệu ứng kính mờ (BackdropFilter)
import 'package:flutter/material.dart';

// MÔ HÌNH DỮ LIỆU THẺ
class MatchCard {
  final int id;
  final String text;
  final int pairId;
  bool isSelected;
  bool isMatched;

  MatchCard({
    required this.id,
    required this.text,
    required this.pairId,
    this.isSelected = false,
    this.isMatched = false,
  });
}

class MatchCardGameScreen extends StatefulWidget {
  const MatchCardGameScreen({super.key});

  @override
  State<MatchCardGameScreen> createState() => _MatchCardGameScreenState();
}

class _MatchCardGameScreenState extends State<MatchCardGameScreen> {
  List<MatchCard> _cards = [];
  int? _firstSelectedIndex;
  int _score = 0;
  bool _isProcessing = false;
  bool _isFinished = false; // Thêm biến kiểm tra trạng thái hoàn thành

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  // KHỞI TẠO BỘ THẺ DỰA TRÊN ẢNH
  void _initializeGame() {
    _cards.clear(); // Xóa thẻ cũ nếu đang chơi lại

    // Dữ liệu mẫu theo ảnh
    _cards.add(MatchCard(id: 1, text: 'Phương trình bậc\n2', pairId: 1));
    _cards.add(MatchCard(id: 2, text: 'ax² + bx + c = 0\n(a ≠ 0)', pairId: 1));
    _cards.add(MatchCard(id: 3, text: 'Delta (Δ)', pairId: 2));
    _cards.add(MatchCard(id: 4, text: 'Δ = b² - 4ac', pairId: 2));
    _cards.add(MatchCard(id: 5, text: 'Hai nghiệm phân\nbiệt', pairId: 3));
    _cards.add(MatchCard(id: 6, text: 'Phương trình có\nΔ > 0', pairId: 3));
    _cards.add(MatchCard(id: 7, text: 'Nghiệm kép', pairId: 4));
    _cards.add(MatchCard(id: 8, text: 'Phương trình có\nΔ = 0', pairId: 4));
    _cards.add(MatchCard(id: 9, text: 'Định lý Vi-et', pairId: 5));
    _cards.add(MatchCard(id: 10, text: 'x₁ + x₂ = -b/a,\nx₁·x₂ = c/a', pairId: 5));
    _cards.add(MatchCard(id: 11, text: 'Công thức\nnghiệm', pairId: 6));
    _cards.add(MatchCard(id: 12, text: 'x = (-b ± √Δ) /\n2a', pairId: 6));

    // Xáo trộn vị trí thẻ
    _cards.shuffle();
  }

  // LOGIC XỬ LÝ CHẠM
  void _onCardTap(int index) {
    if (_isProcessing || _cards[index].isSelected || _cards[index].isMatched || _isFinished) {
      return;
    }

    setState(() {
      _cards[index].isSelected = true;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _isProcessing = true;
      int firstIndex = _firstSelectedIndex!;
      int secondIndex = index;

      if (_cards[firstIndex].pairId == _cards[secondIndex].pairId) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _cards[firstIndex].isMatched = true;
            _cards[secondIndex].isMatched = true;
            _cards[firstIndex].isSelected = false;
            _cards[secondIndex].isSelected = false;
            _score += 10; // Điểm này sẽ được coi là XP
            _firstSelectedIndex = null;
            _isProcessing = false;
            _checkWinCondition();
          });
        });
      } else {
        Future.delayed(const Duration(milliseconds: 600), () {
          setState(() {
            _cards[firstIndex].isSelected = false;
            _cards[secondIndex].isSelected = false;
            _firstSelectedIndex = null;
            _isProcessing = false;
          });
        });
      }
    }
  }

  void _checkWinCondition() {
    if (_cards.every((card) => card.isMatched)) {
      // Cập nhật trạng thái hoàn thành để kích hoạt khung thông báo
      setState(() {
        _isFinished = true;
      });
    }
  }

  // HÀM CHƠI LẠI TỪ ĐẦU
  void _playAgain() {
    setState(() {
      _isFinished = false;
      _score = 0;
      _firstSelectedIndex = null;
      _isProcessing = false;
      _initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7141FF), // Nền tím (như ảnh)
      body: SafeArea(
        child: Stack( // Sử dụng Stack để đè khung thông báo lên lưới thẻ
          children: [
            // ==========================================
            // GIAO DIỆN GAME CHÍNH (Nằm dưới cùng)
            // ==========================================
            Column(
              children: [
                // 1. TOP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.yellowAccent, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '$_score XP', // Đổi chữ 'điểm' thành 'XP'
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. LƯỚI THẺ
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        return GestureDetector(
                          onTap: () => _onCardTap(index),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: card.isMatched ? 0.3 : (card.isSelected ? 0.7 : 1.0),
                            child: _buildCardUI(card),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),

            // ==========================================
            // KHUNG THÔNG BÁO HOÀN THÀNH TRONG SUỐT (Nằm trên cùng)
            // ==========================================
            if (_isFinished) _buildGlassOverlay(),
          ],
        ),
      ),
    );
  }

  // Giao diện thẻ cơ bản
  Widget _buildCardUI(MatchCard card) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2D5B),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          card.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // HÀM TẠO KHUNG THÔNG BÁO KÍNH MỜ (GLASSMORPHISM)
  Widget _buildGlassOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), // Làm mờ màn hình game phía sau
        child: Container(
          color: Colors.black.withOpacity(0.2), // Làm tối nền nhẹ một chút
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15), // Nền trong suốt
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5), // Viền sáng nhẹ
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                    const SizedBox(height: 16),
                    const Text(
                      'Hoàn thành!',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 24),

                    // Nút hiển thị XP nhận được
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            '+$_score XP',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Nút điều hướng
                    Row(
                      children: [
                        // Nút Chơi Lại
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _playAgain,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.6)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Chơi lại', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Nút Tiếp Tục
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, true); // Thoát game và trả về true
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent.shade400,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Tiếp tục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
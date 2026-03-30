import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../data/models/match_card_model.dart';
import '../../../../data/services/match_card_service.dart';

// MÔ HÌNH DỮ LIỆU THẺ DÙNG CHO GIAO DIỆN
class MatchCard {
  final int id; // ID duy nhất cho UI
  final String text;
  final int pairId;
  final int xpReward;
  bool isSelected;
  bool isMatched;

  MatchCard({
    required this.id,
    required this.text,
    required this.pairId,
    required this.xpReward,
    this.isSelected = false,
    this.isMatched = false,
  });
}

class MatchCardGameScreen extends StatefulWidget {
  final int lessonId; // Thêm ID bài học để gọi API

  const MatchCardGameScreen({super.key, required this.lessonId});

  @override
  State<MatchCardGameScreen> createState() => _MatchCardGameScreenState();
}

class _MatchCardGameScreenState extends State<MatchCardGameScreen> {
  final MatchCardService _matchCardService = MatchCardService();

  bool _isLoading = true;
  bool _hasError = false;

  List<MatchCard> _cards = [];
  List<MatchCardModel> _apiData = [];

  int? _firstSelectedIndex;
  int _score = 0;
  bool _isProcessing = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _fetchMatchCards();
  }

  // GỌI API LẤY DỮ LIỆU
  Future<void> _fetchMatchCards() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _matchCardService.getMatchCardsByLesson(widget.lessonId);
      if (mounted) {
        setState(() {
          _apiData = result;
          _isLoading = false;
          _setupCards(); // Biến đổi data API thành thẻ
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  // BIẾN ĐỔI DATA TỪ API THÀNH THẺ UI
  void _setupCards() {
    _cards.clear();

    for (var item in _apiData) {
      // Vì API đã tách sẵn từng thẻ, ta chỉ việc map trực tiếp 1-1
      _cards.add(MatchCard(
          id: item.id,
          text: item.content, // Lấy trường content (Dog, Chó, Cat...)
          pairId: item.pairId, // Lấy pairId để ghép cặp
          xpReward: item.xpReward // XP thưởng khi ghép trúng
      ));
    }

    _cards.shuffle(); // Xáo trộn vị trí các thẻ
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

      // KIỂM TRA ĐÚNG CẶP
      if (_cards[firstIndex].pairId == _cards[secondIndex].pairId) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _cards[firstIndex].isMatched = true;
            _cards[secondIndex].isMatched = true;
            _cards[firstIndex].isSelected = false;
            _cards[secondIndex].isSelected = false;

            // Cộng điểm XP linh động theo API
            _score += _cards[firstIndex].xpReward;

            _firstSelectedIndex = null;
            _isProcessing = false;
            _checkWinCondition();
          });
        });
      } else {
        // SAI CẶP -> ĐÓNG THẺ LẠI
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
    if (_cards.isNotEmpty && _cards.every((card) => card.isMatched)) {
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
      _setupCards(); // Khởi tạo lại thẻ và xáo trộn lại
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7141FF),
      body: SafeArea(
        child: Stack(
          children: [
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
                              '$_score XP',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. LƯỚI THẺ / LOADING / LỖI
                Expanded(
                  child: _buildBodyContent(),
                ),
                const SizedBox(height: 16),
              ],
            ),

            // KHUNG THÔNG BÁO HOÀN THÀNH
            if (_isFinished) _buildGlassOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.white),
            const SizedBox(height: 16),
            const Text("Không thể tải thẻ ghép", style: TextStyle(color: Colors.white, fontSize: 18)),
            TextButton(
              onPressed: _fetchMatchCards,
              child: const Text("Thử lại", style: TextStyle(color: Colors.yellowAccent)),
            )
          ],
        ),
      );
    }

    if (_cards.isEmpty) {
      return const Center(
        child: Text("Chưa có thẻ ghép nào.", style: TextStyle(color: Colors.white, fontSize: 16)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75, // Chỉnh lại tỷ lệ chút cho vừa vặn chữ
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
              opacity: card.isMatched ? 0.0 : (card.isSelected ? 0.6 : 1.0), // isMatched thì tàng hình luôn
              child: _buildCardUI(card),
            ),
          );
        },
      ),
    );
  }

  // Giao diện thẻ cơ bản
  Widget _buildCardUI(MatchCard card) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2D5B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: card.isSelected ? Colors.yellowAccent : Colors.transparent,
            width: 2
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          card.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16, // Phóng to chữ lên chút
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // KHUNG THÔNG BÁO HOÀN THÀNH TRONG SUỐT
  Widget _buildGlassOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          color: Colors.black.withOpacity(0.2),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                    const SizedBox(height: 16),
                    const Text('Hoàn thành!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 24),
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
                          Text('+$_score XP', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
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
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
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
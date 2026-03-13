import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class FlashcardGameScreen extends StatelessWidget {
  const FlashcardGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: const MathFlashcardScreen(),
    );
  }
}

class MathFlashcardScreen extends StatefulWidget {
  const MathFlashcardScreen({super.key});

  @override
  State<MathFlashcardScreen> createState() => _MathFlashcardScreenState();
}

class _MathFlashcardScreenState extends State<MathFlashcardScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  int _resetKey = 0;
  int _currentIndex = 0;
  int _notMemorizedCount = 0;
  int _memorizedCount = 0;

  final List<CardSwiperDirection> _swipeHistory = [];

  final List<Map<String, String>> _cards = [
    {'q': 'Định lý Pythagore áp dụng cho tam giác nào?', 'a': 'Tam giác vuông'},
    {'q': 'Tính: ∫(2x + 1) dx', 'a': 'x^2 + x + C'},
    {'q': 'Công thức tính diện tích hình tròn?', 'a': 'S = π * r^2'},
    {'q': 'Đạo hàm của sin(x) là gì?', 'a': 'cos(x)'},
    {'q': 'Căn bậc hai của 144?', 'a': '12'},
  ];

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    setState(() {
      _swipeHistory.add(direction);

      if (direction == CardSwiperDirection.left) {
        _notMemorizedCount++;
      } else if (direction == CardSwiperDirection.right) {
        _memorizedCount++;
      }
      _currentIndex = currentIndex ?? _cards.length;
    });
    return true;
  }

  bool _onUndo(int? previousIndex, int currentIndex, CardSwiperDirection direction) {
    setState(() {
      if (_swipeHistory.isNotEmpty) {
        final lastDirection = _swipeHistory.removeLast();
        if (lastDirection == CardSwiperDirection.left && _notMemorizedCount > 0) {
          _notMemorizedCount--;
        } else if (lastDirection == CardSwiperDirection.right && _memorizedCount > 0) {
          _memorizedCount--;
        }
      }
      _currentIndex = previousIndex ?? 0;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    bool isFinished = _currentIndex >= _cards.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE040FB), Color(0xFF7B1FA2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. TOP BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context, false), // Trả về false (chưa hoàn thành)
                    ),
                    Text(
                      '${isFinished ? _cards.length : _currentIndex + 1} / ${_cards.length}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // 2. THANH TIẾN TRÌNH
              SizedBox(
                height: 4, // Độ dày của thanh
                child: LinearProgressIndicator(
                  value: _cards.isEmpty ? 0.0 : (_currentIndex / _cards.length).clamp(0.0, 1.0),
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
              ),
              const SizedBox(height: 24),

              // 3. SCORE BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildScoreItem('$_notMemorizedCount', const Color(0xffff9800)),
                    _buildScoreItem('$_memorizedCount', const Color(0xff4caf50)),
                  ],
                ),
              ),

              // 4. KHU VỰC THẺ
              Expanded(
                child: Stack(
                  children: [
                    AnimatedOpacity(
                      opacity: isFinished ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: isFinished ? _buildFinishedScreen() : const SizedBox.shrink(),
                    ),

                    IgnorePointer(
                      ignoring: isFinished,
                      child: CardSwiper(
                        key: ValueKey(_resetKey),
                        controller: _swiperController,
                        cardsCount: _cards.length,
                        isLoop: false,
                        onSwipe: _onSwipe,
                        onUndo: _onUndo,
                        numberOfCardsDisplayed: 2,
                        backCardOffset: const Offset(0, 30),
                        scale: 0.9,
                        maxAngle: 30,
                        allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
                        padding: const EdgeInsets.all(24.0),
                        cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
                          return _buildQuizletStyleCard(_cards[index], horizontalOffsetPercentage);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 5. THANH ĐIỀU HƯỚNG DƯỚI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.undo, color: (_currentIndex > 0 && !isFinished) ? Colors.white : Colors.white30, size: 30),
                      onPressed: (_currentIndex > 0 && !isFinished) ? () => _swiperController.undo() : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.play_arrow, color: !isFinished ? Colors.white : Colors.white30, size: 36),
                      onPressed: !isFinished ? () => _swiperController.swipe(CardSwiperDirection.right) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreItem(String score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF231557).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Text(
        score,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildQuizletStyleCard(Map<String, String> cardData, int horizontalOffsetPercentage) {
    double offsetValue = horizontalOffsetPercentage / 10000.0;
    double swipeOpacity = offsetValue.abs().clamp(0.0, 1.0);

    bool isSwipingRight = offsetValue > 0;
    bool isSwipingLeft = offsetValue < 0;

    return Stack(
      children: [
        FlipCard(
          direction: FlipDirection.HORIZONTAL,
          front: _buildCardContent(content: cardData['q']!, isQuestion: true),
          back: _buildCardContent(content: cardData['a']!, isQuestion: false),
        ),

        if (isSwipingRight || isSwipingLeft)
          IgnorePointer(
            child: Opacity(
              opacity: swipeOpacity,
              child: Container(
                decoration: BoxDecoration(
                  color: isSwipingRight ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSwipingRight ? Colors.green : Colors.orange,
                    width: 4,
                  ),
                ),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  isSwipingRight ? "BIẾT" : "ĐANG HỌC",
                  style: TextStyle(
                    color: isSwipingRight ? Colors.greenAccent : Colors.orangeAccent,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCardContent({required String content, required bool isQuestion}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C2D5B),
            Color(0xFF1A1A32),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10)
          )
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: Icon(
              Icons.star_border,
              color: isQuestion ? Colors.white54 : Colors.amberAccent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isQuestion ? 24 : 28,
                  fontWeight: isQuestion ? FontWeight.w500 : FontWeight.bold,
                  color: isQuestion ? Colors.white : const Color(0xFFE0E0FF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 100),
          const SizedBox(height: 20),
          const Text(
            "Bạn đã hoàn thành bài học!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24, // Màu chìm hơn một chút
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text("Học lại", style: TextStyle(fontSize: 16)),
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                    _notMemorizedCount = 0;
                    _memorizedCount = 0;
                    _swipeHistory.clear();
                    _resetKey++;
                  });
                },
              ),
              const SizedBox(width: 16),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF7B1FA2),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Tiếp theo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
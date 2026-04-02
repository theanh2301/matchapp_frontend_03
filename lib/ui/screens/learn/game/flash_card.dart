import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../../../data/models/flashcard_model.dart';
import '../../../../data/models/flashcard_progress_request.dart';
import '../../../../data/services/flashcard_service.dart';

class FlashcardGameScreen extends StatelessWidget {
  final int lessonId; // Nhận ID bài học từ màn hình LessonListScreen

  const FlashcardGameScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: MathFlashcardScreen(lessonId: lessonId),
    );
  }
}

class MathFlashcardScreen extends StatefulWidget {
  final int lessonId;
  const MathFlashcardScreen({super.key, required this.lessonId});

  @override
  State<MathFlashcardScreen> createState() => _MathFlashcardScreenState();
}

class _MathFlashcardScreenState extends State<MathFlashcardScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  final FlashcardService _flashcardService = FlashcardService();

  bool _isSaving = false;
  bool _isLoading = true;
  bool _hasError = false;
  List<FlashcardModel> _cards = [];

  int _resetKey = 0;
  int _currentIndex = 0;
  int _notMemorizedCount = 0;
  int _memorizedCount = 0;
  final List<CardSwiperDirection> _swipeHistory = [];
  final List<Map<String, dynamic>> _swipeResults = [];


  @override
  void initState() {
    super.initState();
    _fetchFlashcards();
  }

  Future<void> _fetchFlashcards() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _flashcardService.getFlashcardsByLesson(widget.lessonId);
      if (mounted) {
        setState(() {
          _cards = result;
          _isLoading = false;
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

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    setState(() {
      _swipeHistory.add(direction);

      // Ghi nhận trạng thái thẻ (Phải = Biết, Trái = Không biết)
      bool isKnown = direction == CardSwiperDirection.right;

      // Lưu lại kết quả của thẻ vừa quẹt (Giả sử FlashcardModel có thuộc tính id)
      _swipeResults.add({
        'flashcardId': _cards[previousIndex].id, // Đảm bảo gọi đúng tên biến ID của thẻ
        'isKnown': isKnown,
      });

      if (isKnown) {
        _memorizedCount++;
      } else if (direction == CardSwiperDirection.left) {
        _notMemorizedCount++;
      }
      _currentIndex = currentIndex ?? _cards.length;
    });
    return true;
  }

  // --- CẬP NHẬT HÀM _onUndo ---
  bool _onUndo(int? previousIndex, int currentIndex, CardSwiperDirection direction) {
    setState(() {
      if (_swipeHistory.isNotEmpty) {
        final lastDirection = _swipeHistory.removeLast();

        // Gỡ bỏ kết quả của thẻ cuối cùng khỏi danh sách chuẩn bị gửi API
        if (_swipeResults.isNotEmpty) {
          _swipeResults.removeLast();
        }

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

  // --- HÀM LƯU KẾT QUẢ ---
  Future<void> _handleFinishDeck(VoidCallback onSuccess) async {
    setState(() => _isSaving = true);

    // TODO: Thay bằng ID user đang đăng nhập trong app của bạn
    int currentUserId = 1;

    String lastReviewedTime = DateTime.now().toString().substring(0, 19);

    List<FlashcardProgressRequest> requests = _swipeResults.map((data) {
      return FlashcardProgressRequest(
        isKnown: data['isKnown'],
        lastReviewed: lastReviewedTime,
        totalXP: 0, // Backend đã tự tính XP nên ta truyền 0
        flashcardId: data['flashcardId'],
        userId: currentUserId,
      );
    }).toList();

    // Gọi API thông qua service
    await _flashcardService.saveMultipleProgress(requests);

    if (mounted) {
      setState(() => _isSaving = false);
      onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    Text(
                      _cards.isEmpty ? '0 / 0' : '${_currentIndex >= _cards.length ? _cards.length : _currentIndex + 1} / ${_cards.length}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // 2. THANH TIẾN TRÌNH
              SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: _cards.isEmpty ? 0.0 : (_currentIndex / _cards.length).clamp(0.0, 1.0),
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: _buildBodyContent(),
              ),
            ],
          ),
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
            const Text("Không thể tải thẻ", style: TextStyle(color: Colors.white, fontSize: 18)),
            TextButton(onPressed: _fetchFlashcards, child: const Text("Thử lại", style: TextStyle(color: Colors.greenAccent)))
          ],
        ),
      );
    }

    if (_cards.isEmpty) {
      return const Center(child: Text("Chưa có thẻ Flashcard nào.", style: TextStyle(color: Colors.white, fontSize: 16)));
    }

    bool isFinished = _currentIndex >= _cards.length;

    return Column(
      children: [
        // SCORE BAR
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
        const SizedBox(height: 16),

        // THẺ QUẸT
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
                  numberOfCardsDisplayed: _cards.length > 1 ? 2 : 1,
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

        // THANH ĐIỀU HƯỚNG DƯỚI
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
      child: Text(score, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  Widget _buildQuizletStyleCard(FlashcardModel cardData, int horizontalOffsetPercentage) {
    double offsetValue = horizontalOffsetPercentage / 10000.0;
    double swipeOpacity = offsetValue.abs().clamp(0.0, 1.0);

    bool isSwipingRight = offsetValue > 0;
    bool isSwipingLeft = offsetValue < 0;

    return Stack(
      children: [
        FlipCard(
          direction: FlipDirection.HORIZONTAL,
          front: _buildCardContent(content: cardData.frontText, isQuestion: true),
          back: _buildCardContent(content: cardData.backText, isQuestion: false),
        ),
        if (isSwipingRight || isSwipingLeft)
          IgnorePointer(
            child: Opacity(
              opacity: swipeOpacity,
              child: Container(
                decoration: BoxDecoration(
                  color: isSwipingRight ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isSwipingRight ? Colors.green : Colors.orange, width: 4),
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
          colors: [Color(0xFF2C2D5B), Color(0xFF1A1A32)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: Icon(Icons.star_border, color: isQuestion ? Colors.white54 : Colors.amberAccent),
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

  // --- CẬP NHẬT MÀN HÌNH FINISHED ---
  Widget _buildFinishedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 100),
          const SizedBox(height: 20),
          const Text("Bạn đã hoàn thành!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 30),

          // Hiển thị loading nếu đang gọi API
          if (_isSaving)
            const CircularProgressIndicator(color: Colors.greenAccent)
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Học lại", style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    _handleFinishDeck(() {
                      setState(() {
                        _currentIndex = 0;
                        _notMemorizedCount = 0;
                        _memorizedCount = 0;
                        _swipeHistory.clear();
                        _swipeResults.clear(); // Xóa lịch sử sau khi đã lưu thành công
                        _resetKey++;
                      });
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
                    // Lưu dữ liệu rồi mới thoát màn hình
                    _handleFinishDeck(() {
                      Navigator.pop(context, true);
                    });
                  },
                )
              ],
            )
        ],
      ),
    );
  }
}
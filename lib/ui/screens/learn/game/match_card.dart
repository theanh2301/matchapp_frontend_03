import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../data/models/match_card_model.dart';
import '../../../../data/models/match_card_progress_model.dart';
import '../../../../data/services/match_card_service.dart';

class MatchCard {
  final int id;
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
  final int lessonId;
  final int userId;

  const MatchCardGameScreen({
    super.key,
    required this.lessonId,
    required this.userId,
  });

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

  bool _isSaving = false;
  Timer? _timer;
  int _secondsElapsed = 0;
  int _totalPairs = 0;

  @override
  void initState() {
    super.initState();
    _fetchMatchCards();
  }

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
          _setupCards();
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
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isFinished && mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _setupCards() {
    _cards.clear();
    for (var item in _apiData) {
      _cards.add(MatchCard(
          id: item.id,
          text: item.content,
          pairId: item.pairId,
          xpReward: item.xpReward
      ));
    }

    _totalPairs = _cards.length ~/ 2;
    _cards.shuffle();
    _startTimer();
  }

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

            _score += _cards[firstIndex].xpReward;

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
    if (_cards.isNotEmpty && _cards.every((card) => card.isMatched)) {
      setState(() {
        _isFinished = true;
      });
      _timer?.cancel();
      _saveProgressToServer();
    }
  }

  Future<void> _saveProgressToServer() async {
    setState(() => _isSaving = true);

    List<MatchCardProgressRequest> request = [
      MatchCardProgressRequest(
        totalPairs: _totalPairs,
        correctPairs: _totalPairs,
        timeTaken: _secondsElapsed,
        totalXP: _score,
        lessonId: widget.lessonId,
        userId: widget.userId,
      )
    ];

    await _matchCardService.saveMatchCardProgress(request);

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  void _playAgain() {
    setState(() {
      _isFinished = false;
      _score = 0;
      _firstSelectedIndex = null;
      _isProcessing = false;
      _setupCards();
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
                Expanded(
                  child: _buildBodyContent(),
                ),
                const SizedBox(height: 16),
              ],
            ),
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
          childAspectRatio: 0.75,
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
              opacity: card.isMatched ? 0.0 : (card.isSelected ? 0.6 : 1.0),
              child: _buildCardUI(card),
            ),
          );
        },
      ),
    );
  }

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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassOverlay() {
    return Positioned.fill(
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                  const SizedBox(height: 16),
                  const Text('Hoàn thành!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Thời gian: ${_secondsElapsed}s', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 24),

                  if (_isSaving)
                    const CircularProgressIndicator(color: Colors.amber)
                  else ...[
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
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/ai_chat_service.dart';

class AiChatScreen extends StatefulWidget {
  final int userId;
  final String title;
  final String? initialMessage;
  final String? context;
  final int? currentSubjectId;
  final int? currentChapterId;
  final int? currentLessonId;

  const AiChatScreen({
    super.key,
    required this.userId,
    this.title = 'Trợ lý Toán AI',
    this.initialMessage,
    this.context,
    this.currentSubjectId,
    this.currentChapterId,
    this.currentLessonId,
  });

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final AiChatService _service = AiChatService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  String? _sessionId;
  String? _practiceSessionId;
  AiPracticeResponse? _practiceState;
  AiPracticeQuestion? _currentPracticeQuestion;
  String _practiceDifficulty = 'easy';

  bool _isSending = false;
  bool _practiceBusy = false;
  String? _selectedPracticeAnswer;

  @override
  void initState() {
    super.initState();
    _messages.add(
      const _ChatMessage(
        text:
            'Chào bạn, mình sẵn sàng giải thích bài Toán, kiểm tra cách làm hoặc tạo câu luyện tập ngắn cho bạn.',
        isUser: false,
      ),
    );

    final initial = widget.initialMessage?.trim();
    if (initial != null && initial.isNotEmpty) {
      _controller.text = initial;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final response = await _service.sendMessage(
        AiChatMessageRequest(
          userId: widget.userId,
          message: _messageWithContext(text),
          currentSubjectId: widget.currentSubjectId,
          currentChapterId: widget.currentChapterId,
          currentLessonId: widget.currentLessonId,
          sessionId: _sessionId,
        ),
      );

      if (!mounted) return;
      _addAiResponse(response);
    } catch (e) {
      if (!mounted) return;
      _addErrorMessage(_errorText(e));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isSending) return;

    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (image == null) return;

    final text = _controller.text.trim().isEmpty
        ? 'Giải bài trong ảnh giúp em'
        : _controller.text.trim();

    setState(() {
      _messages.add(
        _ChatMessage(text: text, isUser: true, imagePath: image.path),
      );
      _controller.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final response = await _service.sendImageMessage(
        userId: widget.userId,
        message: _messageWithContext(text),
        imagePath: image.path,
        currentSubjectId: widget.currentSubjectId,
        currentChapterId: widget.currentChapterId,
        currentLessonId: widget.currentLessonId,
        sessionId: _sessionId,
      );

      if (!mounted) return;
      _addAiResponse(response);
    } catch (e) {
      if (!mounted) return;
      _addErrorMessage(_errorText(e));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Chụp ảnh bài toán'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Chọn ảnh từ thư viện'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startPractice({
    String? topic,
    bool weakTopic = false,
    String? difficulty,
  }) async {
    if (_practiceBusy) return;
    if (_practiceSessionId != null && _practiceState?.active == true) {
      _showSnack('Bạn đang có một phiên luyện tập AI.');
      return;
    }

    setState(() => _practiceBusy = true);

    try {
      final response = await _service.startPractice(
        AiPracticeStartRequest(
          userId: widget.userId,
          topic: topic?.trim().isEmpty == true ? null : topic,
          difficulty: difficulty ?? _practiceDifficulty,
          weakTopic: weakTopic,
          currentSubjectId: widget.currentSubjectId,
          currentChapterId: widget.currentChapterId,
          currentLessonId: widget.currentLessonId,
        ),
      );

      if (!mounted) return;
      setState(() {
        _practiceState = response;
        _practiceSessionId = response.practiceSessionId;
        _currentPracticeQuestion = response.question;
        _selectedPracticeAnswer = null;
      });
      _showSnack('Đã bắt đầu luyện tập AI.');
    } catch (e) {
      if (!mounted) return;
      _showSnack(_errorText(e));
    } finally {
      if (mounted) setState(() => _practiceBusy = false);
    }
  }

  Future<void> _answerPractice(String answer) async {
    final sessionId = _practiceSessionId;
    if (sessionId == null || _practiceBusy) return;

    setState(() {
      _practiceBusy = true;
      _selectedPracticeAnswer = answer;
    });

    try {
      final response = await _service.answerPractice(
        userId: widget.userId,
        practiceSessionId: sessionId,
        answer: answer,
      );

      if (!mounted) return;
      setState(() => _practiceState = response);
    } catch (e) {
      if (!mounted) return;
      _showSnack(_errorText(e));
    } finally {
      if (mounted) setState(() => _practiceBusy = false);
    }
  }

  Future<void> _nextPractice() async {
    final sessionId = _practiceSessionId;
    if (sessionId == null || _practiceBusy) return;

    setState(() => _practiceBusy = true);

    try {
      final response = await _service.nextPractice(
        userId: widget.userId,
        practiceSessionId: sessionId,
      );

      if (!mounted) return;
      setState(() {
        _practiceState = response;
        _currentPracticeQuestion = response.question;
        _selectedPracticeAnswer = null;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack(_errorText(e));
    } finally {
      if (mounted) setState(() => _practiceBusy = false);
    }
  }

  Future<void> _stopPractice() async {
    final sessionId = _practiceSessionId;
    if (sessionId == null || _practiceBusy) return;

    setState(() => _practiceBusy = true);

    try {
      final response = await _service.stopPractice(
        userId: widget.userId,
        practiceSessionId: sessionId,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text:
                'Phiên luyện tập đã dừng. Điểm của bạn: ${response.score}/${response.totalAnswered}.',
            isUser: false,
          ),
        );
        _practiceState = null;
        _practiceSessionId = null;
        _currentPracticeQuestion = null;
        _selectedPracticeAnswer = null;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      _showSnack(_errorText(e));
    } finally {
      if (mounted) setState(() => _practiceBusy = false);
    }
  }

  void _addAiResponse(AiChatResponse response) {
    setState(() {
      _sessionId = response.sessionId ?? _sessionId;
      _messages.add(
        _ChatMessage(
          text: response.answer.isEmpty
              ? 'AI chưa trả về nội dung phản hồi.'
              : response.answer,
          isUser: false,
          suggestPractice: response.suggestPractice,
          suggestedTopic: response.suggestedTopic,
          weakTopics: response.weakTopics,
        ),
      );
    });
  }

  void _addErrorMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: false, isError: true));
    });
  }

  void _newChat() {
    setState(() {
      _sessionId = null;
      _messages
        ..clear()
        ..add(
          const _ChatMessage(
            text: 'Mình đã mở một cuộc trò chuyện mới. Bạn muốn hỏi bài nào?',
            isUser: false,
          ),
        );
    });
  }

  String _messageWithContext(String message) {
    final contextText = widget.context?.trim();
    if (contextText == null || contextText.isEmpty) return message;
    return '$message\n\nNgữ cảnh màn hình hiện tại:\n$contextText';
  }

  String _errorText(Object error) {
    if (error is AiApiException) return error.message;
    return 'AI hiện chưa phản hồi được, bạn thử lại nhé.';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              _sessionId == null ? 'Cuộc trò chuyện mới' : 'Đang nối lịch sử',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Chat mới',
            onPressed: _isSending ? null : _newChat,
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              itemCount: _messages.length + (_isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isSending && index == _messages.length) {
                  return const _TypingBubble();
                }
                return _MessageBubble(
                  message: _messages[index],
                  onStartPractice: (topic) => _startPractice(topic: topic),
                  onStartWeakPractice: () => _startPractice(weakTopic: true),
                );
              },
            ),
          ),
          if (_practiceSessionId != null || _practiceBusy)
            _PracticePanel(
              state: _practiceState,
              question: _currentPracticeQuestion,
              selectedAnswer: _selectedPracticeAnswer,
              isBusy: _practiceBusy,
              onAnswer: _answerPractice,
              onNext: _nextPractice,
              onStop: _stopPractice,
            )
          else
            _PracticeStarter(
              difficulty: _practiceDifficulty,
              onDifficultyChanged: (value) {
                setState(() => _practiceDifficulty = value);
              },
              onStartWeakPractice: () => _startPractice(weakTopic: true),
            ),
          _Composer(
            controller: _controller,
            isSending: _isSending,
            onSend: _sendMessage,
            onPickImage: _showImageSourceSheet,
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final String? imagePath;
  final bool suggestPractice;
  final String? suggestedTopic;
  final List<String> weakTopics;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    this.imagePath,
    this.suggestPractice = false,
    this.suggestedTopic,
    this.weakTopics = const [],
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final ValueChanged<String?> onStartPractice;
  final VoidCallback onStartWeakPractice;

  const _MessageBubble({
    required this.message,
    required this.onStartPractice,
    required this.onStartWeakPractice,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = message.isUser
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final bubbleColor = message.isUser
        ? AppColors.primary
        : message.isError
        ? const Color(0xFFFFF1F2)
        : Colors.white;
    final textColor = message.isUser
        ? Colors.white
        : message.isError
        ? const Color(0xFFBE123C)
        : AppColors.textDark;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(message.isUser ? 18 : 4),
      bottomRight: Radius.circular(message.isUser ? 4 : 18),
    );

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: radius,
          border: message.isUser
              ? null
              : Border.all(
                  color: message.isError
                      ? const Color(0xFFFFCBD5)
                      : const Color(0xFFE5E7EB),
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(message.imagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 160,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.45),
            ),
            if (!message.isUser &&
                (message.suggestPractice || message.weakTopics.isNotEmpty))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (message.suggestPractice)
                      ActionChip(
                        avatar: const Icon(Icons.bolt_rounded, size: 18),
                        label: Text(
                          message.suggestedTopic == null
                              ? 'Luyện tập ngay'
                              : 'Luyện: ${message.suggestedTopic}',
                        ),
                        onPressed: () =>
                            onStartPractice(message.suggestedTopic),
                      ),
                    ...message.weakTopics.map(
                      (topic) => ActionChip(
                        avatar: const Icon(Icons.adjust_rounded, size: 18),
                        label: Text(topic),
                        onPressed: () => onStartPractice(topic),
                      ),
                    ),
                    if (message.weakTopics.isNotEmpty)
                      ActionChip(
                        avatar: const Icon(Icons.psychology_outlined, size: 18),
                        label: const Text('Luyện điểm yếu'),
                        onPressed: onStartWeakPractice,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _PracticeStarter extends StatelessWidget {
  final String difficulty;
  final ValueChanged<String> onDifficultyChanged;
  final VoidCallback onStartWeakPractice;

  const _PracticeStarter({
    required this.difficulty,
    required this.onDifficultyChanged,
    required this.onStartWeakPractice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'easy', label: Text('Dễ')),
                ButtonSegment(value: 'medium', label: Text('Vừa')),
                ButtonSegment(value: 'hard', label: Text('Khó')),
              ],
              selected: {difficulty},
              showSelectedIcon: false,
              onSelectionChanged: (values) => onDifficultyChanged(values.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            tooltip: 'Luyện điểm yếu',
            onPressed: onStartWeakPractice,
            icon: const Icon(Icons.psychology_outlined),
          ),
        ],
      ),
    );
  }
}

class _PracticePanel extends StatelessWidget {
  final AiPracticeResponse? state;
  final AiPracticeQuestion? question;
  final String? selectedAnswer;
  final bool isBusy;
  final ValueChanged<String> onAnswer;
  final VoidCallback onNext;
  final VoidCallback onStop;

  const _PracticePanel({
    required this.state,
    required this.question,
    required this.selectedAnswer,
    required this.isBusy,
    required this.onAnswer,
    required this.onNext,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final currentQuestion = question;
    final answered = state?.correct != null;

    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SizedBox(
        width: double.infinity,
        height: answered ? screenHeight * 0.56 : screenHeight * 0.38,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isBusy && currentQuestion == null
                  ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      key: ValueKey(state?.practiceSessionId ?? 'practice'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.bolt_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                currentQuestion?.topic ?? 'Luyện tập AI',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            Text(
                              '${state?.score ?? 0}/${state?.totalAnswered ?? 0}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'Dừng luyện tập',
                              onPressed: isBusy ? null : onStop,
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        if (currentQuestion != null) ...[
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Text(
                                      currentQuestion.question,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.4,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _PracticeOptions(
                                    question: currentQuestion,
                                    state: state,
                                    answered: answered,
                                    selectedAnswer: selectedAnswer,
                                    isBusy: isBusy,
                                    onAnswer: onAnswer,
                                  ),
                                  if (answered) ...[
                                    const SizedBox(height: 12),
                                    _PracticeResult(state: state!),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (answered) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: isBusy ? null : onStop,
                                  icon: const Icon(Icons.stop_circle_outlined),
                                  label: const Text('Dừng'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isBusy ? null : onNext,
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  label: const Text('Câu tiếp'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticeOptions extends StatelessWidget {
  final AiPracticeQuestion question;
  final AiPracticeResponse? state;
  final bool answered;
  final String? selectedAnswer;
  final bool isBusy;
  final ValueChanged<String> onAnswer;

  const _PracticeOptions({
    required this.question,
    required this.state,
    required this.answered,
    required this.selectedAnswer,
    required this.isBusy,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth >= 360
            ? (constraints.maxWidth - 8) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: question.options.entries.map((entry) {
            final isSelected = selectedAnswer == entry.key;
            final isCorrect =
                answered &&
                state?.correctAnswer?.toUpperCase() == entry.key.toUpperCase();
            final isWrong = answered && isSelected && !isCorrect;

            return SizedBox(
              width: itemWidth,
              child: ChoiceChip(
                label: SizedBox(
                  width: double.infinity,
                  child: Text(
                    '${entry.key}. ${entry.value}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                selected: isSelected || isCorrect,
                onSelected: answered || isBusy
                    ? null
                    : (_) => onAnswer(entry.key),
                selectedColor: isCorrect
                    ? const Color(0xFFD1FAE5)
                    : isWrong
                    ? const Color(0xFFFFE4E6)
                    : AppColors.primary.withValues(alpha: 0.14),
                labelStyle: TextStyle(
                  color: isCorrect
                      ? const Color(0xFF047857)
                      : isWrong
                      ? const Color(0xFFBE123C)
                      : AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _PracticeResult extends StatelessWidget {
  final AiPracticeResponse state;

  const _PracticeResult({required this.state});

  @override
  Widget build(BuildContext context) {
    final correct = state.correct == true;
    final color = correct ? const Color(0xFF047857) : const Color(0xFFBE123C);
    final bg = correct ? const Color(0xFFD1FAE5) : const Color(0xFFFFE4E6);
    final explanation = state.explanation?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct
                ? 'Chính xác!'
                : 'Chưa đúng. Đáp án là ${state.correctAnswer ?? ''}',
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
          if (state.explanation?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    explanation!,
                    style: const TextStyle(height: 1.4),
                  ),
                ),
              ),
            ),
          ],
          if (state.nextSuggestion?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              state.nextSuggestion!,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onPickImage;

  const _Composer({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              tooltip: 'Gửi ảnh',
              onPressed: isSending ? null : onPickImage,
              icon: const Icon(Icons.image_outlined),
              color: AppColors.primary,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Nhập câu hỏi Toán học...',
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              height: 48,
              child: ElevatedButton(
                onPressed: isSending ? null : onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Icon(Icons.send_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

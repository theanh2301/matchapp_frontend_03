import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../screens/ai/ai_chat_screen.dart';

class GlobalAiChatButton extends StatelessWidget {
  final int userId;
  final String chatContext;

  const GlobalAiChatButton({
    super.key,
    required this.userId,
    required this.chatContext,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Hỏi AI',
      heroTag: 'global_ai_chat_button_$chatContext',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AiChatScreen(userId: userId, context: chatContext),
          ),
        );
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      child: const Icon(Icons.smart_toy_outlined),
    );
  }
}

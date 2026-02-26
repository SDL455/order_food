import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Input bar for chat with text field and send button.
class ChatInputBar extends StatelessWidget {
  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.textController,
    required this.onChanged,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppTheme.primary,
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

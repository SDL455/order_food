import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/firebase_service.dart';
import '../controller/chat_controller.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';

/// Chat detail screen — real-time message list with input.
class ChatDetailScreen extends GetView<ChatController> {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return const Center(
                  child: Text(
                    'No messages yet. Say hello!',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (_, i) {
                  final msg = controller.messages[i];
                  final isMe = msg.fromUid == FirebaseService.uid;
                  final time =
                      '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}';
                  return ChatMessageBubble(
                    text: msg.text,
                    time: time,
                    isMe: isMe,
                  );
                },
              );
            }),
          ),
          ChatInputBar(
            textController: textCtrl,
            onChanged: (v) => controller.messageText.value = v,
            onSend: () {
              controller.sendMessage();
              textCtrl.clear();
            },
          ),
        ],
      ),
    );
  }
}

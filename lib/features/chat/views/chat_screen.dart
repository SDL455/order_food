import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/firebase_service.dart';
import '../controller/chat_controller.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';

/// Chat detail screen — real-time message list with input (text + image).
class ChatDetailScreen extends GetView<ChatController> {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Chat',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return const Center(
                  child: Text(
                    'ຍັງບໍ່ມີຂໍ້ຄວາມ. ສົ່ງສະບາຍດີ!',
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
                    imageUrl: msg.isImage ? msg.imageUrl : null,
                    time: time,
                    isMe: isMe,
                  );
                },
              );
            }),
          ),
          Obx(
            () => ChatInputBar(
              textController: textCtrl,
              onChanged: (v) => controller.messageText.value = v,
              onSend: () {
                controller.sendMessage();
                textCtrl.clear();
              },
              onImageGallery: () =>
                  controller.sendImageMessage(ImageSource.gallery),
              onImageCamera: () =>
                  controller.sendImageMessage(ImageSource.camera),
              isUploadingImage: controller.isUploadingImage.value,
            ),
          ),
        ],
      ),
    );
  }
}

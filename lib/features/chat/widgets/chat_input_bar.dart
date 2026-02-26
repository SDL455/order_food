import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Input bar for chat with text field, image button, and send button.
class ChatInputBar extends StatelessWidget {
  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final VoidCallback? onImageGallery;
  final VoidCallback? onImageCamera;
  final bool isUploadingImage;

  const ChatInputBar({
    super.key,
    required this.textController,
    required this.onChanged,
    required this.onSend,
    this.onImageGallery,
    this.onImageCamera,
    this.isUploadingImage = false,
  });

  void _showImageSourcePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppTheme.primary),
                ),
                title: const Text('ຮູບຈາກກາລະລິ'),
                onTap: () {
                  Navigator.pop(ctx);
                  onImageGallery?.call();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppTheme.primary),
                ),
                title: const Text('ຖ່າຍຮູບ'),
                onTap: () {
                  Navigator.pop(ctx);
                  onImageCamera?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSendImage = (onImageGallery != null || onImageCamera != null);

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
            if (canSendImage)
              IconButton(
                icon: isUploadingImage
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      )
                    : const Icon(
                        Icons.add_photo_alternate_rounded,
                        color: AppTheme.primary,
                        size: 26,
                      ),
                onPressed: isUploadingImage
                    ? null
                    : () => _showImageSourcePicker(context),
              ),
            Expanded(
              child: TextField(
                controller: textController,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: 'ພິມຂໍ້ຄວາມ...',
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
                  Icons.send_rounded,
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

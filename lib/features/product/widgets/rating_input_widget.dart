import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';

/// Widget for rating input (stars + comment) on product detail screen.
class RatingInputWidget extends StatelessWidget {
  final RxDouble userStars;
  final RxString userComment;
  final VoidCallback onSubmit;

  const RatingInputWidget({
    super.key,
    required this.userStars,
    required this.userComment,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Write a Review',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => userStars.value = (i + 1).toDouble(),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      i < userStars.value.round() ? Icons.star : Icons.star_border,
                      size: 32,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => userComment.value = v,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Your comment...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

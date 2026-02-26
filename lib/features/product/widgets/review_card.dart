import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/rating_model.dart';
import 'star_rating_display.dart';

/// Card displaying a single product review.
class ReviewCard extends StatelessWidget {
  final RatingModel rating;

  const ReviewCard({super.key, required this.rating});

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StarRatingDisplay(rating: rating.stars, size: 16),
              const Spacer(),
              Text(
                _formatDate(rating.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          if (rating.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              rating.comment,
              style: const TextStyle(height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

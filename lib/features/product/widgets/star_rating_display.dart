import 'package:flutter/material.dart';

/// Displays star rating (filled/outline).
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        starCount,
        (i) => Icon(
          i < rating.round() ? Icons.star : Icons.star_border,
          size: size,
          color: Colors.amber,
        ),
      ),
    );
  }
}

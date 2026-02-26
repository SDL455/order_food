import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/cart_item_model.dart';

/// Card displaying a single cart item with image, name, price and quantity controls.
class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final ValueChanged<int> onQtyChanged;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: item.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.fastfood,
                      color: AppTheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${(item.price * item.qty).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () => onQtyChanged(item.qty - 1),
                  visualDensity: VisualDensity.compact,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${item.qty}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => onQtyChanged(item.qty + 1),
                  visualDensity: VisualDensity.compact,
                  color: AppTheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

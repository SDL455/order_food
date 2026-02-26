import 'package:flutter/material.dart';

/// Bottom bar with Add to Cart button on product detail screen.
class ProductBottomBar extends StatelessWidget {
  final String productName;
  final double price;
  final VoidCallback onAddToCart;

  const ProductBottomBar({
    super.key,
    required this.productName,
    required this.price,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: onAddToCart,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add to Cart'),
          ),
        ),
      ),
    );
  }
}

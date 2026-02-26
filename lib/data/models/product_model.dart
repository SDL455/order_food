import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore product document model (subcollection of a shop).
class ProductModel {
  final String id;
  final String shopId;
  final String name;
  final double price;
  final String imageUrl;
  final String desc;
  final String category;
  final bool isActive;
  final double avgRating;
  final int ratingCount;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.price,
    this.imageUrl = '',
    this.desc = '',
    this.category = '',
    this.isActive = true,
    this.avgRating = 0,
    this.ratingCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ProductModel.fromMap(
    Map<String, dynamic> map,
    String id,
    String shopId,
  ) {
    return ProductModel(
      id: id,
      shopId: shopId,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      desc: map['desc'] ?? '',
      category: map['category'] ?? '',
      isActive: map['isActive'] ?? true,
      avgRating: (map['avgRating'] ?? 0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'desc': desc,
    'category': category,
    'isActive': isActive,
    'avgRating': avgRating,
    'ratingCount': ratingCount,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

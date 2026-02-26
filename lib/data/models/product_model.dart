import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore product document model (subcollection of a shop).
class ProductModel {
  final String id;
  final String shopId;
  final String name;
  final double price;
  final String imageUrl;
  final List<String> imageUrls;
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
    List<String>? imageUrls,
    this.desc = '',
    this.category = '',
    this.isActive = true,
    this.avgRating = 0,
    this.ratingCount = 0,
    DateTime? createdAt,
  })  : imageUrls = imageUrls ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// First image URL for display (backward compatible with single imageUrl).
  String get displayImageUrl {
    if (imageUrls.isNotEmpty) return imageUrls.first;
    return imageUrl;
  }

  factory ProductModel.fromMap(
    Map<String, dynamic> map,
    String id,
    String shopId,
  ) {
    final rawUrls = map['imageUrls'];
    List<String> urls = [];
    if (rawUrls is List) {
      urls = rawUrls.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    final singleUrl = map['imageUrl'] ?? '';
    if (urls.isEmpty && singleUrl.toString().isNotEmpty) {
      urls = [singleUrl.toString()];
    }
    return ProductModel(
      id: id,
      shopId: shopId,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: urls.isNotEmpty ? urls.first : singleUrl.toString(),
      imageUrls: urls,
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
    'imageUrl': displayImageUrl,
    'imageUrls': imageUrls,
    'desc': desc,
    'category': category,
    'isActive': isActive,
    'avgRating': avgRating,
    'ratingCount': ratingCount,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

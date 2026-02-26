import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore shop document model.
class ShopModel {
  final String id;
  final String ownerUid;
  final String name;
  final String coverUrl;
  final bool isOpen;
  final double lat;
  final double lng;
  final DateTime createdAt;

  ShopModel({
    required this.id,
    required this.ownerUid,
    required this.name,
    this.coverUrl = '',
    this.isOpen = true,
    this.lat = 0,
    this.lng = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ShopModel.fromMap(Map<String, dynamic> map, String id) {
    final loc = map['location'] as Map<String, dynamic>? ?? {};
    return ShopModel(
      id: id,
      ownerUid: map['ownerUid'] ?? '',
      name: map['name'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      isOpen: map['isOpen'] ?? true,
      lat: (loc['lat'] ?? 0).toDouble(),
      lng: (loc['lng'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'ownerUid': ownerUid,
    'name': name,
    'coverUrl': coverUrl,
    'isOpen': isOpen,
    'location': {'lat': lat, 'lng': lng},
    'createdAt': FieldValue.serverTimestamp(),
  };
}

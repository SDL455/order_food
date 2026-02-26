import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore user document model.
class UserModel {
  final String uid;
  final String role; // 'customer' | 'admin'
  final String displayName;
  final String phone;
  final String photoUrl;
  final List<String> fcmTokens;
  final String? defaultAddressId;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.role,
    required this.displayName,
    this.phone = '',
    this.photoUrl = '',
    this.fcmTokens = const [],
    this.defaultAddressId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      role: map['role'] ?? 'customer',
      displayName: map['displayName'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      fcmTokens: List<String>.from(map['fcmTokens'] ?? []),
      defaultAddressId: map['defaultAddressId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'role': role,
    'displayName': displayName,
    'phone': phone,
    'photoUrl': photoUrl,
    'fcmTokens': fcmTokens,
    'defaultAddressId': defaultAddressId,
    'createdAt': FieldValue.serverTimestamp(),
  };

  UserModel copyWith({
    String? displayName,
    String? phone,
    String? photoUrl,
    List<String>? fcmTokens,
    String? defaultAddressId,
  }) {
    return UserModel(
      uid: uid,
      role: role,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      defaultAddressId: defaultAddressId ?? this.defaultAddressId,
      createdAt: createdAt,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore message document model (subcollection of a chat).
class MessageModel {
  final String id;
  final String fromUid;
  final String toUid;
  final String text;
  final String type; // 'text', 'image', etc.
  final String imageUrl; // For type == 'image'
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.text,
    this.type = 'text',
    this.imageUrl = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      fromUid: map['fromUid'] ?? '',
      toUid: map['toUid'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] ?? 'text',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'fromUid': fromUid,
        'toUid': toUid,
        'text': text,
        'type': type,
        if (imageUrl.isNotEmpty) 'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

  bool get isImage => type == 'image' && imageUrl.isNotEmpty;
}

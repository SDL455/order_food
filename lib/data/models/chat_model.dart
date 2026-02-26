import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore chat document model.
class ChatModel {
  final String id;
  final String shopId;
  final String customerUid;
  final String lastMessage;
  final DateTime lastAt;

  ChatModel({
    required this.id,
    required this.shopId,
    required this.customerUid,
    this.lastMessage = '',
    DateTime? lastAt,
  }) : lastAt = lastAt ?? DateTime.now();

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      shopId: map['shopId'] ?? '',
      customerUid: map['customerUid'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastAt: (map['lastAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'shopId': shopId,
    'customerUid': customerUid,
    'lastMessage': lastMessage,
    'lastAt': FieldValue.serverTimestamp(),
  };
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

/// Handles Firestore CRUD for chats and messages.
class ChatRepository {
  final _chats = FirebaseService.firestore.collection(AppConstants.chatsCol);

  /// Get a chat by ID.
  Future<ChatModel?> getChat(String chatId) async {
    final doc = await _chats.doc(chatId).get();
    if (!doc.exists) return null;
    return ChatModel.fromMap(doc.data()!, doc.id);
  }

  /// Get or create a chat between a customer and a shop.
  Future<ChatModel> getOrCreateChat({
    required String shopId,
    required String customerUid,
  }) async {
    // Try to find an existing chat
    final snap = await _chats
        .where('shopId', isEqualTo: shopId)
        .where('customerUid', isEqualTo: customerUid)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      final doc = snap.docs.first;
      return ChatModel.fromMap(doc.data(), doc.id);
    }

    // Create new chat
    final chat = ChatModel(id: '', shopId: shopId, customerUid: customerUid);
    final doc = await _chats.add(chat.toMap());
    return ChatModel(id: doc.id, shopId: shopId, customerUid: customerUid);
  }

  /// Stream chats for a customer.
  Stream<List<ChatModel>> streamCustomerChats(String customerUid) {
    return _chats
        .where('customerUid', isEqualTo: customerUid)
        .orderBy('lastAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => ChatModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  /// Stream chats for a shop (admin view).
  Stream<List<ChatModel>> streamShopChats(String shopId) {
    return _chats
        .where('shopId', isEqualTo: shopId)
        .orderBy('lastAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => ChatModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  /// Stream messages in a chat.
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection(AppConstants.messagesCol)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => MessageModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  /// Send a message in a chat.
  Future<void> sendMessage({
    required String chatId,
    required MessageModel message,
  }) async {
    await _chats
        .doc(chatId)
        .collection(AppConstants.messagesCol)
        .add(message.toMap());

    // Update the chat's last message
    final lastMsg = message.isImage ? 'ຮູບພາບ' : message.text;
    await _chats.doc(chatId).update({
      'lastMessage': lastMsg,
      'lastAt': FieldValue.serverTimestamp(),
    });
  }
}

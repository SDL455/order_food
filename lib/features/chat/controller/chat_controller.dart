import 'package:get/get.dart';

import '../../../core/services/firebase_service.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/shop_repository.dart';

/// Chat controller — handles both chat list and individual chat.
class ChatController extends GetxController {
  final ChatRepository _chatRepo = ChatRepository();
  final ShopRepository _shopRepo = ShopRepository();

  final chats = <ChatModel>[].obs;
  final messages = <MessageModel>[].obs;
  final messageText = ''.obs;
  final isLoading = true.obs;

  /// Currently selected chat.
  final Rxn<ChatModel> activeChat = Rxn<ChatModel>();

  /// Whether current user is admin (determines which chats to show).
  bool get isAdmin => Get.arguments is String; // admin passes shopId

  String get shopIdFromArgs => Get.arguments as String? ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadChats();
  }

  void _loadChats() {
    isLoading.value = true;
    if (isAdmin) {
      _chatRepo.streamShopChats(shopIdFromArgs).listen((list) {
        chats.value = list;
        isLoading.value = false;
      });
    } else {
      _chatRepo.streamCustomerChats(FirebaseService.uid).listen((list) {
        chats.value = list;
        isLoading.value = false;
      });
    }
  }

  /// Open a chat and start listening to messages.
  void openChat(ChatModel chat) {
    activeChat.value = chat;
    _chatRepo.streamMessages(chat.id).listen((list) {
      messages.value = list;
    });
  }

  /// Start or open a chat with a specific shop (customer action).
  Future<void> startChatWithShop(String shopId) async {
    final chat = await _chatRepo.getOrCreateChat(
      shopId: shopId,
      customerUid: FirebaseService.uid,
    );
    openChat(chat);
  }

  /// Send a message in the active chat.
  Future<void> sendMessage() async {
    if (messageText.value.trim().isEmpty || activeChat.value == null) return;

    // Determine toUid
    final chat = activeChat.value!;
    String toUid;
    if (FirebaseService.uid == chat.customerUid) {
      // Customer sending to shop admin — need to look up admin uid
      final shop = await _shopRepo.getShop(chat.shopId);
      toUid = shop?.ownerUid ?? '';
    } else {
      toUid = chat.customerUid;
    }

    final message = MessageModel(
      id: '',
      fromUid: FirebaseService.uid,
      toUid: toUid,
      text: messageText.value.trim(),
    );

    await _chatRepo.sendMessage(chatId: chat.id, message: message);
    messageText.value = '';
  }
}

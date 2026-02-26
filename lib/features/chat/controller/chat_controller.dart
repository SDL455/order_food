import 'package:get/get.dart';

import '../../../core/services/firebase_service.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/shop_model.dart';
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

  /// Shops for customer to search and start chat with admin.
  final shops = <ShopModel>[].obs;
  final isShopsLoading = false.obs;
  final searchQuery = ''.obs;

  /// Currently selected chat.
  final Rxn<ChatModel> activeChat = Rxn<ChatModel>();

  /// Whether current user is admin (determines which chats to show).
  bool get isAdmin => Get.arguments is String; // admin passes shopId

  String get shopIdFromArgs => Get.arguments as String? ?? '';

  /// Shops filtered by search (for customer).
  List<ShopModel> get filteredShops {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return shops;
    return shops.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadChats();
    if (!isAdmin) _loadShops();
  }

  Future<void> _loadShops() async {
    isShopsLoading.value = true;
    try {
      shops.value = await _shopRepo.getShops();
    } finally {
      isShopsLoading.value = false;
    }
  }

  void _loadChats() {
    isLoading.value = true;

    // Customer ຕ້ອງເຂົ້າສູ່ລະບົບກ່ອນ
    if (!isAdmin && FirebaseService.uid.isEmpty) {
      isLoading.value = false;
      chats.clear();
      return;
    }

    // Admin ຕ້ອງມີ shopId
    if (isAdmin && shopIdFromArgs.isEmpty) {
      isLoading.value = false;
      chats.clear();
      return;
    }

    final stream = isAdmin
        ? _chatRepo.streamShopChats(shopIdFromArgs)
        : _chatRepo.streamCustomerChats(FirebaseService.uid);

    stream.listen(
      (list) {
        chats.value = list;
        isLoading.value = false;
      },
      onError: (e, st) {
        isLoading.value = false;
        chats.clear();
        Get.snackbar(
          'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້',
          'ກະລຸນາກວດສອບການເຊື່ອມຕໍ່ ຫຼື ລອງໃໝ່ພາຍຫຼັງ',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
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

import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/storage_service.dart';
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

  /// Uploading image state.
  final isUploadingImage = false.obs;

  /// Currently selected chat.
  final Rxn<ChatModel> activeChat = Rxn<ChatModel>();

  /// Whether current user is admin (determines which chats to show).
  bool get isAdmin => Get.arguments is String; // admin passes shopId

  String get shopIdFromArgs => Get.arguments as String? ?? '';

  /// ChatId from notification tap (arguments: {'chatId': '...'}).
  String? get _chatIdFromArgs {
    final args = Get.arguments;
    if (args is Map && args['chatId'] != null) {
      return args['chatId'] as String?;
    }
    return null;
  }

  /// Shops filtered by search (for customer).
  List<ShopModel> get filteredShops {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return shops;
    return shops.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    final chatId = _chatIdFromArgs;
    if (chatId != null && chatId.isNotEmpty) {
      _openChatById(chatId);
    } else {
      _loadChats();
      if (!isAdmin) _loadShops();
    }
  }

  /// Open a chat by ID (e.g. from notification tap).
  Future<void> _openChatById(String chatId) async {
    isLoading.value = true;
    try {
      final chat = await _chatRepo.getChat(chatId);
      if (chat != null) {
        openChat(chat);
      } else {
        Get.snackbar(
          'ບໍ່ພົບການສົນທະນາ',
          'ການສົນທະນາອາດຈະຖືກລຶບແລ້ວ',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      }
    } finally {
      isLoading.value = false;
    }
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

  /// Send an image message. Picks image from gallery/camera and uploads.
  Future<void> sendImageMessage(ImageSource source) async {
    if (activeChat.value == null) return;

    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (xFile == null) return;

    final chat = activeChat.value!;
    String toUid;
    if (FirebaseService.uid == chat.customerUid) {
      final shop = await _shopRepo.getShop(chat.shopId);
      toUid = shop?.ownerUid ?? '';
    } else {
      toUid = chat.customerUid;
    }

    isUploadingImage.value = true;
    try {
      final file = File(xFile.path);
      final url = await StorageService.instance.uploadImage(
        file,
        AppConstants.chatImages,
      );

      final message = MessageModel(
        id: '',
        fromUid: FirebaseService.uid,
        toUid: toUid,
        text: '',
        type: 'image',
        imageUrl: url,
      );

      await _chatRepo.sendMessage(chatId: chat.id, message: message);
    } catch (e) {
      Get.snackbar(
        'ບໍ່ສາມາດສົ່ງຮູບໄດ້',
        'ກະລຸນາລອງໃໝ່ພາຍຫຼັງ',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }
}

/// Local cart item — persisted with GetStorage.
class CartItemModel {
  final String productId;
  final String shopId;
  final String name;
  final double price;
  int qty;
  final String imageUrl;

  CartItemModel({
    required this.productId,
    required this.shopId,
    required this.name,
    required this.price,
    this.qty = 1,
    this.imageUrl = '',
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'] ?? '',
      shopId: map['shopId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      qty: map['qty'] ?? 1,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'shopId': shopId,
    'name': name,
    'price': price,
    'qty': qty,
    'imageUrl': imageUrl,
  };
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// A single item inside an order.
class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int qty;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.qty,
    this.imageUrl = '',
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      qty: map['qty'] ?? 1,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'name': name,
    'price': price,
    'qty': qty,
    'imageUrl': imageUrl,
  };
}

/// Address info attached to an order.
class OrderAddress {
  final String text;
  final double? lat;
  final double? lng;

  OrderAddress({required this.text, this.lat, this.lng});

  factory OrderAddress.fromMap(Map<String, dynamic> map) {
    return OrderAddress(
      text: map['text'] ?? '',
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {'text': text, 'lat': lat, 'lng': lng};
}

/// Firestore order document model.
class OrderModel {
  final String id;
  final String shopId;
  final String customerUid;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final OrderAddress address;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.shopId,
    required this.customerUid,
    required this.items,
    required this.subtotal,
    this.deliveryFee = 0,
    required this.total,
    this.status = 'pending',
    required this.address,
    this.note = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      shopId: map['shopId'] ?? '',
      customerUid: map['customerUid'] ?? '',
      items:
          (map['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      address: OrderAddress.fromMap(
        map['address'] as Map<String, dynamic>? ?? {'text': ''},
      ),
      note: map['note'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'shopId': shopId,
    'customerUid': customerUid,
    'items': items.map((e) => e.toMap()).toList(),
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'total': total,
    'status': status,
    'address': address.toMap(),
    'note': note,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

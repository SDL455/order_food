/// Firestore category document model (subcollection of a shop).
class CategoryModel {
  final String id;
  final String shopId;
  final String name;
  final int order;

  CategoryModel({
    required this.id,
    required this.shopId,
    required this.name,
    this.order = 0,
  });

  factory CategoryModel.fromMap(
    Map<String, dynamic> map,
    String id,
    String shopId,
  ) {
    return CategoryModel(
      id: id,
      shopId: shopId,
      name: map['name'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'order': order,
      };
}

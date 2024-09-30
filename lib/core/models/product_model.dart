import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final double price;
  final List<String> imageUrls;
  final String category;
  final String subCategory;
  final String phoneNumber;
  final String description;
  final String sellerId;
  final DateTime createdAt;
  final int stock;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrls,
    required this.category,
    required this.subCategory,
    required this.phoneNumber,
    required this.description,
    required this.sellerId,
    required this.createdAt,
    required this.stock,
  });

  // Create a Product from a Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      category: data['category'] ?? '',
      subCategory: data['subCategory'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      description: data['description'] ?? '',
      sellerId: data['sellerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      stock: data['stock'] ?? 0,
    );
  }

  // Convert a Product to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'price': price,
      'imageUrls': imageUrls,
      'category': category,
      'subCategory': subCategory,
      'phoneNumber': phoneNumber,
      'description': description,
      'sellerId': sellerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'stock': stock,
    };
  }

  // Create a copy of the Product with some fields changed
  Product copyWith({
    String? title,
    double? price,
    List<String>? imageUrls,
    String? category,
    String? subCategory,
    String? phoneNumber,
    String? description,
    String? sellerId,
    DateTime? createdAt,
    int? stock,
  }) {
    return Product(
      id: id,
      title: title ?? this.title,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
      sellerId: sellerId ?? this.sellerId,
      createdAt: createdAt ?? this.createdAt,
      stock: stock ?? this.stock,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, title: $title, price: $price, category: $category, subCategory: $subCategory)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.title == title &&
        other.price == price &&
        other.category == category &&
        other.subCategory == subCategory &&
        other.phoneNumber == phoneNumber &&
        other.description == description &&
        other.sellerId == sellerId &&
        other.createdAt == createdAt &&
        other.stock == stock;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        price.hashCode ^
        category.hashCode ^
        subCategory.hashCode ^
        phoneNumber.hashCode ^
        description.hashCode ^
        sellerId.hashCode ^
        createdAt.hashCode ^
        stock.hashCode;
  }
}

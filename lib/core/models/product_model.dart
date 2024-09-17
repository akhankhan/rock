import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final double price;
  final String description;
  final String size;
  final String color;
  final String category;
  final String subCategory;
  final String imageUrl;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.size,
    required this.color,
    required this.category,
    required this.subCategory,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      size: data['size'] ?? '',
      color: data['color'] ?? '',
      category: data['category'] ?? '',
      subCategory: data['subCategory'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

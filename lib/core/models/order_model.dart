import 'item_model.dart';

class OrderModel {
  final String id;
  final double amount;
  final List<CartItem> items;
  final DateTime date;
  final String status;

  OrderModel({
    required this.id,
    required this.amount,
    required this.items,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'items': items.map((item) => item.toMap()).toList(),
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      amount: map['amount'],
      items:
          (map['items'] as List).map((item) => CartItem.fromMap(item)).toList(),
      date: DateTime.parse(map['date']),
      status: map['status'],
    );
  }
}

import 'dart:convert';

import 'package:fine_rock/core/models/item_model.dart';
import 'package:fine_rock/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/order_model.dart';
import '../../core/services/stripe_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  bool _isProcessing = false;

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  bool get isProcessing => _isProcessing;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    await loadCartFromPrefs();
    _isInitialized = true;
  }

  Future<void> loadCartFromPrefs() async {
    final cartData = _prefs.getString('cart');
    if (cartData != null) {
      final decodedData = json.decode(cartData) as Map<String, dynamic>;
      _items = {};
      decodedData.forEach((key, value) {
        _items[key] = CartItem.fromMap(value as Map<String, dynamic>);
      });
      notifyListeners();
    }
  }

  Future<void> saveCartToPrefs() async {
    final cartData = {};
    _items.forEach((key, value) {
      cartData[key] = value.toMap();
    });
    await _prefs.setString('cart', json.encode(cartData));
  }

  Future<void> addItem({
    required String productId,
    required String title,
    required double price,
    required String imageUrl,
  }) async {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity += 1;
    } else {
      _items[productId] = CartItem(
        id: productId,
        title: title,
        price: price,
        imageUrl: imageUrl,
      );
    }
    notifyListeners();
    await saveCartToPrefs();
  }

  Future<void> removeItem(String productId) async {
    _items.remove(productId);
    notifyListeners();
    await saveCartToPrefs();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (_items.containsKey(productId)) {
      if (quantity > 0) {
        _items[productId]!.quantity = quantity;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
      await saveCartToPrefs();
    }
  }

  Future<void> clear() async {
    _items = {};
    notifyListeners();
    await saveCartToPrefs();
  }

  Future<void> processPayment() async {
    try {
      _isProcessing = true;
      notifyListeners();

      final amount = (totalAmount * 100).toInt().toString();
      await StripeService.makePayment(
        amount: amount,
        currency: 'USD',
      );

      await _saveOrder();

      await clear();
    } catch (e) {
      AppLogger.log('Payment failed: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> _saveOrder() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final orderId = FirebaseFirestore.instance.collection('orders').doc().id;

    final order = OrderModel(
      id: orderId,
      amount: totalAmount,
      items: _items.values.toList(),
      date: DateTime.now(),
      status: 'Completed',
    );

    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
      ...order.toMap(),
      'userId': userId,
    });
  }
}

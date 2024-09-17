import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fine_rock/core/utils/image_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/product_model.dart';
import 'package:path/path.dart' as path;

class AddProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool? isLoading = false;

  Map<String, List<String>> categorySubcategoryMap = {
    "Facted Grade": ["Precious Stone", "Semi Precious Stone"],
    "Rough Item": ["Precious Stone", "Semi Precious Stone"],
    "Matrix": ["Precious Stone", "Semi Precious Stone"]
  };

  String? selectedCategory;
  String? selectedSubCategory;

  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController colorController = TextEditingController();

  File? image;

  AddProductProvider() {
    selectedCategory = categorySubcategoryMap.keys.first;
    selectedSubCategory = categorySubcategoryMap[selectedCategory]!.first;
  }

  List<String> get categories => categorySubcategoryMap.keys.toList();

  List<String> get subcategories =>
      categorySubcategoryMap[selectedCategory] ?? [];

  Stream<List<Product>> getProductsStream() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  void setCategory(String? value) {
    selectedCategory = value;
    selectedSubCategory = categorySubcategoryMap[value]!.first;
    notifyListeners();
  }

  void setSubCategory(String? value) {
    selectedSubCategory = value;
    notifyListeners();
  }

  void getImageGallery() async {
    image = await ImagePickerUtil.pickImageFromGallery();
    notifyListeners();
  }

  Future<void> addProduct() async {
    isLoading = true;
    notifyListeners();
    if (image == null) {
      print('Error: No image selected');
      return;
    }

    try {
      // Get the current user
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Check if the file exists
      if (!await image!.exists()) {
        throw Exception('The selected image file does not exist');
      }

      // Generate a unique ID for the product
      String productId = _firestore.collection('products').doc().id;

      // Upload image
      String fileName = path.basename(image!.path);
      Reference ref = _storage.ref().child('product_images/$fileName');
      await ref.putFile(image!);
      String imageUrl = await ref.getDownloadURL();

      // Add product to Firestore
      await _firestore.collection('products').doc(productId).set({
        'id': productId,
        'userId': currentUser.uid,
        'title': titleController.text,
        'price': double.parse(priceController.text),
        'description': descController.text,
        'size': sizeController.text,
        'color': colorController.text,
        'category': selectedCategory,
        'subCategory': selectedSubCategory,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      clearForm();
      notifyListeners();
    } catch (e) {
      print('Error adding product: $e');
      // You might want to show an error message to the user here
      rethrow; // Rethrow the error so it can be caught and handled in the UI
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearForm() {
    titleController.clear();
    priceController.clear();
    descController.clear();
    sizeController.clear();
    colorController.clear();
    image = null;
    selectedCategory = categories.first;
    selectedSubCategory = subcategories.first;
  }
}

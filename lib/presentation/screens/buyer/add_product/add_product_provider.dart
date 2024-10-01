import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fine_rock/presentation/screens/auth/auth_controller.dart';
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
  final AuthController _authController;

  bool isLoading = false;

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

  List<File> images = [];
  static const int maxImages = 6;

  String get userPhoneNumber => _authController.userModel?.phoneNumber ?? '';

  AddProductProvider(this._authController) {
    selectedCategory = categorySubcategoryMap.keys.first;
    selectedSubCategory = categorySubcategoryMap[selectedCategory]!.first;
    log("User phone number: ${_authController.userModel!.phoneNumber}");
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

  Future<void> addImage() async {
    if (images.length >= maxImages) {
      // Show an error or notification that max images reached
      return;
    }
    File? image = await ImagePickerUtil.pickImageFromGallery();
    if (image != null) {
      images.add(image);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> addProduct() async {
    isLoading = true;
    notifyListeners();

    if (!_validateInputs()) {
      isLoading = false;
      notifyListeners();
      throw Exception('Please fill all required fields');
    }

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      String productId = _firestore.collection('products').doc().id;
      List<String> imageUrls = [];

      // Upload all images
      for (var image in images) {
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
        Reference ref = _storage.ref().child('product_images/$fileName');
        UploadTask uploadTask = ref.putFile(image);

        await uploadTask.whenComplete(() async {
          String imageUrl = await ref.getDownloadURL();
          imageUrls.add(imageUrl);
        });
      }

      // Add product to Firestore
      await _firestore.collection('products').doc(productId).set({
        'id': productId,
        'userId': _authController.userModel!.id,
        'title': titleController.text,
        'price': double.parse(priceController.text),
        'description': descController.text,
        'size': sizeController.text,
        'color': colorController.text,
        'category': selectedCategory,
        'subCategory': selectedSubCategory,
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'phoneNumber': _authController.userModel!.phoneNumber,
      });

      log('Product added successfully');
      clearForm();
    } catch (e) {
      log('Error adding product: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _validateInputs() {
    if (titleController.text.isEmpty ||
        priceController.text.isEmpty ||
        descController.text.isEmpty ||
        sizeController.text.isEmpty ||
        colorController.text.isEmpty ||
        selectedCategory == null ||
        selectedSubCategory == null ||
        images.isEmpty) {
      return false;
    }
    return true;
  }

  void clearForm() {
    titleController.clear();
    priceController.clear();
    descController.clear();
    sizeController.clear();
    colorController.clear();
    images.clear();
    selectedCategory = categories.first;
    selectedSubCategory = subcategories.first;
  }
}

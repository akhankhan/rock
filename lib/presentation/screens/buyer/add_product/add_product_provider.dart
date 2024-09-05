import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fine_rock/core/utils/image_picker.dart';
import 'package:flutter/material.dart';

class AddProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Map<String, List<String>> categorySubcategoryMap = {
    "Facted Grade": ["Precious Stone", "Semi Precious Stone"],
    "Rough Item": ["Raw Stone", "Uncut Gem"],
    "Matrix": ["Mineral Matrix", "Gemstone Matrix"]
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
    if (image == null) return;

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('product_images/$fileName');
      await ref.putFile(image!);
      String imageUrl = await ref.getDownloadURL();

      await _firestore.collection('products').add({
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

      _clearForm();
      notifyListeners();
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  void _clearForm() {
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

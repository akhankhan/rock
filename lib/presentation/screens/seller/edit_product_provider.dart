import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProductProvider extends ChangeNotifier {
  final String productId;
  final Map<String, dynamic> initialProductData;

  EditProductProvider(
      {required this.productId, required this.initialProductData}) {
    _initializeControllers();
  }

  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController descController;
  late TextEditingController sizeController;
  late TextEditingController colorController;
  late TextEditingController phoneNumberController;

  String completePhoneNumber = '';

  List<String> currentImageUrls = [];
  List<File> newImages = [];
  final picker = ImagePicker();
  bool isLoading = false;
  bool updateSuccess = false;

  void _initializeControllers() {
    titleController =
        TextEditingController(text: initialProductData['title'] ?? '');
    priceController = TextEditingController(
        text: initialProductData['price']?.toString() ?? '');
    descController =
        TextEditingController(text: initialProductData['description'] ?? '');
    sizeController =
        TextEditingController(text: initialProductData['size'] ?? '');
    colorController =
        TextEditingController(text: initialProductData['color'] ?? '');
    currentImageUrls = List<String>.from(initialProductData['imageUrls'] ?? []);
    completePhoneNumber = initialProductData['phoneNumber'] ?? '';
    phoneNumberController =
        TextEditingController(text: _extractPhoneNumber(completePhoneNumber));
  }

  String _extractPhoneNumber(String completeNumber) {
    return completeNumber.replaceFirst(RegExp(r'^\+\d+\s'), '');
  }

  void setPhoneNumber(String phoneNum) {
    completePhoneNumber = phoneNum;
    notifyListeners();
  }

  Future<void> addImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      newImages.add(File(pickedFile.path));
      notifyListeners();
    }
  }

  void removeCurrentImage(int index) {
    currentImageUrls.removeAt(index);
    notifyListeners();
  }

  void removeNewImage(int index) {
    newImages.removeAt(index);
    notifyListeners();
  }

  Future<void> updateProduct() async {
    isLoading = true;
    updateSuccess = false;
    notifyListeners();

    try {
      List<String> updatedImageUrls = [...currentImageUrls];

      // Upload new images
      for (File image in newImages) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref =
            FirebaseStorage.instance.ref().child('product_images/$fileName');
        await ref.putFile(image);
        String imageUrl = await ref.getDownloadURL();
        updatedImageUrls.add(imageUrl);
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
        'title': titleController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'description': descController.text,
        'size': sizeController.text,
        'color': colorController.text,
        'imageUrls': updatedImageUrls,
        'updatedAt': FieldValue.serverTimestamp(),
        'phoneNumber': completePhoneNumber,
      });

      updateSuccess = true;
    } catch (e) {
      updateSuccess = false;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descController.dispose();
    sizeController.dispose();
    colorController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }
}

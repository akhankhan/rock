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

  File? _image;
  final picker = ImagePicker();
  String? currentImageUrl;
  bool? _isLoading = false;
  bool _updateSuccess = false;

  File? get image => _image;
  bool get updateSuccess => _updateSuccess;
  bool? get isLoading => _isLoading;

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
    currentImageUrl = initialProductData['imageUrl'];
    completePhoneNumber = initialProductData['phoneNumber'] ?? '';
    phoneNumberController =
        TextEditingController(text: _extractPhoneNumber(completePhoneNumber));
  }

  String _extractPhoneNumber(String completeNumber) {
    // Remove the country code from the complete number
    // This is a simple implementation and might need to be adjusted based on your specific format
    return completeNumber.replaceFirst(RegExp(r'^\+\d+\s'), '');
  }

  void setPhoneNumber(String phoneNum) {
    completePhoneNumber = phoneNum;
    notifyListeners();
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> updateProduct() async {
    _isLoading = true;
    _updateSuccess = false;
    notifyListeners();

    try {
      String imageUrl = currentImageUrl ?? '';

      if (_image != null) {
        // Upload new image
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref =
            FirebaseStorage.instance.ref().child('product_images/$fileName');
        await ref.putFile(_image!);
        imageUrl = await ref.getDownloadURL();
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
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
        'phoneNumber': completePhoneNumber,
      });

      _updateSuccess = true;
    } catch (e) {
      _updateSuccess = false;
      rethrow;
    } finally {
      _isLoading = false;
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
    super.dispose();
  }
}

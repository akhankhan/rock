import 'dart:io';

import 'package:fine_rock/core/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/auth/auth_controller.dart';

class EditProfileProvider with ChangeNotifier {
  final AuthController authController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late bool isLoading;
  File? image;
  final ImagePicker _picker = ImagePicker();

  EditProfileProvider({required this.authController}) {
    nameController =
        TextEditingController(text: authController.userModel?.fullName);
    phoneController =
        TextEditingController(text: authController.userModel?.phoneNumber);
    isLoading = false;
  }

  Future<void> getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final UserModel? user = authController.userModel;

    if (user != null) {
      String? imageUrl;

      // Update profile picture
      if (image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_profile_images')
            .child('${user.id}.jpg');
        await ref.putFile(image!);
        imageUrl = await ref.getDownloadURL();
      }

      // Prepare data to update
      Map<String, dynamic> updateData = {
        'fullName': nameController.text,
        'phoneNumber': phoneController.text,
      };

      if (imageUrl != null) {
        updateData['profileImageUrl'] = imageUrl;
      }

      // Update user data
      await authController.updateUserData(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context);
    }
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}

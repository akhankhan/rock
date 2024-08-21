import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/auth/auth_controller.dart';

class EditProfileProvider with ChangeNotifier {
  final AuthController authController;
  late TextEditingController nameController;
  late bool isLoading;
  File? image;
  final ImagePicker _picker = ImagePicker();

  EditProfileProvider({required this.authController}) {
    nameController =
        TextEditingController(text: authController.user?.displayName);
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

    final user = authController.user;

    if (user != null) {
      String? imageUrl;

      // Update profile picture
      if (image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_profile_images')
            .child('${user.uid}.jpg');
        await ref.putFile(image!);
        imageUrl = await ref.getDownloadURL();
      }

      // Prepare data to update
      Map<String, dynamic> updateData = {
        'fullName': nameController.text,
      };

      if (imageUrl != null) {
        updateData['profileImageUrl'] = imageUrl;
      }

      // Update Firestore
      await authController.updateUserData(user.uid, updateData);

      // Update Firebase Auth user
      await user.updateDisplayName(nameController.text);
      if (imageUrl != null) {
        await user.updatePhotoURL(imageUrl);
      }

      // Refresh the user
      await authController.refreshUser();

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
    super.dispose();
  }
}

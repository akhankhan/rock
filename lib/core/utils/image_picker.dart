import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage({required ImageSource source}) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static Future<File?> pickImageFromGallery() async {
    return await pickImage(source: ImageSource.gallery);
  }

  static Future<File?> pickImageFromCamera() async {
    return await pickImage(source: ImageSource.camera);
  }
}

import 'package:flutter/material.dart';

enum Role { buyer, seller }

class HomePrivder extends ChangeNotifier {
  Role? selectedRole = Role.buyer;
  String? category;
  String? subCategory;

  Map<String, List<String>> categorySubcategoryMap = {
    "Facted Grade": ["Precious Stone", "Semi Precious Stone"],
    "Rough Item": ["Raw Stone", "Uncut Gem"],
    "Matrix": ["Mineral Matrix", "Gemstone Matrix"]
  };

  HomePrivder() {
    category = categorySubcategoryMap.keys.first;
    subCategory = categorySubcategoryMap[category]!.first;
  }

  void setRole(Role role) {
    selectedRole = role;
    notifyListeners();
  }

  void setCategory(String? newCategory) {
    category = newCategory;
    subCategory = categorySubcategoryMap[newCategory]!.first;
    notifyListeners();
  }

  void setSubCategory(String? newSubCategory) {
    subCategory = newSubCategory;
    notifyListeners();
  }
}

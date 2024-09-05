import 'package:flutter/material.dart';

enum Role { buyer, seller }

class HomePrivder extends ChangeNotifier {
  Role? selectedRole = Role.buyer;

  void setRole(Role role) {
    selectedRole = role;
    notifyListeners();
  }
}

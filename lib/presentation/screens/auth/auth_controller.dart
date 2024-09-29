import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fine_rock/core/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  UserModel? _userModel;
  String phoneNumber = '';

  UserModel? get userModel => _userModel;

  AuthController() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> refreshUser() async {
    User? freshUser = _auth.currentUser;
    if (freshUser != null) {
      await freshUser.reload();
      await _loadUserData(freshUser.uid);
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _userModel =
            UserModel.fromFirestore(userDoc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> signUp(
      String email, String password, String fullName, String role) async {
    try {
      isLoading = true;
      notifyListeners();

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        fullName: fullName,
        email: email,
        role: role,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());

      _userModel = newUser;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print("Error during signup: $e");
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserData(userCredential.user!.uid);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print("Error during login: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _userModel = null;
      notifyListeners();
    } catch (e) {
      print("Error during logout: $e");
      rethrow;
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      if (_userModel != null) {
        await _firestore.collection('users').doc(_userModel!.id).update(data);
        await _loadUserData(_userModel!.id);
      }
    } catch (e) {
      print("Error updating user data: $e");
      rethrow;
    }
  }
}

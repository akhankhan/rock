import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fine_rock/core/models/user_model.dart';
import 'package:fine_rock/presentation/screens/home/home_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  UserModel? _userModel;
  String phoneNumber = '';
  String? userRole;
  bool isAuthenticated = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  UserModel? get userModel => _userModel;

  AuthController() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData(user.uid); // This is async
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
      _handleError('Error loading user data', e);
    }
  }

  Future<void> signUp(
      String email, String password, String fullName, String role) async {
    try {
      final UserCredential userCredential =
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
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required String role,
    required BuildContext context,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _loadUserData(userCredential.user!.uid);
      userRole = role;
      isAuthenticated = true;
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      if (role == "Buyer") {
        homeProvider.setRole(Role.buyer);
      } else if (role == "Seller") {
        homeProvider.setRole(Role.seller);
      } else {
        throw Exception('Invalid role: $role');
      }
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _userModel = null;
      notifyListeners();
    } catch (e) {
      _handleError('Error during logout', e);
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      if (_userModel != null) {
        await _firestore.collection('users').doc(_userModel!.id).update(data);
        await _loadUserData(_userModel!.id);
      }
    } catch (e) {
      _handleError('Error updating user data', e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided for this user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  void _handleError(String message, dynamic error) {
    isLoading = false;
    notifyListeners();
    print("$message: $error");
    throw CustomAuthException(
        'An unexpected error occurred. Please try again.');
  }

  void check() {
    
  }
}

class CustomAuthException implements Exception {
  final String message;
  CustomAuthException(this.message);

  @override
  String toString() => message;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  User? _user;
  //String? _role;

  User? get user => _user;
  //String? get role => _role;

  AuthController() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      //   _loadRole();
      notifyListeners();
    });
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> refreshUser() async {
    User? freshUser = _auth.currentUser;
    if (freshUser != null) {
      await freshUser.reload();
      _user = _auth.currentUser;
      // await _loadRole();
      notifyListeners();
    }
  }

  // Future<void> _loadRole() async {
  //   if (_user != null) {
  //     try {
  //       DocumentSnapshot userDoc =
  //           await _firestore.collection('users').doc(_user!.uid).get();
  //       if (userDoc.exists) {
  //         _role = userDoc.get('role');
  //         notifyListeners();
  //       }
  //     } catch (e) {
  //       print("Error loading role: $e");
  //     }
  //   }
  // }

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
      _user = userCredential.user;

      // Update display name
      await _user?.updateDisplayName(fullName);

      // Store user data in Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'id': _user!.uid,
        'fullName': fullName,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // _role = role;
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
      _user = userCredential.user;
      //  await _loadRole();

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
      _user = null;
      //  _role = null;
      notifyListeners();
    } catch (e) {
      print("Error during logout: $e");
      rethrow;
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      await refreshUser();
    } catch (e) {
      print("Error updating user data: $e");
      rethrow;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return null; // Null means success
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'An unknown error occurred';
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<String?> register(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'An unknown error occurred';
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _auth.signOut();
    _setLoading(false);
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;


  Future<bool> signInWithEmail(String email, String password) async {
    try {
      print("Tentative de connexion avec l'email: $email");
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user; // L'utilisateur connecté
      print("Utilisateur connecté: ${_user?.email}");
      notifyListeners();
      return true; // Connexion réussie
    } catch (e) {
      print("Erreur de connexion: $e");
      _user = null;
      notifyListeners();
      return false; // Connexion échouée
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    _user = await _authService.signUpWithEmail(email, password);
    notifyListeners();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }
}

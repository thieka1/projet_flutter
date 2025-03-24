import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;

  User? get user => _user;

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      notifyListeners();
      return null;
    } catch (e) {
      return "Erreur de connexion : ${e.toString()}";
    }
  }

  Future<User?> signUpWithEmail(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user!;

      // Créer un profil par défaut dans Firestore
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "name": name,
        "email": email,
        "role": "user",  // Rôle par défaut
        "photoUrl": null,  // Pas de photo initiale (peut être une image par défaut)
        "createdAt": FieldValue.serverTimestamp(),
      });

      await user.sendEmailVerification();  // Envoi de l'email de vérification
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }


  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("users").doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc["role"] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }

}

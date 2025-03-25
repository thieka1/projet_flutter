import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmail(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User user = result.user!;

      String defaultProfileImage = "https://firebasestorage.googleapis.com/v0/b/ton-projet.appspot.com/o/default-profile.png?alt=media";

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "name": name,
        "email": email,
        "role": "membre",
        "profileImage": defaultProfileImage,
        "createdAt": FieldValue.serverTimestamp(),
      });

      await user.updateDisplayName(name);
      await user.sendEmailVerification();
      return user;
    } catch (e) {
      print("Erreur d'inscription : ${e.toString()}");
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print("Erreur de connexion : ${e.toString()}");
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Erreur de réinitialisation du mot de passe : ${e.toString()}");
    }
  }

  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        "profileImage": imageUrl,
      });
    } catch (e) {
      print("Erreur de mise à jour de l'image : ${e.toString()}");
    }
  }

}

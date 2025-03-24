import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/userprofil_Model.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile? userProfile;

  // Chargement du profil utilisateur
  Future<void> loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print("Chargement des données pour l'utilisateur ID : ${user.uid}");

      try {
        // Récupère les données depuis Firestore
        DocumentSnapshot userData = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

        if (userData.exists) {
          print("Données récupérées depuis Firestore : ${userData.data()}");

          userProfile = UserProfile(
            fullName: userData["name"] ?? "Nom non défini",  // Champ name
            email: userData["email"] ?? user.email!,  // Champ email
            profileImageUrl: userData["profileImage"] ?? "",  // Image du profil
          );
          notifyListeners();  // Notify listeners pour les mises à jour
        } else {
          print("Document utilisateur non trouvé dans Firestore.");
        }
      } catch (e) {
        print("Erreur lors de la récupération des données utilisateur : $e");
        // Optionnellement, tu peux ajouter un retour d'erreur ou une gestion spécifique
      }
    } else {
      print("Aucun utilisateur connecté.");
    }
  }

  Future<void> updateUserProfile(File imageFile) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Upload de l'image vers Firebase Storage
        String imageUrl = await uploadProfileImage(imageFile, user.uid);

        if (imageUrl.isNotEmpty) {
          // Mise à jour du profil dans Firestore
          await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
            "profileImage": imageUrl,
          });

          userProfile = UserProfile(
            fullName: userProfile!.fullName,
            email: userProfile!.email,
            profileImageUrl: imageUrl,
          );
          notifyListeners();
        } else {
          print("Erreur : L'image n'a pas pu être téléchargée.");
        }
      } catch (e) {
        print("Erreur lors de la mise à jour du profil : $e");
      }
    }
  }
  Future<String> uploadProfileImage(File file, String userId) async {
    try {
      // Télécharge l'image dans Firebase Storage
      TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref()
          .child('profile_images/$userId.png')
          .putFile(file);

      // Récupère l'URL de l'image téléchargée
      String imageUrl = await uploadTask.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image : $e');
      return '';
    }
  }
}


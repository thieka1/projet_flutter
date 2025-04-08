import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fichier_model.dart';

class FichierProvider with ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> uploadFile(String projectId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      double fileSize = file.lengthSync() / (1024 * 1024); // Mo
      String userId = _auth.currentUser?.uid ?? "inconnu";

      try {
        TaskSnapshot uploadTask = await _storage
            .ref('uploads/$projectId/$fileName')
            .putFile(file);

        String downloadUrl = await uploadTask.ref.getDownloadURL();

        await _firestore.collection('fichiers').add({
          'nom': fileName,
          'url': downloadUrl,
          'taille': fileSize,
          'userId': userId,
          'projectId': projectId, // 🔥 Ajouté
          'dateAjout': FieldValue.serverTimestamp(),
        });

        notifyListeners();
      } catch (e) {
        print("Erreur upload fichier : $e");
      }
    }

  }


  Stream<List<FichierModel>> getFilesForProject(String projetId) {
    return _firestore
        .collection('fichiers')
        .where('projetId', isEqualTo: projetId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => FichierModel.fromFirestore(doc)).toList());
  }



}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/taches_Models.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TacheProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajouter une tâche
  Future<void> addTask({
    required String titre,
    required String description,
    required String assignedTo,
    required DateTime dueDate,
    required String projetId,
    required String statut,
  }) async {
    try {
      await _firestore.collection('taches').add({
        'titre': titre,
        'description': description,
        'assigneA': assignedTo,
        'dateLimite': dueDate.toIso8601String(),
        'statut': statut,
        'createdAt': FieldValue.serverTimestamp(),
        'projetId': projetId,
        'avancement': 0.0,
        'rappelEnvoye': false,
      });

      notifyListeners();
    } catch (e) {
      print("Erreur lors de l'ajout de la tâche : $e");
    }
  }




  // Récupérer les tâches depuis Firebase
  Stream<List<Tache>> fetchTasks() {
    return _firestore
        .collection('taches')
        .orderBy('createdAt', descending: true) // Tri par date de création
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Tache.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Mettre à jour une tâche (exemple)
  Future<void> updateTask(Tache task) async {
    try {
      await _firestore.collection('taches').doc(task.id).update(task.toMap());
      notifyListeners(); // Notifie les consommateurs du provider
    } catch (e) {
      print("Erreur lors de la mise à jour de la tâche : $e");
    }
  }


  Stream<List<Tache>> fetchTasksByProject(String projectId) {
    return _firestore
        .collection('taches')
        .where('projetId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Tache.fromFirestore(doc)).toList());
  }
}

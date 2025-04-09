import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/taches_Models.dart';

class TacheProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajouter une tâche
  // Version mise à jour de votre fonction addTask
  Future<void> addTask({
    required String titre,
    required String description,
    required String assignedTo,
    required DateTime dueDate,
    required String projetId,
    required String statut,
    required String priorite, // Nouveau paramètre
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
        'priorite': priorite, // Stockez la priorité
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
  // Ajouter un commentaire à une tâche spécifique
  Future<void> addCommentToTask({
    required String projectId,  // Id du projet (optionnel ici si vous l'utilisez juste pour une logique de filtrage)
    required String taskId,     // Id de la tâche à commenter
    required String contenu,    // Contenu du commentaire
    required String auteur,     // Auteur du commentaire (peut être l'utilisateur courant)
  }) async {
    try {
      // Créer un nouveau message
      Message newMessage = Message(
        auteur: auteur,
        contenu: contenu,
        date: DateTime.now(),
      );

      // Ajouter le message dans la liste des messages de la tâche
      await _firestore.collection('taches').doc(taskId).update({
        'messages': FieldValue.arrayUnion([newMessage.toMap()]), // Ajoute le message à la liste
      });

      // Notifier les écouteurs pour mettre à jour l'interface utilisateur
      notifyListeners();
    } catch (e) {
      print("Erreur lors de l'ajout du commentaire : $e");
    }
  }

  Future<String> getAuteurForProject(String projectId) async {
    try {
      DocumentSnapshot projectSnapshot = await _firestore
          .collection('projets')
          .doc(projectId)
          .get();

      if (projectSnapshot.exists) {
        String auteur = projectSnapshot['createur'] ?? 'mamy lay'; // Vérifiez que 'createur' est bien défini
        print("Auteur du projet : $auteur"); // Ajoutez un log ici
        return auteur;
      } else {
        print("Projet non trouvé");
        return 'mamy laye';
      }
    } catch (e) {
      print("Erreur lors de la récupération de l'auteur du projet: $e");
      return 'Inconnu';
    }
  }
  Future<void> updateTaskProgress(String taskId, double progress) async {
    try {
      // Assurez-vous que la valeur est entre 0 et 1
      progress = progress.clamp(0.0, 1.0);

      await _firestore.collection('taches').doc(taskId).update({
        'avancement': progress,
      });

      notifyListeners();
    } catch (e) {
      print("Erreur lors de la mise à jour de l'avancement: $e");
    }
  }

}

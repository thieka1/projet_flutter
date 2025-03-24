import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Créer un projet avec statut par défaut
  Future<void> createProject(String title, String description, DateTime startDate, DateTime endDate, String priority) async {
    try {
      await _db.collection('projects').add({
        'title': title,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
        'priority': priority,
        'status': 'En attente', // Le statut par défaut
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // Récupérer tous les projets en temps réel
  Stream<QuerySnapshot> getProjects() {
    return _db.collection('projects').orderBy('createdAt', descending: true).snapshots();
  }

  // Récupérer les projets par statut
  Stream<QuerySnapshot> getProjectsByStatus(String status) {
    return _db.collection('projects').where('status', isEqualTo: status).orderBy('createdAt', descending: true).snapshots();
  }

  // Mettre à jour le statut d'un projet

  Future<void> updateProjectStatus(String projectId, String status) async {
    try {
      await _db.collection('projects').doc(projectId).update({'status': status});
    } catch (e) {
      throw Exception("Erreur mise à jour statut: $e");
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _db.collection('projects').doc(projectId).delete();
    } catch (e) {
      throw Exception("Erreur suppression projet: $e");
    }
  }
}

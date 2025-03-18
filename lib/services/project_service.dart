import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createProject(String title, String description, DateTime startDate, DateTime endDate, String priority) async {
    try {
      await _db.collection('projects').add({
        'title': title,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
        'priority': priority,
        'status': 'En attente',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Stream<QuerySnapshot> getProjects() {
    return _db.collection('projects').orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getProjectsByStatus(String status) {
    return _db.collection('projects').where('status', isEqualTo: status).orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateProjectStatus(String projectId, String status) async {
    try {
      await _db.collection('projects').doc(projectId).update({
        'status': status,
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

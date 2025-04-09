import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, int> projectStats = {};
  Map<String, int> userStats = {};
  double projectCompletion = 0.0;

  Future<void> fetchDashboardData() async {
    await fetchProjectStats();
    await fetchUserStats();
    notifyListeners();
  }

  Future<void> fetchProjectStats() async {
    final snapshot = await _firestore.collection('projects').get();
    int enCours = 0, termines = 0, annules = 0, total = 0, completedPercentSum = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String status = data['status'] ?? 'en cours';
      double completion = (data['completion'] ?? 0).toDouble();

      total++;
      completedPercentSum += completion.toInt();

      if (status == 'en cours') enCours++;
      if (status == 'terminé') termines++;
      if (status == 'annulé') annules++;
    }

    projectStats = {
      'En cours': enCours,
      'Terminés': termines,
      'Annulés': annules,
    };
    projectCompletion = total > 0 ? completedPercentSum / total : 0;
  }

  Future<void> fetchUserStats() async {
    final snapshot = await _firestore.collection('users').get();
    int actifs = 0, inactifs = 0;

    for (var doc in snapshot.docs) {
      final actif = doc['actif'] ?? true;
      if (actif) {
        actifs++;
      } else {
        inactifs++;
      }
    }

    userStats = {
      'Actifs': actifs,
      'Inactifs': inactifs,
    };
  }

  Future<void> toggleUserStatus(String userId, bool actif) async {
    await _firestore.collection('users').doc(userId).update({'actif': actif});
    await fetchUserStats();
    notifyListeners();
  }
}

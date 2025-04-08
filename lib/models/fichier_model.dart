import 'package:cloud_firestore/cloud_firestore.dart';

class FichierModel {
  final String id;
  final String nom;
  final String url;
  final double taille;
  final String userId;
  final String projetId; // 🔥 Ajouté
  final DateTime dateAjout;

  FichierModel({
    required this.id,
    required this.nom,
    required this.url,
    required this.taille,
    required this.userId,
    required this.projetId,
    required this.dateAjout,
  });

  factory FichierModel.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return FichierModel(
      id: doc.id,
      nom: data['nom'],
      url: data['url'],
      taille: data['taille'].toDouble(),
      userId: data['userId'],
      projetId: data['projetId'],
      dateAjout: (data['dateAjout'] as Timestamp).toDate(),
    );
  }

}

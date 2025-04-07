import 'package:cloud_firestore/cloud_firestore.dart';

class FichierModel {
  String id;
  String nom;
  String url;
  double taille;
  String userId;
  DateTime dateAjout;

  // Constructeur
  FichierModel({
    required this.id,
    required this.nom,
    required this.url,
    required this.taille,
    required this.userId,
    required this.dateAjout,
  });

  // Convertir un document Firestore en objet FichierModel
  factory FichierModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return FichierModel(
      id: doc.id,
      nom: data['nom'] ?? '',
      url: data['url'] ?? '',
      taille: (data['taille'] as num?)?.toDouble() ?? 0.0,
      userId: data['userId'] ?? '',
      dateAjout: (data['dateAjout'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'url': url,
      'taille': taille,
      'userId': userId,
      'dateAjout': FieldValue.serverTimestamp(),
    };
  }
}

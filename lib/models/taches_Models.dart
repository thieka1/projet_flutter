import 'package:cloud_firestore/cloud_firestore.dart';

enum Priorite { Basse, Moyenne, Haute }

class Tache {
  String id;
  String titre;
  String description;
  Priorite priorite;
  String assigneA;
  DateTime dateLimite;
  double avancement;
  bool rappelEnvoye;
  String projetId;
  String statut;

  Tache({
    required this.id,
    required this.titre,
    required this.description,
    required this.priorite,
    required this.assigneA,
    required this.dateLimite,
    required this.avancement,
    this.rappelEnvoye = false,
    this.statut = 'En attente',
    required this.projetId,
  });

  factory Tache.fromMap(String id, Map<String, dynamic> data) {
    return Tache(
      id: id,
      titre: data['titre'] ?? 'Sans titre',
      description: data['description'] ?? 'Aucune description',
      priorite: stringToPriorite(data['priorite'] ?? 'Moyenne'),
      assigneA: data['assigneA'] ?? 'Non Assigné',
      dateLimite: DateTime.tryParse(data['dateLimite']) ?? DateTime.now(),
      avancement: (data['avancement'] ?? 0.0).toDouble(),
      rappelEnvoye: data['rappelEnvoye'] ?? false,
      projetId: data['projetId'] ?? '',
      statut: data['statut'] ?? 'En attente',

    );
  }

  factory Tache.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Tache(
      id: doc.id,
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      priorite: Tache.stringToPriorite(data['priorite'] ?? 'Moyenne'), // ✅ Correction ici
      assigneA: data['assigneA'] ?? '',
      projetId: data['projetId'] ?? '',
      dateLimite: DateTime.tryParse(data['dateLimite'] ?? '') ?? DateTime.now(),
      rappelEnvoye: data['rappelEnvoye'] ?? false,
      avancement: (data['avancement'] ?? 0.0).toDouble(),
      statut: data['statut'] ?? 'En attente',
    );
  }



  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'description': description,
      'priorite': prioriteToString(priorite),
      'assigneA': assigneA,
      'dateLimite': dateLimite.toIso8601String(),
      'avancement': avancement,
      'rappelEnvoye': rappelEnvoye,
      'projetId': projetId,
      'statut': statut,
    };
  }

  static String prioriteToString(Priorite priorite) {
    return priorite.toString().split('.').last;
  }

  static Priorite stringToPriorite(String priorite) {
    return Priorite.values.firstWhere(
          (e) => e.toString().split('.').last == priorite,
      orElse: () => Priorite.Moyenne,
    );
  }

}

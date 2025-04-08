import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String auteur;
  String contenu;
  DateTime date;

  Message({
    required this.auteur,
    required this.contenu,
    required this.date,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      auteur: map['auteur'] ?? 'Inconnu',
      contenu: map['contenu'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'auteur': auteur,
      'contenu': contenu,
      'date': date.toIso8601String(),
    };
  }
}


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
  List<Message> messages; // ✅ Nouveau champ messages

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
    this.messages = const [], // ✅ Initialisation par défaut
  });

  factory Tache.fromMap(String id, Map<String, dynamic> data) {
    var rawMessages = data['messages'] as List<dynamic>? ?? [];
    List<Message> messageList = rawMessages.map((e) => Message.fromMap(e)).toList();

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
      messages: messageList,
    );
  }

  factory Tache.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    var rawMessages = data['messages'] as List<dynamic>? ?? [];
    List<Message> messageList = rawMessages.map((e) => Message.fromMap(e)).toList();

    return Tache(
      id: doc.id,
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      priorite: Tache.stringToPriorite(data['priorite'] ?? 'Moyenne'),
      assigneA: data['assigneA'] ?? '',
      projetId: data['projetId'] ?? '',
      dateLimite: DateTime.tryParse(data['dateLimite'] ?? '') ?? DateTime.now(),
      rappelEnvoye: data['rappelEnvoye'] ?? false,
      avancement: (data['avancement'] ?? 0.0).toDouble(),
      statut: data['statut'] ?? 'En attente',
      messages: messageList,
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
      'messages': messages.map((m) => m.toMap()).toList(), // ✅ Enregistrement des messages
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

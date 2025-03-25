import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ProjectProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  BuildContext? get context => null;

  // Ajouter un projet
  Future<void> addProject(Project project) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Utilisateur non authentifié.");

      // Initialiser les membres avec l'utilisateur connecté (chef de projet)
      Map<String, String> members = {user.email!: "chef de projet"};

      // Ajouter les membres par email qui ont été sélectionnés
      members.addAll(
          project.members); // Fusionner les membres ajoutés par email



      // Ajout du projet dans Firestore avec les membres
      DocumentReference docRef = await _firestore.collection('projects').add({
        'title': project.title,
        'description': project.description,
        'startDate': project.startDate.toIso8601String(),
        'endDate': project.endDate.toIso8601String(),
        'priority': project.priority,
        'status': 'En attente',
        'members': members, // Enregistrer la map des membres (email : rôle)
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du projet: $e");
    }
  }


  // Récupérer les projets
  Stream<List<Project>> fetchProjects() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Si l'utilisateur n'est pas authentifié, retourner une liste vide
      return Stream.value([]);
    }

    return _firestore
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
        // Convertir chaque document en objet Project
        return Project.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      })
          .where((project) {
        // Vérifier si l'email de l'utilisateur fait partie des membres
        return project.members.containsKey(user.email);
      }).toList();
    });
  }


  void updateProject(Project updatedProject) {
    // Trouver l'indice du projet à mettre à jour dans la liste
    int index = _projects.indexWhere((project) =>
    project.id == updatedProject.id);

    // Si le projet est trouvé, on le remplace par la version mise à jour
    if (index != -1) {
      _projects[index] = updatedProject;
      notifyListeners(); // Notifie les widgets qui écoutent cet état
    }
  }


  void _addMemberToProject(BuildContext context, Project project, String email) async {
    if (email.isEmpty) {
      print("Erreur: Email vide");
      return;
    }

    try {
      // Référence au document du projet dans Firestore
      DocumentReference projectRef =
      FirebaseFirestore.instance.collection('projects').doc(project.id);

      // Récupération des données du projet
      DocumentSnapshot projectSnapshot = await projectRef.get();
      if (!projectSnapshot.exists) {
        print("Erreur: Projet introuvable !");
        return;
      }

      Map<String, dynamic> projectData =
      projectSnapshot.data() as Map<String, dynamic>;

      // Récupère la liste des membres ou crée une nouvelle Map vide si elle n'existe pas
      Map<String, dynamic> members =
      projectData.containsKey('members') ? projectData['members'] : {};

      // Vérifie si l'email du membre est déjà présent
      if (members.containsKey(email)) {
        print("Membre déjà ajouté");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ce membre est déjà ajouté')),
        );
        return;
      }

      // Ajoute le membre à la liste des membres
      members[email] = 'Membre';

      // Met à jour les membres dans Firestore
      await projectRef.update({'members': members});

      // Met à jour les membres dans le provider local
      Provider.of<ProjectProvider>(context, listen: false).updateProject(project);

      print("Membre ajouté avec succès à Firebase !");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Membre ajouté au projet avec succès')),
      );
    } catch (e) {
      print("Erreur lors de l'ajout du membre : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout du membre")),
      );
    }
  }

  Future<Project> getProjectById(String projectId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('projects').doc(projectId).get();
      if (!doc.exists) {
        throw Exception("Projet introuvable !");
      }
      return Project.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception("Erreur lors de la récupération du projet : $e");
    }
  }

  Future<Map<String, String>> getUserByEmail(String email) async {
    try {
      // Récupérer le document de l'utilisateur depuis Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(email) // Utiliser l'email comme ID du document
          .get();

      // Vérifier si le document existe
      if (snapshot.exists) {
        var userData = snapshot.data();

        // Ajouter des logs pour voir les données récupérées
        print("Données utilisateur récupérées : $userData");

        // Vérifier si le champ 'name' existe et le récupérer
        String name = userData?['name'] ?? "Nom inconnu";  // Récupérer le champ 'name'

        // Log des valeurs récupérées
        print("Nom complet : $name");

        return {'name': name};  // Retourner le nom complet
      } else {
        // Si l'utilisateur n'existe pas dans Firestore, renvoyer des valeurs par défaut
        print("Aucun utilisateur trouvé avec l'email $email");  // Log si aucun utilisateur trouvé
        return {'name': "Nom inconnu"};  // Valeur par défaut
      }
    } catch (e) {
      // Si une erreur se produit lors de la récupération des données
      print("Erreur lors de la récupération des données utilisateur: $e");
      return {'name': "Nom inconnu"};  // Valeur par défaut en cas d'erreur
    }
  }




}

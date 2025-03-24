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
    return _firestore
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) =>
            Project.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
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


  void _addMemberToProject(Project project, String email) async {
    void _addMemberToProject(BuildContext context, Project project,
        String email) async {
      if (email.isEmpty) {
        print("Erreur: Email vide");
        return;
      }

      try {
        DocumentReference projectRef =
        FirebaseFirestore.instance.collection('projects').doc(project.id);

        DocumentSnapshot projectSnapshot = await projectRef.get();
        if (!projectSnapshot.exists) {
          print("Erreur: Projet introuvable !");
          return;
        }

        Map<String, dynamic> projectData =
        projectSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> members =
        projectData.containsKey('members') ? projectData['members'] : {};

        if (members.containsKey(email)) {
          print("Membre déjà ajouté");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ce membre est déjà ajouté')),
          );
          return;
        }

        members[email] = 'Membre';

        await projectRef.update({'members': members});

        Provider.of<ProjectProvider>(context, listen: false).updateProject(
            project);

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
  }


}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gestion_des_projets/models/file_Model.dart';
import 'package:file_picker/file_picker.dart';

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
      return Stream.value([]); // Si l'utilisateur n'est pas authentifié, retourne une liste vide
    }

    return _firestore
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
        return Project.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      })
          .where((project) {
        return project.members.containsKey(user.email); // Vérifie si l'email de l'utilisateur fait partie des membres
      })
          .toList();
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
      print("Tentative de récupération des données pour l'email: $email");

      // Effectuer une requête où l'email est un champ dans le document
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)  // Chercher par email dans le champ 'email'
          .get();

      // Vérifier si des documents ont été trouvés
      if (snapshot.docs.isNotEmpty) {
        var userData = snapshot.docs.first.data();  // Prendre le premier document
        print("Données utilisateur récupérées : $userData");

        String name = userData['name'] ?? "Nom inconnu";  // Si 'name' est null, utiliser "Nom inconnu"
        print("Nom récupéré : $name");

        return {'name': name};  // Retourner le nom
      } else {
        print("Aucun utilisateur trouvé avec l'email: $email");
        return {'name': "Nom inconnu"};  // Retourner une valeur par défaut
      }
    } catch (e) {
      print("Erreur lors de la récupération des données utilisateur: $e");
      return {'name': "Nom inconnu"};  // Retourner une valeur par défaut en cas d'erreur
    }
  }

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      double fileSize = (file.lengthSync() / (1024 * 1024)); // Convertir en Mo
      String userId = _auth.currentUser?.uid ?? "Inconnu";

      try {
        // 🔹 2. Upload sur Firebase Storage
        TaskSnapshot uploadTask = await _storage
            .ref('uploads/$fileName')
            .putFile(file);

        // 🔹 3. Récupérer l'URL du fichier
        String downloadUrl = await uploadTask.ref.getDownloadURL();

        // 🔹 4. Enregistrer dans Firestore
        await _firestore.collection('fichiers').add({
          'nom': fileName,
          'url': downloadUrl,
          'taille': fileSize,
          'userId': userId,
          'dateAjout': FieldValue.serverTimestamp(),
        });

        print("Fichier uploadé avec succès !");
      } catch (e) {
        print("Erreur lors de l'upload : $e");
      }
    } else {
      print("Aucun fichier sélectionné.");
    }
  }

  // 🔹 5. Récupérer la liste des fichiers
  Stream<List<FichierModel>> getFiles() {
    return _firestore.collection('fichiers').orderBy('dateAjout', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => FichierModel.fromFirestore(doc)).toList(),
    );
  }


  Future<void> updateMemberRole(BuildContext context, Project project, String memberEmail, String newRole) async {
    try {
      // Référence au document du projet dans Firestore
      final DocumentReference projectRef = FirebaseFirestore.instance.collection('projects').doc(project.id);

      // Créer une copie de la map des membres du projet
      Map<String, String> updatedMembers = Map<String, String>.from(project.members);

      // Mettre à jour le rôle du membre
      updatedMembers[memberEmail] = newRole;

      // Mettre à jour le document dans Firestore
      await projectRef.update({
        'members': updatedMembers,
      });

      // Mettre à jour l'objet projet local
      project.members = updatedMembers;

      // Notifier les listeners pour rafraîchir l'UI
      notifyListeners();

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le rôle de $memberEmail a été modifié avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Gérer les erreurs
      print('Erreur lors de la mise à jour du rôle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la modification du rôle: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}















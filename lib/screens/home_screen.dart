import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../provider/project_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4 onglets
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // On utilise StreamBuilder pour écouter les projets en temps réel
    return StreamBuilder<List<Project>>(
      stream: Provider.of<ProjectProvider>(context, listen: false)
          .fetchProjects(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final projects = snapshot.data ?? [];
        // Filtrage par statut
        final enAttente = projects.where((p) => p.status == 'En attente').toList();
        final enCours = projects.where((p) => p.status == 'En cours').toList();
        final termines = projects.where((p) => p.status == 'Terminés').toList();
        final annules = projects.where((p) => p.status == 'Annulés').toList();

        return Scaffold(
          appBar: _buildAppBar(),
          drawer: _buildDrawer(),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un projet...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onChanged: (value) {
                    // Implémente la recherche si nécessaire
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProjectList(enAttente),
                    _buildProjectList(enCours),
                    _buildProjectList(termines),
                    _buildProjectList(annules),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/createproject');
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.blueAccent,
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('SunuProjet', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.blueAccent,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        tabs: [
          Tab(text: 'En attente'),
          Tab(text: 'En cours'),
          Tab(text: 'Terminés'),
          Tab(text: 'Annulés'),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
      ],
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Text('Menu',
              style: TextStyle(color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
          _buildDrawerItem(Icons.home, 'Accueil', onTap: () {}),
          _buildDrawerItem(Icons.settings, 'Paramètres', onTap: () {}),
          _buildDrawerItem(Icons.logout, 'Déconnexion', onTap: _logout),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title,
      {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: TextStyle(color: Colors.black, fontSize: 16)),
      onTap: onTap,
      tileColor: Colors.white,
      shape: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    );
  }

  Widget _buildProjectList(List<Project> projects) {
    if (projects.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre et priorité
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _getPriorityColor(project.priority),
                      ),
                      child: Text(
                        project.priority,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                // Description du projet
                Text(
                  project.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10),
                // Barre de progression
                LinearProgressIndicator(
                  backgroundColor: Colors.grey[350],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  value: 0.0,
                ),
                SizedBox(height: 6),
                // Ligne : % et date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "0% En attente",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      "Échéance : ${project.endDate.day}/${project.endDate.month}/${project.endDate.year}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Icône profil en bas à gauche
                Align(
                  alignment: Alignment.bottomLeft,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(
                      Icons.account_circle,
                      size: 22,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/projectprofil',
                        arguments: project,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Basse':
        return Colors.blue; // Couleur bleue pour "Basse"
      case 'Urgente':
        return Colors.red; // Couleur rouge pour "Urgente"
      case 'Haute':
        return Colors.yellow; // Couleur jaune pour "Haute"
      default:
        return Colors.grey; // Couleur par défaut pour toute autre valeur
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text('Aucun projet trouvé',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Créez un nouveau projet pour commencer',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(Project project) {
    final TextEditingController _emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un membre'),
          content: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Email du membre',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String email = _emailController.text.trim();
                _addMemberToProject(project, email); // Ajouter le membre
                Navigator.pop(context); // Fermer le dialog
              },
              child: Text('Ajouter'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer sans ajouter
              },
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }


  void _addMemberToProject(Project project, String email) {
    if (email.isEmpty || project.members.containsKey(email)) {
      print("Erreur: Membre déjà ajouté ou email vide");
      return;
    }

    // Ajoute le membre à la Map
    project.members[email] = 'Membre';

    // Affichage des membres avant mise à jour
    print("Membres avant mise à jour: ${project.members}");

    // Met à jour le projet dans le provider
    Provider.of<ProjectProvider>(context, listen: false).updateProject(project);

    // Affichage des membres après mise à jour
    print("Membres après mise à jour: ${project.members}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membre ajouté au projet avec succès')),
    );
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print("Erreur de déconnexion : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la déconnexion.")),
      );
    }
  }
}

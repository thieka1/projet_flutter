import 'package:flutter/material.dart';
import 'package:gestion_des_projets/provider/project_provider.dart';
import '../models/project.dart';

class ProfilProjectPage extends StatefulWidget {
  @override
  _ProfilProjectPageState createState() => _ProfilProjectPageState();
}

class _ProfilProjectPageState extends State<ProfilProjectPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double progress = 0.0;
  String projectStatus = "En attente";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4 onglets
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer l'objet `Project` passé dans les arguments
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;
    final String projectTitle = project.title;  // Extraire le titre du projet depuis l'objet `Project`

    return Scaffold(
      appBar: AppBar(
        title: Text(projectTitle, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          tabs: [
            Tab(text: 'Aperçu'),
            Tab(text: 'Tâches'),
            Tab(text: 'Membres'),
            Tab(text: 'Fichiers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApercuTab(project),  // Passer `project` comme argument
          _buildTasksTab(),
          _buildMembersTab(),
          _buildFilesTab(),
        ],
      ),
    );
  }

  Widget _buildApercuTab(Project project) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        project.title,
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          project.status,
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Priorité: ${project.priority}",
                        style: TextStyle(color: Colors.orange[600]),
                      ),
                      SizedBox(height: 8), // Espacement entre la priorité et la description
                      Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4), // Espacement entre "Description" et la description
                      Text(project.description, style: TextStyle(color: Colors.black54)),
                      SizedBox(height: 8), // Espacement entre la description et les dates
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            "Début: ${project.startDate.day}/${project.startDate.month}/${project.startDate.year}",
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            "Fin: ${project.endDate.day}/${project.endDate.month}/${project.endDate.year}",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  )

                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("Avancement du projet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: progress / 100, // Convertir en pourcentage
                          strokeWidth: 6,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                        ),
                      ),
                      Text("${progress.toInt()}%", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text("Changer le statut du projet", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statusButton("En attente", Colors.orange, fontSize: 12),
                      _statusButton("En cours", Colors.blue, fontSize: 12),
                      _statusButton("Terminé", Colors.green, fontSize: 12),
                      _statusButton("Annulé", Colors.red, fontSize: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String status, Color color, {double fontSize = 14}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        setState(() {
          projectStatus = status;
          progress = _getProgressForStatus(status);
        });
      },
      child: Text(status),
    );
  }

  double _getProgressForStatus(String status) {
    switch (status) {
      case "En cours":
        return 50;
      case "Terminé":
        return 100;
      case "Annulé":
        return 0;
      default:
        return 0;
    }
  }

  Widget _buildTasksTab() {
    return Center(
      child: Text("Liste des tâches du projet", style: TextStyle(fontSize: 18)),
    );
  }
  // Instance de ProjectProvider
  final ProjectProvider _projectProvider = ProjectProvider();
  Widget _buildMembersTab() {
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;

    // Trier les membres pour que le créateur (chef de projet) apparaisse en premier
    List<MapEntry<String, String>> sortedMembers = project.members.entries.toList();
    sortedMembers.sort((a, b) {
      if (a.value == "chef de projet") return -1;  // Le créateur doit être en premier
      if (b.value == "chef de projet") return 1;   // Le créateur doit être en premier
      return 0;
    });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: sortedMembers.length,
        itemBuilder: (context, index) {
          String email = sortedMembers[index].key;
          String role = sortedMembers[index].value;

          // Remplacer "chef de projet" par "créateur"
          if (role == "chef de projet") {
            role = "créateur";
          }

          return FutureBuilder<Map<String, String>>(
            future: _projectProvider.getUserByEmail(email),  // Appel via l'instance de ProjectProvider
            builder: (context, snapshot) {
              print("Email en cours de récupération : $email");  // Log de l'email
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text("Erreur lors de la récupération des données");
              }

              if (snapshot.hasData) {
                String name = snapshot.data!['name']!;  // Récupérer le nom complet

                print("Nom récupéré : $name");  // Log du nom récupéré

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8),
                    leading: Icon(Icons.person, color: Colors.blueAccent),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$name",  // Afficher le prénom et nom
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          email,  // Afficher l'email sous le nom
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: role != "Membre"
                        ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: role == "créateur" ? Colors.orange : Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: role == "créateur" ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        role,  // Afficher le rôle
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    )
                        : null, // Si le rôle est "Membre", ne rien afficher
                  ),
                );
              }

              return Container();
            },
          );
        },
      ),
    );
  }



  Widget _buildFilesTab() {
    return Center(
      child: Text("Liste des fichiers", style: TextStyle(fontSize: 18)),
    );
  }


}

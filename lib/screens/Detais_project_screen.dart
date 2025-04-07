import 'package:flutter/material.dart';
import 'package:gestion_des_projets/provider/project_provider.dart';
import '../models/project.dart';
import 'package:provider/provider.dart';

import '../models/taches_Models.dart';
import '../provider/taches_provider.dart';

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
          _buildTasksTab(project.id),
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
  Widget _buildTasksTab(String projectId) {
    return Consumer<TacheProvider>(
      builder: (context, tacheProvider, _) {
        return Scaffold(
          body: Column(
            children: [
              // Liste des tâches existantes
              Expanded(
                child: StreamBuilder<List<Tache>>(
                  stream: tacheProvider.fetchTasksByProject(projectId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur : ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('Aucune tâche à afficher.'));
                    }

                    List<Tache> taches = snapshot.data!;
                    return ListView.builder(
                      itemCount: taches.length,
                      itemBuilder: (context, index) {
                        Tache tache = taches[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ExpansionTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // Tout aligné à gauche
                              children: [
                                // Titre de la tâche
                                Text(
                                  tache.titre,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    // Priorité
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(tache.priorite.toString().split('.').last),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tache.priorite.toString().split('.').last,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    // Statut
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tache.statut,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    // Date limite
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(
                                          _formatDate(tache.dateLimite),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.expand_more, color: Colors.black), // Icône pour dérouler
                            children: [
                              // Contenu déroulant : description de la tâche
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                child: Text(
                                  tache.description,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddTaskDialog(context, tacheProvider, projectId);
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
          ),
        );
      },
    );
  }

// Dialogue pour ajouter une nouvelle tâche
  void _showAddTaskDialog(BuildContext context, TacheProvider tacheProvider, String projectId) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();
    final TextEditingController _assignedToController = TextEditingController();
    DateTime _dueDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Ajouter une tâche"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Titre'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _assignedToController,
                  decoration: InputDecoration(labelText: 'Assignée à'),
                ),
                ListTile(
                  title: Text('Date limite : ${_dueDate.toLocal().toString().split(' ')[0]}'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      _dueDate = pickedDate;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _descriptionController.text.isNotEmpty &&
                    _assignedToController.text.isNotEmpty) {
                  tacheProvider.addTask(
                    titre: _titleController.text,
                    description: _descriptionController.text,
                    assignedTo: _assignedToController.text,
                    dueDate: _dueDate,
                    projetId: projectId,
                    statut: 'En attente', // Statut par défaut
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez remplir tous les champs')),
                  );
                }
              },
              child: Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

// Méthode pour obtenir la couleur selon la priorité
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Haute':
        return Colors.yellow.shade700; // Jaune pour "Haute"
      case 'Moyenne':
        return Colors.orange;
      case 'Basse':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }


// Méthode pour formater la date
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
// Méthode pour obtenir la couleur selon la priorité
  Color _getTaskPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgente':
        return Colors.red;
      case 'haute':
        return Colors.orange;
      case 'moyenne':
        return Colors.yellow;
      case 'basse':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }





// Instance de ProjectProvider
  final ProjectProvider _projectProvider = ProjectProvider();

  Widget _buildMembersTab() {
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;

    List<MapEntry<String, String>> sortedMembers = project.members.entries.toList();
    sortedMembers.sort((a, b) {
      if (a.value == "chef de projet") return -1;
      if (b.value == "chef de projet") return 1;
      return 0;
    });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: sortedMembers.length,
        itemBuilder: (context, index) {
          String email = sortedMembers[index].key;
          String role = sortedMembers[index].value;

          if (role == "chef de projet") {
            role = "créateur";
          }

          return FutureBuilder<Map<String, String>>(
            future: _projectProvider.getUserByEmail(email),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }



              if (snapshot.hasData) {
                String name = snapshot.data!['name']!;

                return GestureDetector(
                  onTap: () {
                    _showRoleSelectionDialog(context, project, email);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8),
                      leading: Icon(Icons.person, color: Colors.blueAccent),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(email, style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      trailing: _buildRoleBadge(role),
                    ),
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
  void _showRoleSelectionDialog(BuildContext context, Project project, String email) {
    List<String> roles = ["Membre", "Admin", "chef de projet"];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: roles.map((role) {
              return ListTile(
                title: Text(role),
                onTap: () {
                  // Utiliser ProjectProvider pour mettre à jour le rôle
                  final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
                  projectProvider.updateMemberRole(context, project, email, role);
                  Navigator.pop(context); // Fermer le BottomSheet
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }




  Widget _buildRoleBadge(String role) {
    // Si le rôle est "Membre", ne rien afficher
    if (role == "Membre") {
      return SizedBox.shrink(); // Retourne un widget vide
    }

    // Sinon, on affiche un badge avec le rôle
    Color badgeColor = Colors.blueAccent;

    if (role == "créateur") {
      badgeColor = Colors.orange;
    } else if (role == "Admin") {
      badgeColor = Colors.blue;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor, width: 2),
      ),
      child: Text(
        role,
        style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}




Widget _buildFilesTab() {
  return Center(
    child: Text("Liste des fichiers", style: TextStyle(fontSize: 18)),
  );
}




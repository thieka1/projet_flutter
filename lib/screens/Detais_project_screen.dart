import 'package:flutter/material.dart';
import 'package:gestion_des_projets/provider/project_provider.dart';
import '../models/fichier_model.dart';
import '../models/project.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/taches_Models.dart';
import '../provider/FichierProvider.dart';
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
    final fichierProvider = Provider.of<FichierProvider>(context, listen: false);

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
          _buildFilesTab(context, fichierProvider, project.id),
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
                  SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: progress / 100, // Convertir en pourcentage
                          strokeWidth: 10,
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
                        return _buildTaskCard(tache, tacheProvider, projectId);
                      },
                    );
                  },
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

// Carte d'affichage de tâche
  Widget _buildTaskCard(Tache tache, TacheProvider tacheProvider, String projectId) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: _buildTaskHeader(tache),
        trailing: Icon(Icons.expand_more, color: Colors.black),
        children: [
          _buildTaskDetails(tache),
          _buildTaskDiscussion(tache, tacheProvider, projectId),
        ],
      ),
    );
  }

// En-tête de la tâche
  Widget _buildTaskHeader(Tache tache) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tache.titre,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 6),
        Row(
          children: [
            _buildPriorityChip(tache),
            SizedBox(width: 8),
            _buildStatusChip(tache),
            SizedBox(width: 8),
            _buildDueDate(tache),
          ],
        ),
      ],
    );
  }

// Chip de priorité
  Widget _buildPriorityChip(Tache tache) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _getPriorityColor(tache.priorite.toString().split('.').last),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tache.priorite.toString().split('.').last,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

// Chip de statut
  Widget _buildStatusChip(Tache tache) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tache.statut,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

// Date limite de la tâche
  Widget _buildDueDate(Tache tache) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 14, color: Colors.grey),
        SizedBox(width: 4),
        Text(
          _formatDate(tache.dateLimite),
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

// Détails de la tâche (Progression et description)
  Widget _buildTaskDetails(Tache tache) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progression : ${tache.avancement.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: tache.avancement / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              tache.avancement < 100 ? Colors.blue : Colors.green,
            ),
          ),
          SizedBox(height: 8),
          Text(
            tache.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[700]),
              SizedBox(width: 6),
              Text(
                'Assignée à : ${tache.assigneA}',
                style: TextStyle(fontSize: 14, color: Colors.grey[800], fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Section de discussion pour chaque tâche
  Widget _buildTaskDiscussion(Tache tache, TacheProvider tacheProvider, String projectId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discussion',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800]),
          ),
          SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: tache.messages.length,
            itemBuilder: (context, index) {
              final message = tache.messages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          message.auteur,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      message.contenu,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 12),
          _buildCommentField(tacheProvider, projectId, tache),
        ],
      ),
    );
  }

// Champ pour ajouter un commentaire
  Widget _buildCommentField(TacheProvider tacheProvider, String projectId, Tache tache) {
    TextEditingController commentController = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: commentController,
            decoration: InputDecoration(
              hintText: "Ajouter un commentaire...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            onSubmitted: (value) async {
              if (value.isNotEmpty) {
                String auteur = await tacheProvider.getAuteurForProject(projectId);
                print("Auteur récupéré : $auteur"); // Ajoutez un log ici pour vérifier
                tacheProvider.addCommentToTask(
                  projectId: projectId,
                  taskId: tache.id,
                  contenu: value,
                  auteur: auteur,
                );
                commentController.clear();
              }
            },
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.send, color: Colors.blue),
          onPressed: () async {
            String comment = commentController.text;
            if (comment.isNotEmpty) {
              String auteur = await tacheProvider.getAuteurForProject(projectId);
              print("Auteur récupéré : $auteur"); // Ajoutez un log ici pour vérifier
              tacheProvider.addCommentToTask(
                projectId: projectId,
                taskId: tache.id,
                contenu: comment,
                auteur: auteur,
              );
              commentController.clear();
            }
          },
        ),
      ],
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




Widget _buildFilesTab(BuildContext context, FichierProvider fichierProvider, String projetId) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.blueAccent, // Couleur du texte en blanc
            side: BorderSide(color: Colors.blue, width: 1), // Bordure légère bleue
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Bordure légèrement arrondie
            ),
          ),
          onPressed: () => fichierProvider.uploadFile(projetId),
          icon: Icon(Icons.add, color: Colors.white), // Icône en blanc
          label: Text(
            "Ajouter un fichier",
            style: TextStyle(color: Colors.white), // Texte en blanc
          ),
        ),
      ),

      Expanded(
        child: StreamBuilder<List<FichierModel>>(
          stream: fichierProvider.getFilesForProject(projetId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return Center(child: Text("Aucun fichier trouvé."));
            }

            final files = snapshot.data!;
            if (files.isEmpty) return Center(child: Text("Aucun fichier trouvé."));

            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  leading: Icon(Icons.insert_drive_file, size: 32, color: Colors.blue),
                  title: Text(file.nom),
                  subtitle: Text("Taille: ${file.taille.toStringAsFixed(2)} Mo"),
                );
              },
            );
          },
        ),
      )
    ],
  );
}




// Classe pour représenter un fichier
class FileItem {
  final IconData icon;
  final String name;
  final String size;
  final String addedBy;
  final String dateAdded;

  FileItem({
    required this.icon,
    required this.name,
    required this.size,
    required this.addedBy,
    required this.dateAdded,
  });
}





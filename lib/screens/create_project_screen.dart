import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../provider/project_provider.dart';

class CreateProjectPage extends StatefulWidget {
  @override
  _CreateProjectPageState createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPriority = 'Moyenne';
  final List<String> _priorities = ['Basse', 'Moyenne', 'Haute', 'Urgente'];

  Map<String, String> _selectedMembers = {};

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _addMember() {
    String email = _emailController.text.trim();
    if (email.isEmpty || _selectedMembers.containsKey(email)) {
      return;
    }

    setState(() {
      _selectedMembers[email] = 'Membre';
      _emailController.clear();
    });
  }

  void _removeMember(String email) {
    setState(() {
      _selectedMembers.remove(email);
    });
  }

  void _handleCreateProject() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _startDate == null ||
        _endDate == null ||
        _selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs et ajouter au moins un membre.")),
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("La date de fin doit être après la date de début.")),
      );
      return;
    }

    final project = Project(
      id: "",
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDate!,
      endDate: _endDate!,
      priority: _selectedPriority,
      status: "En attente",
      members: _selectedMembers,
    );

    try {
      await Provider.of<ProjectProvider>(context, listen: false).addProject(project);

      // Actualiser la liste des projets après l'ajout
      await Provider.of<ProjectProvider>(context, listen: false).fetchProjects();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Projet créé avec succès !")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Erreur: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la création du projet.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Créer un projet", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_titleController, "Titre du projet", Icons.title),
              SizedBox(height: 15),
              _buildTextField(_descriptionController, "Description", Icons.description, maxLines: 3),
              SizedBox(height: 20),
              Text("Dates du projet", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDatePicker("Date de début", _startDate, () => _selectDate(context, true)),
                  SizedBox(width: 10),
                  _buildDatePicker("Date de fin", _endDate, () => _selectDate(context, false)),
                ],
              ),
              SizedBox(height: 20),
              Text("Priorité", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildPrioritySelector(),
              SizedBox(height: 20),
              Text("Ajouter des membres", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(child: _buildTextField(_emailController, "Email du membre", Icons.person)),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.blueAccent),
                    onPressed: _addMember,
                  ),
                ],
              ),
              SizedBox(height: 10),
              _buildMemberList(),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleCreateProject,
                child: Text(
                  "Créer le projet",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.calendar_today, color: Colors.black54),
              Text(date == null ? label : "${date.day}/${date.month}/${date.year}"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      children: _priorities.map((priority) {
        return RadioListTile(
          title: Text(priority),
          value: priority,
          groupValue: _selectedPriority,
          onChanged: (value) {
            setState(() {
              _selectedPriority = value.toString();
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildMemberList() {
    return Column(
      children: _selectedMembers.keys.map((email) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text(email),
            subtitle: Text(_selectedMembers[email]!),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeMember(email),
            ),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SunuProjet',
          style: TextStyle(color: Colors.white), // Titre en blanc
        ),
        backgroundColor: Colors.blueAccent, // Couleur de l'AppBar
        iconTheme: IconThemeData(color: Colors.white), // Icônes (y compris l'icône du drawer) en blanc
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white, // Couleur du soulignement des onglets
          labelColor: Colors.white, // Couleur du texte des onglets (sélectionné)
          unselectedLabelColor: Colors.white.withOpacity(0.6), // Couleur du texte des onglets non sélectionnés
          tabs: [
            Tab(text: 'En attente'),
            Tab(text: 'En cours'),
            Tab(text: 'Terminés'),
            Tab(text: 'Annulés'),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white, // Couleur de fond blanche du Drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // En-tête du Drawer
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent, // Couleur de fond de l'en-tête
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white, // Texte de l'en-tête en blanc
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Éléments de menu avec séparation claire
            _buildDrawerItem(Icons.home, 'Accueil', onTap: () {
              // Naviguer ou gérer une action pour "Accueil"
            }),
            _buildDrawerItem(Icons.settings, 'Paramètres', onTap: () {
              // Naviguer ou gérer une action pour "Paramètres"
            }),
            _buildDrawerItem(Icons.logout, 'Déconnexion', onTap: () {
              // Gérer la déconnexion
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Center(
              child: Container(
                width: 350, // Longueur réduite de la barre de recherche
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un projet...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
            ),
          ),
          // Vue des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEmptyState('En attente'),
                _buildEmptyState('En cours'),
                _buildEmptyState('Terminés'),
                _buildEmptyState('Annulés'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigue vers la page pour créer un projet
          Navigator.pushNamed(context, '/createproject');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue, // Couleur du bouton flottant
      ),
    );
  }

  // Widget pour afficher l'état vide
  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Aucun projet trouvé',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Créez un nouveau projet pour commencer',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Fonction pour créer un ListTile avec bordure blanche
  Widget _buildDrawerItem(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent), // Icône bleue
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black, // Texte noir pour un bon contraste
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      tileColor: Colors.white, // Fond blanc de chaque élément
      shape: Border(
        bottom: BorderSide(color: Colors.grey.shade200, width: 1), // Ligne fine en bas pour la séparation
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Espacement interne
    );
  }
}

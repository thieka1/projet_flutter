import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestion_des_projets/provider/auth_provider.dart'; // Import du AuthProvider
import 'package:gestion_des_projets/provider/profil_provider.dart';
import 'package:gestion_des_projets/provider/project_provider.dart'; // Import du ProjectProvider
import 'package:gestion_des_projets/provider/taches_provider.dart';
import 'package:gestion_des_projets/screens/create_project_screen.dart';
import 'package:gestion_des_projets/screens/home_screen.dart';
import 'package:gestion_des_projets/screens/login_screen.dart';
import 'package:gestion_des_projets/screens/profi_screen.dart';
import 'package:gestion_des_projets/screens/Detais_project_screen.dart';
import 'package:gestion_des_projets/screens/signup_screen.dart';
import 'package:provider/provider.dart'; // Import de provider
import 'package:gestion_des_projets/screens/Detais_project_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(); // Initialisation de Firebase
    print("Firebase initialisé avec succès.");
  } catch (e) {
    print("Erreur d'initialisation de Firebase : $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider gère les informations de l'utilisateur connecté
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // ProjectProvider gère les projets
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => TacheProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SunuProjet',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login', // La page de connexion s'affichera en premier
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/createproject': (context) => CreateProjectPage(),
          '/signup': (context) => SignUpScreen(),
          '/profile': (context) => ProfileScreen(),
          '/projectprofil': (context) => ProfilProjectPage(),
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _signup() async {
    if (_passwordController.text == _confirmPasswordController.text) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signUpWithEmail(_emailController.text, _passwordController.text);
      if (authProvider.user != null) {
        // Naviguez vers le tableau de bord ou l'écran d'accueil
      } else {
        // Affichez un message d'erreur
      }
    } else {
      print('Les mots de passe ne correspondent pas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inscription',
          style: TextStyle(fontWeight: FontWeight.bold), // Ajout du gras
        ),
        backgroundColor: Colors.blueAccent, // Couleur de fond
        foregroundColor: Colors.white, // Couleur du texte et des icônes
      ),


    body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400), // Pour limiter la largeur du formulaire
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Centrage vertical
                crossAxisAlignment: CrossAxisAlignment.center, // Centrage horizontal
                children: [
                  Text(
                    'Créer un compte',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Rejoignez SunuProjet pour gérer vos projets',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom complet',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Adresse Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de Passe',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le Mot de Passe',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signup,
                    child: Text('S\'inscrire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: Size(double.infinity, 50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Vous avez déjà un compte? ',
                            ),
                            TextSpan(
                              text: 'Se connecter',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

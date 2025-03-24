import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage; // Stocke le message d'erreur

  Future<void> _login() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final error = await authProvider.signInWithEmail(_emailController.text, _passwordController.text);

      if (error == null) {
        // Connexion réussie, redirection vers l'écran principal
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Afficher l'erreur de connexion
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      // Gérer les erreurs de manière plus détaillée
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la connexion : ${e.toString()}')));
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'SunuProjet',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Connectez-vous pour continuer',
                  style: TextStyle(fontSize: 18),
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
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Implémentez la récupération de mot de passe ici
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue, // Set the text color to blue
                    ),
                    child: Text('Mot de passe oublié?'),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Se connecter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: Size(double.infinity, 50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
                // Affichage du message d'erreur, s'il existe
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Vous n\'avez pas de compte? ',
                          ),
                          TextSpan(
                            text: 'S\'inscrire',
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
    );
  }
}

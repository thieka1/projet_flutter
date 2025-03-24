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
  bool _isLoading = false;

  Future<void> _signup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      print("Veuillez remplir tous les champs !");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      print('Les mots de passe ne correspondent pas');
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$").hasMatch(_emailController.text)) {
      print("L'adresse email n'est pas valide !");
      return;
    }

    if (_passwordController.text.length < 6) {
      print("Le mot de passe doit contenir au moins 6 caractères !");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = await authProvider.signUpWithEmail(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      print("Inscription réussie, utilisateur enregistré !");
      Navigator.pushNamed(context, '/home');
    } else {
      print("Erreur d'inscription !");
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inscription',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Rejoignez SunuProjet pour gérer vos projets',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  _buildTextField(
                    controller: _nameController,
                    labelText: 'Nom complet',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    labelText: 'Adresse Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    labelText: 'Mot de Passe',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirmer le Mot de Passe',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text('S\'inscrire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                    ),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Vous avez déjà un compte? ',
                            ),
                            TextSpan(
                              text: 'Se connecter',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:hajz_sejours/core/app_theme.dart';
import 'package:hajz_sejours/features/auth/controller/login_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginController _loginController = LoginController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Tente de connecter l'utilisateur
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _loginController.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        final clientId = result['data']['id'] as int;
        if (clientId > 0) {
          Get.log('Login successful, navigating to /home with clientId: $clientId');
          Get.offNamed(
            '/home',
            arguments: {'clientId': clientId},
          );
        } else {
          _showErrorSnackBar("Erreur : ID du client invalide");
        }
      } else {
        _showErrorSnackBar(result['message']);
      }
    }
  }

  // Debug: Vérifie le token sauvegardé
  void _debugToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final clientId = prefs.getInt('clientId');
    Get.log('Stored token: $token, clientId: $clientId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Token: ${token ?? 'Aucun'}, ClientId: ${clientId ?? 'Aucun'}'),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // Affiche une erreur via SnackBar
  void _showErrorSnackBar(String message) {
    Get.log('Login error: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTheme.textStyle),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: AppTheme.primaryColor,
        textTheme: const TextTheme(
          bodyMedium: AppTheme.textStyle,
          headlineMedium: AppTheme.headingStyle,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                right: 0,
                child: Lottie.asset("assets/auth.json", width: 300, height: 300, fit: BoxFit.cover),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Connexion", style: AppTheme.headingStyle),
                            const SizedBox(height: 20),
                            _buildTextField(_emailController, "Email", Icons.email, validator: (value) {
                              if (value == null || value.isEmpty) return "Email requis";
                              if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value))
                                return "Email invalide";
                              return null;
                            }),
                            _buildPasswordField(_passwordController, "Mot de passe", validator: (value) {
                              if (value == null || value.isEmpty) return "Mot de passe requis";
                              if (value.length < 8) return "Au moins 8 caractères requis";
                              return null;
                            }),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Get.toNamed("/forgot-password"),
                                child: const Text(
                                  "Mot de passe oublié ?",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Se connecter"),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: () => Get.toNamed("/signup"),
                                child: const Text(
                                  "Créer un compte",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construit un champ de texte avec validation
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: AppTheme.textStyle,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: AppTheme.accentColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  // Construit un champ de mot de passe avec option de visibilité
  Widget _buildPasswordField(
      TextEditingController controller,
      String label, {
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: !_isPasswordVisible,
        validator: validator,
        style: AppTheme.textStyle,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.lock, color: AppTheme.accentColor),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }
}
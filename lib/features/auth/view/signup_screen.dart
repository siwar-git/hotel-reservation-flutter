import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:hajz_sejours/core/app_theme.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _numTelController = TextEditingController();
  final TextEditingController _localisationController = TextEditingController();
  DateTime? _birthday;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;
  bool _isButtonPressed = false;

  // Envoie un email de vérification à l'utilisateur
  Future<Map<String, dynamic>> _sendVerificationEmail(String email) async {
    try {
      final jsonBody = jsonEncode({
        'email': email,
        'isResetPassword': false,
      });
      Get.log('Send verification body: $jsonBody');
      var response = await http.post(
        Uri.parse(AppApi.sendVerificationUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );
      Get.log('Send verification response: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Code envoyé avec succès'};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['error'] ?? 'Erreur lors de l\'envoi de l\'email',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Erreur serveur : ${response.body}',
          };
        }
      }
    } catch (e) {
      Get.log('Send verification error: $e');
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  // Valide le formulaire et envoie le code de vérification
  void _signup() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez accepter les termes et conditions."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_birthday == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez sélectionner une date de naissance."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final formData = {
        'email': _emailController.text,
        'role': 'client',
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'motDePass': _passwordController.text,
        'localisation': _localisationController.text,
        'numTel': _numTelController.text,
        'username': _userNameController.text,
        'birthday': DateFormat('yyyy-MM-dd').format(_birthday!),
        'point': 15,
      };

      Get.log('Signup formData: $formData');
      Get.log('Signup formData types: ${formData.map((k, v) => MapEntry(k, v.runtimeType))}');

      final result = await _sendVerificationEmail(_emailController.text);

      setState(() => _isLoading = false);

      if (result['success']) {
        try {
          Get.log('Navigating to /verify with formData: $formData');
          FocusScope.of(context).unfocus();
          Get.toNamed(
            '/verify',
            arguments: {
              'email': _emailController.text,
              'formData': formData,
            },
          );
        } catch (e) {
          Get.log('Navigation error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de navigation : $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Ouvre un sélecteur de date pour la date de naissance
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthday = picked);
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _userNameController.dispose();
    _numTelController.dispose();
    _localisationController.dispose();
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
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Lottie.asset("assets/auth.json", width: 300, height: 300, fit: BoxFit.cover),
                ),
                Center(
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
                            const Text("Inscription", style: AppTheme.headingStyle),
                            const SizedBox(height: 24),
                            const Text("Informations personnelles", style: TextStyle(color: Colors.white70, fontSize: 18)),
                            const SizedBox(height: 12),
                            _buildTextField(_nomController, "Nom", Icons.person, validator: (value) {
                              if (value == null || value.isEmpty) return "Nom requis";
                              return null;
                            }),
                            _buildTextField(_prenomController, "Prénom", Icons.person_outline, validator: (value) {
                              if (value == null || value.isEmpty) return "Prénom requis";
                              return null;
                            }),
                            _buildTextField(_userNameController, "Nom d'utilisateur", Icons.account_circle, validator: (value) {
                              if (value == null || value.isEmpty) return "Nom d'utilisateur requis";
                              if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(value))
                                return "Caractères alphanumériques uniquement (3-20)";
                              return null;
                            }),
                            const SizedBox(height: 16),
                            const Text("Informations de connexion", style: TextStyle(color: Colors.white70, fontSize: 18)),
                            const SizedBox(height: 12),
                            _buildTextField(_emailController, "Email", Icons.email, validator: (value) {
                              if (value == null || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value))
                                return "Email invalide";
                              return null;
                            }),
                            _buildPasswordField(_passwordController, "Mot de passe", isMain: true),
                            _buildPasswordField(_confirmPasswordController, "Confirmer le mot de passe", isMain: false),
                            const SizedBox(height: 16),
                            const Text("Informations supplémentaires", style: TextStyle(color: Colors.white70, fontSize: 18)),
                            const SizedBox(height: 12),
                            _buildTextField(_numTelController, "Numéro de téléphone", Icons.phone, validator: (value) {
                              if (value == null || value.isEmpty) return "Numéro requis";
                              if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) return "Numéro invalide";
                              return null;
                            }),
                            _buildTextField(_localisationController, "Localisation", Icons.location_on, validator: (value) {
                              if (value == null || value.isEmpty) return "Localisation requise";
                              return null;
                            }),
                            _buildDatePicker(),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(
                                  value: _acceptTerms,
                                  onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                                  activeColor: AppTheme.accentColor,
                                ),
                                const Expanded(
                                  child: Text("J'accepte les termes et conditions", style: AppTheme.textStyle),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTapDown: (_) => setState(() => _isButtonPressed = true),
                              onTapUp: (_) => setState(() => _isButtonPressed = false),
                              onTapCancel: () => setState(() => _isButtonPressed = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                transform: Matrix4.identity()..scale(_isButtonPressed ? 0.98 : 1.0),
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signup,
                                  child: _isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text("S'inscrire"),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: () => Get.toNamed("/login"),
                                child: const Text("Déjà un compte ? Se connecter", style: TextStyle(color: Colors.white70)),
                              ),
                            ),
                          ],
                        ),
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

  // Construit un champ de texte avec validation
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {String? Function(String?)? validator}) {
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
  Widget _buildPasswordField(TextEditingController controller, String label, {required bool isMain}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isMain ? !_isPasswordVisible : !_isConfirmPasswordVisible,
        style: AppTheme.textStyle,
        validator: (value) {
          if (value == null || value.isEmpty) return "Champ requis";
          if (isMain) {
            if (value.length < 8) return "Mot de passe doit contenir au moins 8 caractères";
            if (!RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$').hasMatch(value))
              return "Doit contenir un chiffre et un caractère spécial";
            return null;
          }
          if (value != _passwordController.text) return "Les mots de passe ne correspondent pas";
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.lock, color: AppTheme.accentColor),
          suffixIcon: IconButton(
            icon: Icon(
              isMain ? (_isPasswordVisible ? Icons.visibility : Icons.visibility_off)
                  : (_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
              color: Colors.white70,
            ),
            onPressed: () => setState(() {
              if (isMain) _isPasswordVisible = !_isPasswordVisible;
              else _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            }),
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

  // Construit un sélecteur de date
  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: _selectDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.1),
          ),
          child: Row(
            children: [
              const Icon(Icons.cake, color: AppTheme.accentColor),
              const SizedBox(width: 12),
              Text(
                _birthday == null ? "Date de naissance" : DateFormat('dd/MM/yyyy').format(_birthday!),
                style: AppTheme.textStyle.copyWith(color: _birthday == null ? Colors.white70 : Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
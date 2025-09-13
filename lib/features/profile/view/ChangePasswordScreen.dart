import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:hajz_sejours/core/routes/app_route.dart'; // Import AppRoutes

class ChangePasswordScreen extends StatefulWidget {
  final int clientId;

  const ChangePasswordScreen({super.key, required this.clientId});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppApi.baseUrl}/client/${widget.clientId}/changer-motdepasse'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ancienMotDePasse': _oldPasswordController.text,
          'nouveauMotDePasse': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Succès',
          'Mot de passe changé avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Show alert dialog and navigate to profile
        _showSuccessDialog();
      } else {
        Get.snackbar(
          'Erreur',
          'Échec du changement de mot de passe',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur réseau : $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    Get.defaultDialog(
      title: 'Succès',
      middleText: 'Votre mot de passe a été changé avec succès.',
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: Colors.amber,
      onConfirm: () {
        Get.back(); // Close the dialog
        Get.offNamed(
          AppRoutes.profile,
          arguments: {'clientId': widget.clientId},
        ); // Navigate to ProfilePage
      },
      barrierDismissible: false, // Prevent dismissing by tapping outside
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changer le mot de passe'),
        backgroundColor: const Color(0xFF0D2180),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Ancien mot de passe',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) =>
                value!.isEmpty ? 'Veuillez entrer l\'ancien mot de passe' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Veuillez entrer le nouveau mot de passe';
                  if (value.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le nouveau mot de passe',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Veuillez confirmer le mot de passe';
                  if (value != _newPasswordController.text) return 'Les mots de passe ne correspondent pas';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Changer le mot de passe',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
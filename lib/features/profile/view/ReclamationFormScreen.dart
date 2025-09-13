import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:hajz_sejours/core/routes/app_route.dart'; // Import AppRoutes

class ReclamationFormScreen extends StatefulWidget {
  final int clientId;

  const ReclamationFormScreen({super.key, required this.clientId});

  @override
  _ReclamationFormScreenState createState() => _ReclamationFormScreenState();
}

class _ReclamationFormScreenState extends State<ReclamationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitReclamation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppApi.baseUrl}/client/${widget.clientId}/reclamation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sujet': _subjectController.text,
          'description': _descriptionController.text,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Succès',
          'Réclamation envoyée avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Show alert dialog and navigate to profile
        _showSuccessDialog();
      } else {
        Get.snackbar(
          'Erreur',
          'Échec de l\'envoi de la réclamation',
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
      middleText: 'Votre réclamation a été envoyée avec succès.',
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
        title: const Text('Envoyer une réclamation'),
        backgroundColor: const Color(0xFF0D2180),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Sujet',
                  prefixIcon: Icon(Icons.subject),
                ),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer un sujet' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Veuillez entrer une description' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submitReclamation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Envoyer',
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
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
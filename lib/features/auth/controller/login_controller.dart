import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Contrôleur pour gérer les opérations de connexion
class LoginController {
  // Connecte un utilisateur via l'API
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final jsonBody = jsonEncode({'email': email, 'motDePass': password});
      Get.log('Login body: $jsonBody');

      var response = await http.post(
        Uri.parse(AppApi.loginUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );

      Get.log('Login response: ${response.statusCode}, ${response.body}');

      // Gère le succès
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        Get.log('Parsed response data: $data');

        if (data['role'] != null) {
          // Try different token field names
          final token = data['token'] ?? data['jwt'] ?? data['accessToken'];
          // Try different ID field names
          final clientId = data['id'] ?? data['userId'] ?? data['clientId'];

          // Save to shared_preferences if token or clientId is present
          if (token != null || clientId != null) {
            final prefs = await SharedPreferences.getInstance();
            if (token != null) {
              await prefs.setString('jwt_token', token);
              Get.log('Saved token: $token');
            } else {
              Get.log('Warning: No token found in response');
            }
            if (clientId != null) {
              await prefs.setInt('clientId', clientId);
              Get.log('Saved clientId: $clientId');
            } else {
              Get.log('Warning: No clientId found in response');
            }
          } else {
            Get.log('Missing token and clientId in response');
            return {
              'success': false,
              'message': 'Réponse du serveur incomplète: token ou ID manquant',
            };
          }

          return {
            'success': true,
            'data': data, // Contient role, username, nom, prenom, id, token, etc.
          };
        } else {
          return {
            'success': false,
            'message': 'Email ou mot de passe incorrect',
          };
        }
      }

      // Gère les erreurs
      try {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Erreur serveur: ${response.statusCode}',
        };
      } catch (e) {
        return {
          'success': false,
          'message': 'Erreur serveur: ${response.body}',
        };
      }
    } catch (e) {
      Get.log('Login error: $e');
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }
}
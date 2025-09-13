import 'package:flutter/foundation.dart';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:hajz_sejours/features/profile/model/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileController with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchClient(int clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(AppApi.getUserUrl(clientId)));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = UserModel.fromJson(data);
        print('Profile fetched with avatarId: ${_user?.avatarId}');
      } else {
        _errorMessage = 'Échec du chargement du profil';
      }
    } catch (e) {
      _errorMessage = 'Erreur : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateClient(int clientId, UserModel updatedUser) async {
    final url = AppApi.getUserUrl(clientId);
    print('Sending PUT request to: $url'); // Debug

    try {
      final response = await http.put( // Changé de POST à PUT
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(updatedUser.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        _errorMessage = 'Erreur serveur: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau: $e';
      return false;
    }
  }

  Future<bool> deleteClient(int clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse(AppApi.getUserUrl(clientId)),
      );
      if (response.statusCode == 204) {
        _user = null;
        print('Profile deleted successfully');
        return true;
      } else {
        _errorMessage = 'Échec de la suppression du profil';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur : $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

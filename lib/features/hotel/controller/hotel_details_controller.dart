import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hajz_sejours/core/app_api.dart';

class HotelDetailsController with ChangeNotifier {
  Map<String, dynamic>? _hotelDetails;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get hotelDetails => _hotelDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchHotelDetails(int hotelId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(AppApi.hotelDetailsUrl(hotelId)),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _processHotelData(data);
      } else {
        _handleErrorResponse(response.statusCode, response.body);
      }
    } on SocketException {
      _errorMessage = "Pas de connexion Internet";
    } on TimeoutException {
      _errorMessage = "Le serveur ne répond pas";
    } on FormatException {
      _errorMessage = "Erreur de format des données";
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint(stackTrace.toString());
      _errorMessage = "Erreur inattendue";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _processHotelData(Map<String, dynamic> data) {
    try {
      _hotelDetails = {
        'id': data['id'],
        'nom': data['nom'] ?? 'Nom non disponible',
        'description': data['description'] ?? '',
        'adresse': data['adresse'] ?? '',
        'nombre_etoiles': data['nombre_etoiles'] ?? 0,
        'imageUrl': _ensureFullUrl(data['imageUrl']),
        'galleryUrls': _processGallery(data['galleryUrls']),
        'presentationsUrl': _ensureFullUrl(data['presentationsUrl']),
        'contact': {
          'telephone': data['telephone'] ?? '',
          'email': data['email'] ?? '',
          'whatsApp': data['whatsApp'] ?? '',
        },
        'services': {
          'parking': data['rooms']?.isNotEmpty ?? false ? 'Oui' : 'Non',
          'wifi': 'Gratuit',
          'piscine': data['nombre_etoiles'] >= 4 ? 'Oui' : 'Non',
        },
        'rooms': data['rooms'] ?? [],
      };
    } catch (e, stackTrace) {
      debugPrint('Error processing hotel data: $e');
      debugPrint(stackTrace.toString());
      _errorMessage = "Erreur de traitement des données";
    }
  }

  List<String> _processGallery(dynamic galleryData) {
    if (galleryData == null || !(galleryData is List)) return [];
    return (galleryData as List)
        .map((url) => _ensureFullUrl(url))
        .where((url) => url != null && url.isNotEmpty)
        .cast<String>()
        .toList();
  }

  String? _ensureFullUrl(dynamic url) {
    if (url == null || url.toString().isEmpty) return null;
    final urlStr = url.toString();
    if (urlStr.startsWith('http')) {
      return urlStr.replaceFirst('http://localhost:8081', AppApi.baseUrl);
    }
    return '${AppApi.baseUrl}/uploads/$urlStr';
  }

  void _handleErrorResponse(int statusCode, String body) {
    switch (statusCode) {
      case 404:
        _errorMessage = "Hôtel non trouvé";
        break;
      case 401:
        _errorMessage = "Authentification requise";
        break;
      case 500:
        _errorMessage = "Erreur serveur: ${_extractServerError(body)}";
        break;
      default:
        _errorMessage = "Erreur inconnue (code: $statusCode)";
    }
  }

  String _extractServerError(String body) {
    try {
      final json = jsonDecode(body);
      return json['message'] ?? json['error'] ?? body;
    } catch (e) {
      return body;
    }
  }
}
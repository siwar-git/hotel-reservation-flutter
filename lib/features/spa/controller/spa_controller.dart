import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';

class SpaController extends ChangeNotifier {
  Map<String, dynamic>? _spa;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get spa => _spa;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSpa(int hotelId) async {
    _isLoading = true;
    _errorMessage = null;
    _spa = null;
    notifyListeners();

    try {
      final uri = Uri.parse(AppApi.hotelSpaUrl(hotelId));
      print('Fetching spa from: $uri');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Spa response: $data');

        if (data.isNotEmpty) {
          final spaData = data.first;
          final imageUrl = _ensureFullUrl(spaData['imageUrl']?.toString());
          final presentationsUrl = _ensureFullUrl(spaData['presentationsUrl']?.toString());
          print('Processed image URL: $imageUrl');
          print('Processed presentations URL: $presentationsUrl');
          _spa = {
            'id': spaData['id'],
            'title': spaData['title']?.toString() ?? 'SPA HOTEL',
            'description': spaData['description']?.toString() ?? 'Aucune description disponible.',
            'image': imageUrl,
            'catalogue': presentationsUrl,
            'price': (spaData['price'] is num) ? spaData['price'].toDouble() : 0.0,
          };
        } else {
          throw Exception('Aucune donnée de spa trouvée pour cet hôtel.');
        }
      } else {
        print('Failed to fetch spa: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Erreur lors de la récupération du spa: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching spa: $e, StackTrace: ${StackTrace.current}');
      _errorMessage = 'Erreur lors de la récupération du spa: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _ensureFullUrl(dynamic url) {
    if (url == null || url.toString().isEmpty) {
      print('Invalid URL: $url');
      return null;
    }
    final urlStr = url.toString().trim();
    print('Processing URL: $urlStr');
    if (urlStr.contains('localhost:8081')) {
      return urlStr.replaceFirst('http://localhost:8081', AppApi.baseUrl);
    }
    if (urlStr.startsWith('/uploads/')) {
      return '${AppApi.baseUrl}${urlStr.substring(1)}';
    }
    if (!urlStr.startsWith('http')) {
      return '${AppApi.baseUrl}uploads/$urlStr';
    }
    return urlStr;
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';

class OffersController extends ChangeNotifier {
  List<Map<String, dynamic>> _offers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get offers => _offers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOffers(int hotelId) async {
    _isLoading = true;
    _errorMessage = null;
    _offers = [];
    notifyListeners();

    try {
      final uri = Uri.parse(AppApi.hotelOffersUrl(hotelId));
      print('Fetching offers from: $uri');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Offers response: $data');

        _offers = data.map((offer) {
          final imageUrl = _ensureFullUrl(offer['imageUrl']?.toString());
          final rawPrice = offer['price'];
          print('Raw price for ${offer['title']}: $rawPrice');
          double parsedPrice = 0.0;
          if (rawPrice != null) {
            if (rawPrice is num) {
              parsedPrice = rawPrice.toDouble();
            } else if (rawPrice is String) {
              parsedPrice = double.tryParse(rawPrice) ?? 0.0;
            }
          }
          print('Parsed price for ${offer['title']}: $parsedPrice');
          return {
            'id': offer['id'],
            'title': offer['title']?.toString() ?? 'Titre non disponible',
            'image': imageUrl,
            'description': offer['description']?.toString() ?? 'Description non disponible',
            'price': parsedPrice,
          };
        }).toList();
      } else {
        print('Failed to fetch offers: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Erreur lors de la récupération des offres: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching offers: $e, StackTrace: ${StackTrace.current}');
      _errorMessage = 'Erreur lors de la récupération des offres: $e';
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
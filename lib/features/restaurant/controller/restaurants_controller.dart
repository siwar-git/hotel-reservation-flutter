import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';

class RestaurantsController extends ChangeNotifier {
  List<Map<String, dynamic>> _restaurantsBars = [];
  List<String> _images = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get restaurantsBars => _restaurantsBars;
  List<String> get images => _images;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRestaurants(int hotelId) async {
    _isLoading = true;
    _errorMessage = null;
    _restaurantsBars = [];
    _images = [];
    notifyListeners();

    try {
      final uri = Uri.parse(AppApi.hotelRestaurantsUrl(hotelId));
      print('Fetching restaurants from: $uri');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Restaurants response: $data');

        _restaurantsBars = data.map((restaurant) {
          final iconMap = {
            'Restaurant principal': Icons.restaurant,
            'Restaurant à la carte': Icons.restaurant_menu,
            'Café': Icons.coffee,
            'Bar': Icons.local_bar,
            'Bar salon': Icons.sports_bar,
          };

          String name = restaurant['name'] ?? 'Nom non disponible';
          IconData? icon;
          for (var key in iconMap.keys) {
            if (name.toLowerCase().contains(key.toLowerCase())) {
              icon = iconMap[key];
              break;
            }
          }

          return {
            'id': restaurant['id'] ?? 0,
            'name': name,
            'icon': icon ?? Icons.restaurant,
            'description': restaurant['description'] ?? 'Non disponible',
            'imageUrls': _processGallery(restaurant['images'] ?? restaurant['imageUrls'] ?? restaurant['imagesUrls']),
          };
        }).toList();

        _images = _restaurantsBars
            .expand((restaurant) => restaurant['imageUrls'] as List<String>)
            .toList();

        if (_images.isEmpty) {
          print('No images found, using placeholder');
          _images = ['https://via.placeholder.com/200'];
        }

        print('Processed images: $_images');
      } else {
        print('Failed to fetch restaurants: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Erreur lors de la récupération des restaurants: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching restaurants: $e');
      _errorMessage = 'Erreur lors de la récupération des restaurants: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> _processGallery(dynamic galleryData) {
    if (galleryData == null || !(galleryData is List)) {
      print('Gallery data is null or not a list: $galleryData');
      return [];
    }
    return (galleryData as List)
        .map((url) => _ensureFullUrl(url))
        .where((url) => url != null && url.isNotEmpty)
        .cast<String>()
        .toList();
  }

  String? _ensureFullUrl(dynamic url) {
    if (url == null || url.toString().isEmpty) {
      print('Invalid URL: $url');
      return null;
    }
    final urlStr = url.toString();
    if (urlStr.startsWith('http')) {
      return urlStr.replaceFirst('http://localhost:8081', AppApi.baseUrl);
    }
    return '${AppApi.baseUrl}/Uploads/$urlStr';
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';

class ConferencesController extends ChangeNotifier {
  List<Map<String, dynamic>> _conferences = [];
  List<String> _images = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get conferences => _conferences;
  List<String> get images => _images;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchConferences(int hotelId) async {
    _isLoading = true;
    _errorMessage = null;
    _conferences = [];
    _images = [];
    notifyListeners();

    try {
      final uri = Uri.parse(AppApi.hotelConferencesUrl(hotelId));
      print('Fetching conferences from: $uri');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Conferences response: $data');

        _conferences = data.map((conference) {
          final images = _processGallery(conference['images'] ?? conference['imageUrls'] ?? conference['imagesUrls']);
          final presentationsUrl = _ensureFullUrl(conference['presentationsUrl']?.toString());
          print('Processed images for ${conference['title']}: $images');
          print('Processed presentations URL for ${conference['title']}: $presentationsUrl');
          return {
            'title': conference['title']?.toString() ?? 'Titre non disponible',
            'description': conference['description']?.toString() ?? 'Non disponible',
            'price': (conference['price'] is num) ? conference['price'].toDouble() : 0.0,
            'presentationsUrl': presentationsUrl ?? '',
            'icon': Icons.meeting_room,
            'imageUrls': images,
          };
        }).toList();

        _images = _conferences
            .expand((conference) => conference['imageUrls'] as List<String>)
            .toList();

        if (_images.isEmpty) {
          print('No images found, using placeholder');
          _images = ['https://via.placeholder.com/200'];
        }

        print('Total images: $_images');
      } else {
        print('Failed to fetch conferences: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Erreur lors de la récupération des conférences: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching conferences: $e, StackTrace: ${StackTrace.current}');
      _errorMessage = 'Erreur lors de la récupération des conférences: $e';
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
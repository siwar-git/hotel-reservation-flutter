import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';

class ServicesController extends ChangeNotifier {
  List<Map<String, dynamic>> _piscines = [];
  List<Map<String, dynamic>> _activitesSportives = [];
  List<Map<String, dynamic>> _fitnessSpa = [];
  List<Map<String, dynamic>> _kidsActivities = [];
  List<Map<String, dynamic>> _autresServices = [];
  List<Map<String, dynamic>> _equipements = [];

  List<String> _piscineImages = [];
  List<String> _activitesSportivesImages = [];
  List<String> _fitnessSpaImages = [];
  List<String> _kidsActivitiesImages = [];
  List<String> _autresServicesImages = [];
  List<String> _equipementsImages = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get piscines => _piscines;
  List<Map<String, dynamic>> get activitesSportives => _activitesSportives;
  List<Map<String, dynamic>> get fitnessSpa => _fitnessSpa;
  List<Map<String, dynamic>> get kidsActivities => _kidsActivities;
  List<Map<String, dynamic>> get autresServices => _autresServices;
  List<Map<String, dynamic>> get equipements => _equipements;

  List<String> get piscineImages => _piscineImages;
  List<String> get activitesSportivesImages => _activitesSportivesImages;
  List<String> get fitnessSpaImages => _fitnessSpaImages;
  List<String> get kidsActivitiesImages => _kidsActivitiesImages;
  List<String> get autresServicesImages => _autresServicesImages;
  List<String> get equipementsImages => _equipementsImages;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchServices(int hotelId) async {
    _isLoading = true;
    _errorMessage = null;
    _piscines = [];
    _activitesSportives = [];
    _fitnessSpa = [];
    _kidsActivities = [];
    _autresServices = [];
    _equipements = [];
    _piscineImages = [];
    _activitesSportivesImages = [];
    _fitnessSpaImages = [];
    _kidsActivitiesImages = [];
    _autresServicesImages = [];
    _equipementsImages = [];
    notifyListeners();

    try {
      final uri = Uri.parse(AppApi.hotelServicesUrl(hotelId));
      print('Fetching services from: $uri');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Services response: $data');

        for (var service in data) {
          final title = service['title']?.toLowerCase() ?? '';
          final description = service['description'] ?? '';
          // Gérer details comme chaîne ou liste
          List<String> details = [];
          if (service['details'] is List) {
            details = (service['details'] as List<dynamic>).cast<String>();
          } else if (service['details'] is String) {
            String detailsStr = service['details'];
            // Supprimer les crochets et nettoyer
            detailsStr = detailsStr.replaceAll(RegExp(r'[\[\]]'), '').trim();
            if (detailsStr.isNotEmpty) {
              details = [detailsStr];
            }
          }
          print('Parsed details for ${service['title']}: $details');

          final images = _processGallery(service['images'] ?? service['imageUrls'] ?? service['imagesUrls']);
          print('Processed images for ${service['title']}: $images');

          final iconMap = {
            'piscine': Icons.pool,
            'activit': Icons.sports_soccer,
            'fitness': Icons.fitness_center,
            'spa': Icons.fitness_center,
            'kids': Icons.child_friendly,
            'autres': Icons.room_service,
            'quipement': Icons.hotel,
          };

          IconData? icon;
          for (var key in iconMap.keys) {
            if (title.contains(key)) {
              icon = iconMap[key];
              break;
            }
          }

          final serviceMap = {
            'title': service['title'] ?? 'Titre non disponible',
            'description': description,
            'details': details,
            'icon': icon ?? Icons.room_service,
          };

          if (title.contains('piscine')) {
            _piscines.add(serviceMap);
            _piscineImages.addAll(images);
          } else if (title.contains('activit')) {
            _activitesSportives.add(serviceMap);
            _activitesSportivesImages.addAll(images);
          } else if (title.contains('fitness') || title.contains('spa')) {
            _fitnessSpa.add(serviceMap);
            _fitnessSpaImages.addAll(images);
          } else if (title.contains('kids')) {
            _kidsActivities.add(serviceMap);
            _kidsActivitiesImages.addAll(images);
          } else if (title.contains('autres')) {
            _autresServices.add(serviceMap);
            _autresServicesImages.addAll(images);
          } else if (title.contains('quipement')) {
            _equipements.addAll((details).map((detail) => {
              'title': detail,
            }).toList());
            _equipementsImages.addAll(images);
          }
        }

        // Fallback images
        if (_piscineImages.isEmpty) _piscineImages = ['https://via.placeholder.com/200'];
        if (_activitesSportivesImages.isEmpty) _activitesSportivesImages = ['https://via.placeholder.com/200'];
        if (_fitnessSpaImages.isEmpty) _fitnessSpaImages = ['https://via.placeholder.com/200'];
        if (_kidsActivitiesImages.isEmpty) _kidsActivitiesImages = ['https://via.placeholder.com/200'];
        if (_autresServicesImages.isEmpty) _autresServicesImages = ['https://via.placeholder.com/200'];
        if (_equipementsImages.isEmpty) _equipementsImages = ['https://via.placeholder.com/200'];
      } else {
        print('Failed to fetch services: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Erreur lors de la récupération des services: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching services: $e, StackTrace: ${StackTrace.current}');
      _errorMessage = 'Erreur lors de la récupération des services: $e';
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
    return '${AppApi.baseUrl}uploads/$urlStr';
  }
}
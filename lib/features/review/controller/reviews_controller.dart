import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';

class ReviewsController extends ChangeNotifier {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchReviews(int hotelId) async {
    _isLoading = true;
    _errorMessage = null;
    _reviews = [];
    notifyListeners();

    try {
      final uri = Uri.parse(AppApi.hotelReviewsUrl(hotelId));
      print('Fetching reviews from: $uri');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Reviews response: $data');

        _reviews = data.map((review) {
          return {
            'id': review['id'],
            'rating': review['rating']?.toDouble() ?? 0.0,
            'name': review['name']?.toString() ?? 'Utilisateur Anonyme',
            'date': review['date']?.toString() ?? DateTime.now().toString().split(" ")[0],
            'review': review['review']?.toString() ?? 'Aucun commentaire.',
          };
        }).toList();
      } else {
        print('Failed to fetch reviews: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Erreur lors de la récupération des avis: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reviews: $e, StackTrace: ${StackTrace.current}');
      _errorMessage = 'Erreur lors de la récupération des avis: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
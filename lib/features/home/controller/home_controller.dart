import 'package:flutter/material.dart';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeController with ChangeNotifier {
  final int _clientId;
  bool isLoading = false;
  bool isHotelsLoading = false;
  bool isRoomsLoading = false;
  bool isServicesLoading = false;
  bool isRestaurantsLoading = false;
  bool isSpasLoading = false;
  bool isConferencesLoading = false;
  bool isReviewsLoading = false;
  bool isRecommendationsLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> personalizedRecommendations = [];
  List<Map<String, dynamic>> hotels = [];
  List<Map<String, dynamic>> recommendedRooms = [];
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> restaurants = [];
  List<Map<String, dynamic>> spas = [];
  List<Map<String, dynamic>> conferences = [];
  List<Map<String, dynamic>> customerReviews = [];

  final Set<String> _favorites = {};

  HomeController({required int clientId}) : _clientId = clientId {
    debugPrint('HomeController initialized with clientId: $clientId');
    loadFavorites();
  }

  int get clientId => _clientId;

  Future<void> fetchData() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        errorMessage = 'Aucune connexion Internet';
        isLoading = false;
        notifyListeners();
        return;
      }

      await Future.wait([
        _fetchPersonalizedRecommendations(),
        _fetchHotels(),
        _fetchRecommendedRooms(),
        _fetchServices(),
        _fetchRestaurants(),
        _fetchSpas(),
        _fetchConferences(),
        _fetchCustomerReviews(),
      ]);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Échec du chargement des données: $e';
      isLoading = false;
      notifyListeners();
      debugPrint('Erreur lors du chargement des données: $e');
    }
  }

  Future<void> _fetchPersonalizedRecommendations() async {
    isRecommendationsLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('${AppApi.recommendedHotelsUrl}?clientId=$clientId'));
      if (response.statusCode == 200) {
        final List<dynamic>? data = jsonDecode(response.body);
        if (data != null) {
          personalizedRecommendations = data.map((item) {
            final map = item as Map<String, dynamic>;
            return {
              'id': map['id'] ?? 0,
              'title': map['nom'] ?? map['title'] ?? 'Sans titre',
              'imageUrl': AppApi.getImageUrl(map['imageUrl']?.toString()),
              'type': 'hotel',
            };
          }).toList();
        } else {
          personalizedRecommendations = [];
        }
      } else {
        debugPrint('Erreur lors du chargement des recommandations: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des recommandations: $e');
    }

    isRecommendationsLoading = false;
    notifyListeners();
  }

  Future<void> _fetchHotels() async {
    isHotelsLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(AppApi.hotelsListUrl));
      if (response.statusCode == 200) {
        final List<dynamic>? data = jsonDecode(response.body);
        if (data != null) {
          hotels = data.map((item) {
            final map = item as Map<String, dynamic>;
            return {
              'id': map['id'] ?? 0,
              'nom': map['nom'] ?? 'Hôtel sans nom',
              'imageUrl': AppApi.getImageUrl(map['imageUrl']?.toString()),
              'nombre_etoiles': map['nombre_etoiles'] ?? 0,
              'isSpecialOffer': map['isSpecialOffer'] ?? false,
              'isNew': map['isNew'] ?? false,
            };
          }).toList();
        } else {
          hotels = [];
        }
      } else {
        debugPrint('Erreur lors du chargement des hôtels: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des hôtels: $e');
    }

    isHotelsLoading = false;
    notifyListeners();
  }

  Future<void> _fetchRecommendedRooms() async {
    isRoomsLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(AppApi.roomsListUrl));
      if (response.statusCode == 200) {
        final List<dynamic>? data = jsonDecode(response.body);
        if (data != null) {
          recommendedRooms = data.map((item) {
            final map = item as Map<String, dynamic>;
            return {
              'id': map['id'] ?? 0,
              'type': map['type'] ?? 'Chambre',
              'imageUrl': AppApi.getImageUrl(map['imageUrl']?.toString()),
              'price': map['price']?.toString() ?? 'Prix indisponible',
            };
          }).toList();
        } else {
          recommendedRooms = [];
        }
      } else {
        debugPrint('Erreur lors du chargement des chambres: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des chambres: $e');
    }

    isRoomsLoading = false;
    notifyListeners();
  }

  Future<void> _fetchServices() async {
    isServicesLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(AppApi.servicesListUrl));
      if (response.statusCode == 200) {
        final List<dynamic>? data = jsonDecode(response.body);
        if (data != null) {
          services = data.map((item) {
            final map = item as Map<String, dynamic>;
            return {
              'id': map['id'] ?? 0,
              'title': map['title'] ?? 'Service',
              'imageUrl': AppApi.getImageUrl(map['imageUrl']?.toString()),
              'description': map['description'] ?? 'Description indisponible',
            };
          }).toList();
        } else {
          services = [];
        }
      } else {
        debugPrint('Erreur lors du chargement des services: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des services: $e');
    }

    isServicesLoading = false;
    notifyListeners();
  }

  Future<void> _fetchRestaurants() async {
    isRestaurantsLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(AppApi.restaurantsListUrl));
      if (response.statusCode == 200) {
        final List<dynamic>? data = jsonDecode(response.body);
        if (data != null) {
          restaurants = data.map((item) {
            final map = item as Map<String, dynamic>;
            return {
              'id': map['id'] ?? 0,
              'name': map['name'] ?? 'Restaurant',
              'imageUrl': AppApi.getImageUrl(map['imageUrl']?.toString()),
              'price': map['price']?.toString() ?? 'Prix indisponible',
            };
          }).toList();
        } else {
          restaurants = [];
        }
      } else {
        debugPrint('Erreur lors du chargement des restaurants: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des restaurants: $e');
    }

    isRestaurantsLoading = false;
    notifyListeners();
  }

  Future<void> _fetchSpas() async {
    isSpasLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(AppApi.spasListUrl));
      if (response.statusCode == 200) {
        final List<dynamic>? data = jsonDecode(response.body);
        if (data != null) {
          spas = data.map((item) {
            final map = item as Map<String, dynamic>;
            return {
              'id': map['id'] ?? 0,
              'title': map['title'] ?? 'Spa',
              'imageUrl': AppApi.getImageUrl(map['imageUrl']?.toString()),
              'price': map['price']?.toString() ?? 'Prix indisponible',
            };
          }).toList();
        } else {
          spas = [];
        }
      } else {
        debugPrint('Erreur lors du chargement des spas: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des spas: $e');
    }

    isSpasLoading = false;
    notifyListeners();
  }

  Future<void> _fetchConferences() async {
    isConferencesLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(AppApi.conferencesListUrl));
      if (response.statusCode == 200) {
        final List<dynamic>? data = jsonDecode(response.body);
        if (data != null) {
          conferences = data.map((item) {
            final map = item as Map<String, dynamic>;
            return {
              'id': map['id'] ?? 0,
              'title': map['title'] ?? 'Conférence',
              'imageUrl': AppApi.getImageUrl(map['imageUrl']?.toString()),
              'price': map['price']?.toString() ?? 'Prix indisponible',
            };
          }).toList();
        } else {
          conferences = [];
        }
      } else {
        debugPrint('Erreur lors du chargement des conférences: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des conférences: $e');
    }

    isConferencesLoading = false;
    notifyListeners();
  }

  Future<void> _fetchCustomerReviews() async {
    isReviewsLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(AppApi.reviewsListUrl));
      if (response.statusCode == 200) {
        final List<dynamic>? data = jsonDecode(response.body);
        if (data != null) {
          customerReviews = data.map((item) {
            final map = item as Map<String, dynamic>;
            return {
              'id': map['id'] ?? 0,
              'rating': map['rating'] ?? 0,
              'review': map['review'] ?? 'Aucun commentaire',
              'date': map['date'] ?? '',
              'name': map['name'] ?? 'Inconnu',
            };
          }).toList();
        } else {
          customerReviews = [];
        }
      } else {
        debugPrint('Erreur lors du chargement des avis: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des avis: $e');
    }

    isReviewsLoading = false;
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    try {
      final box = await Hive.openBox<String>('favorites');
      _favorites.clear();
      _favorites.addAll(box.values);
      notifyListeners();
      debugPrint('Favoris chargés: $_favorites');
    } catch (e) {
      debugPrint('Erreur lors du chargement des favoris: $e');
      // Optionally notify user of failure
      errorMessage = 'Erreur lors du chargement des favoris';
      notifyListeners();
    }
  }

  bool isFavorite(String id) {
    return _favorites.contains(id);
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final box = await Hive.openBox<String>('favorites');
      if (_favorites.contains(id)) {
        _favorites.remove(id);
        await box.delete(id);
      } else {
        _favorites.add(id);
        await box.put(id, id);
      }
      notifyListeners();
      debugPrint('Favori modifié: $id, Favoris: $_favorites');
    } catch (e) {
      debugPrint('Erreur lors de la modification des favoris: $e');
      errorMessage = 'Erreur lors de la gestion des favoris';
      notifyListeners();
    }
  }
}
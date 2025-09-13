import 'package:get/get.dart';

class AppApi {
  // Configuration de base
  static const String baseUrl = "http://192.168.1.103:8081"; // À modifier pour la production
  static const String uploadsPath = "/Uploads";

  // Authentification
  static String get registerUrl => "$baseUrl/auth/inscription";
  static String get loginUrl => "$baseUrl/auth/login";
  static String get sendVerificationUrl => "$baseUrl/api/verification/send";
  static String get verifyUrl => "$baseUrl/api/verification/verify";
  static String get resetPasswordUrl => "$baseUrl/auth/reset-password";

  // Utilisateurs
  static String getUserUrl(int userId) => "$baseUrl/client/$userId";

  // Images
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Retourner une chaîne vide pour laisser CachedNetworkImage gérer l'erreur
    }
    if (imagePath.startsWith('http')) {
      return imagePath.replaceFirst('http://localhost:8081', baseUrl);
    }
    final cleanPath = imagePath.replaceAll(RegExp(r'^\/+'), '');
    return '$baseUrl$uploadsPath/$cleanPath';
  }

  // Endpoints
  static String hotelDetailsUrl(int id) => "$baseUrl/Hotel/$id";
  static String get recommendedHotelsUrl => "$baseUrl/Hotel/recommended";
  static String roomDetailsUrl(int id) => "$baseUrl/Room/$id";
  static String hotelRoomsUrl(int hotelId) => "$baseUrl/Room/hotel/$hotelId";
  static String hotelRestaurantsUrl(int hotelId) => '$baseUrl/Restaurant/hotel/$hotelId';
  static String hotelServicesUrl(int hotelId) => '$baseUrl/Serv/hotel/$hotelId';
  static String hotelConferencesUrl(int hotelId) => '$baseUrl/Conference/hotel/$hotelId';
  static String hotelSpaUrl(int hotelId) => '$baseUrl/Spa/hotel/$hotelId';
  static String hotelOffersUrl(int hotelId) => '$baseUrl/Offer/hotel/$hotelId';
  static String hotelReviewsUrl(int hotelId) => '$baseUrl/Review/hotel/$hotelId';
  static String addReviewUrl(int hotelId) => "$baseUrl/Review/addReview/$hotelId";
  static const String hotelsListUrl = '$baseUrl/Hotel/HotelsList';
  static const String roomsListUrl = '$baseUrl/Room/RoomsList';
  static const String servicesListUrl = '$baseUrl/Serv/ServsList';
  static const String restaurantsListUrl = '$baseUrl/Restaurant/RestaurantsList';
  static const String offersListUrl = '$baseUrl/Offer/OffersList';
  static const String spasListUrl = '$baseUrl/Spa/SpasList';
  static const String conferencesListUrl = '$baseUrl/Conference/ConferencesList';
  static const String reviewsListUrl = '$baseUrl/Review/ReviewsList';
  static const String reservationRoomsUrl = '$baseUrl/api/reservations/rooms';
  static const String searchUrl = '$baseUrl/search';
  static const String actualitesUrl = '$baseUrl/actualites';
}
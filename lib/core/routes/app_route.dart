import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajz_sejours/features/Actualites/view/actualites_page.dart';
import 'package:hajz_sejours/features/hotel/view/hotel_details_screen.dart';
import 'package:hajz_sejours/features/profile/view/ChangePasswordScreen.dart';
import 'package:hajz_sejours/features/profile/view/ReclamationFormScreen.dart';
import 'package:hajz_sejours/features/profile/view/ReservationHistoryScreen.dart';
import 'package:hajz_sejours/features/room/view/room_details_screen.dart';
import 'package:hajz_sejours/features/search/view/search_screen.dart';
import 'package:hajz_sejours/features/splash/view/splash_screen.dart';
import 'package:hajz_sejours/features/auth/view/signup_screen.dart';
import 'package:hajz_sejours/features/auth/view/verification_code_screen.dart';
import 'package:hajz_sejours/features/auth/view/login_screen.dart';
import 'package:hajz_sejours/features/auth/view/forgotPassword_screen.dart';
import 'package:hajz_sejours/features/auth/view/reset_password_verification_screen.dart';
import 'package:hajz_sejours/features/home/view/home_screen.dart';
import 'package:hajz_sejours/features/home/view/full_list_screen.dart';
import 'package:hajz_sejours/features/chatbot/view/chatbot_screen.dart';
import 'package:hajz_sejours/features/notification/view/notifications_screen.dart';
import 'package:hajz_sejours/features/payment/view/paiement.dart';
import 'package:hajz_sejours/features/room/view/rooms_screen.dart';
import 'package:hajz_sejours/features/offer/view/offers_screen.dart';
import 'package:hajz_sejours/features/restaurant/view/restaurants_screen.dart';
import 'package:hajz_sejours/features/service/view/services_screen.dart';
import 'package:hajz_sejours/features/spa/view/spa_screen.dart';
import 'package:hajz_sejours/features/conference/view/conferences_screen.dart';
import 'package:hajz_sejours/features/review/view/reviews_screen.dart';
import 'package:hajz_sejours/features/profile/view/profil_screen.dart';

// Placeholder for ReservationDetailsScreen
class ReservationDetailsScreen extends StatelessWidget {
  final int? notificationId;
  final int clientId;

  const ReservationDetailsScreen({
    Key? key,
    this.notificationId,
    required this.clientId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('ReservationDetailsScreen: notificationId=$notificationId, clientId=$clientId');
    return Scaffold(
      appBar: AppBar(title: const Text('Détails de la réservation')),
      body: Center(
        child: Text('Notification ID: $notificationId, Client ID: $clientId'),
      ),
    );
  }
}

class AppRoutes {
  static const splash = '/';
  static const signup = '/signup';
  static const verify = '/verify';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const resetPasswordVerify = '/reset-password-verify';
  static const home = '/home';
  static const chatbot = '/chatbot';
  static const Actualites = '/Actualites';
  static const notifications = '/notifications';
  static const reclamation = '/reclamation';
  static const payment = '/payment';
  static const hotelDetails = '/hotel-details';
  static const rooms = '/rooms';
  static const roomDetails = '/room-details';
  static const offers = '/offers';
  static const restaurants = '/restaurants';
  static const services = '/services';
  static const spa = '/spa';
  static const conferences = '/conferences';
  static const avis = '/avis';
  static const profile = '/profile';
  static const fullList = '/full-list';
  static const serviceDetails = '/service-details';
  static const restaurantDetails = '/restaurant-details';
  static const spaDetails = '/spa-details';
  static const conferenceDetails = '/conference-details';
  static const searchResults = '/search-results';
  static const reservationDetails = '/reservation-details';
  static const String changePassword = '/change-password';
  static const String reservationHistory = '/reservation-history';
  static const String reclamationForm = '/reclamation-form';

}

class AppPages {
  static Map<String, dynamic>? _normalizeArguments(dynamic args) {
    if (args == null) return null;
    if (args is Map<String, dynamic>) return args;
    if (args is Map) {
      return args.map((key, value) => MapEntry(key.toString(), value));
    }
    Get.log('Invalid arguments type: ${args.runtimeType}', isError: true);
    return null;
  }

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => WelcomeScreen()),
    GetPage(name: AppRoutes.signup, page: () => SignupScreen()),
    GetPage(
      name: AppRoutes.verify,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('email') || !args.containsKey('formData')) {
          return _errorScreen('Arguments invalides pour /verify');
        }
        return VerificationCodeScreen(
          email: args['email'] as String,
          formData: args['formData'] as Map<String, dynamic>,
        );
      },
    ),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(
      name: AppRoutes.resetPasswordVerify,
      page: () {
        final email = Get.arguments as String?;
        if (email == null) {
          return _errorScreen('Argument email manquant pour /reset-password-verify');
        }
        return ResetPasswordVerificationScreen(email: email);
      },
    ),
    GetPage(
      name: AppRoutes.home,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        Get.log('HomeScreen args: $args');
        if (args == null || !args.containsKey('clientId')) {
          return _errorScreen('Argument clientId manquant pour /home');
        }
        final clientId = args['clientId'] is int
            ? args['clientId']
            : int.tryParse(args['clientId'].toString());
        if (clientId == null || clientId <= 0) {
          return _errorScreen('Format clientId invalide pour /home');
        }
        return HomeScreen(clientId: clientId);
      },
    ),
    GetPage(
      name: AppRoutes.chatbot,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('clientId')) {
          return _errorScreen('Argument clientId manquant pour /chatbot');
        }
        final clientId = args['clientId'] is int
            ? args['clientId']
            : int.tryParse(args['clientId']?.toString() ?? '0') ?? 0;
        if (clientId == 0) {
          return _errorScreen('clientId invalide pour /chatbot');
        }
        return ChatbotPage(clientId: clientId);
      },
    ),
    GetPage(
      name: AppRoutes.Actualites,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('clientId')) {
          return _errorScreen('Argument clientId manquant pour /About');
        }
        final clientId = args['clientId'] is int
            ? args['clientId']
            : int.tryParse(args['clientId']?.toString() ?? '0') ?? 0;
        if (clientId == 0) {
          return _errorScreen('clientId invalide pour /About');
        }
        return ActualitesPage(clientId: clientId);
      },
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('clientId')) {
          return _errorScreen('Argument clientId manquant pour /notifications');
        }
        final clientId = args['clientId'] is int
            ? args['clientId']
            : int.tryParse(args['clientId']?.toString() ?? '0') ?? 0;
        if (clientId == 0) {
          return _errorScreen('clientId invalide pour /notifications');
        }
        return NotificationsPage(clientId: clientId);
      },
    ),
    GetPage(
      name: AppRoutes.payment,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('sessionUrl')) {
          return _errorScreen('Argument sessionUrl manquant pour /payment');
        }
        return PaymentPage(sessionUrl: args['sessionUrl'] as String);
      },
    ),
    GetPage(
      name: AppRoutes.hotelDetails,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('hotelId') || !args.containsKey('clientId')) {
          return _errorScreen('Arguments hotelId ou clientId manquants pour /hotel-details');
        }
        return HotelDetailsScreen(
          hotelId: args['hotelId'] is int
              ? args['hotelId']
              : int.tryParse(args['hotelId']?.toString() ?? '0') ?? 0,
          clientId: args['clientId'] is int
              ? args['clientId']
              : int.tryParse(args['clientId']?.toString() ?? '0') ?? 0,
        );
      },
    ),
    GetPage(
      name: AppRoutes.rooms,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('hotelId') || !args.containsKey('clientId')) {
          return _errorScreen('Arguments hotelId ou clientId manquants pour /rooms');
        }
        return RoomsScreen(
          hotelId: args['hotelId'] is int ? args['hotelId'] : int.tryParse(args['hotelId']?.toString() ?? '0') ?? 0,
          clientId: args['clientId'] is int ? args['clientId'] : int.tryParse(args['clientId']?.toString() ?? '0') ?? 0,
        );
      },
    ),
    GetPage(
      name: AppRoutes.roomDetails,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('roomId') || !args.containsKey('clientId')) {
          return _errorScreen('Arguments manquants pour /room-details');
        }
        return RoomDetailsScreen(
          roomId: args['roomId'] is int ? args['roomId'] : int.tryParse(args['roomId']?.toString() ?? '0') ?? 0,
          clientId: args['clientId'] is int ? args['clientId'] : int.tryParse(args['clientId']?.toString() ?? '0') ?? 0,
        );
      },
    ),
    GetPage(
      name: AppRoutes.offers,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('hotelId')) {
          return _errorScreen('Argument hotelId manquant pour /offers');
        }
        return OffersScreen(hotelId: args['hotelId']);
      },
    ),
    GetPage(
      name: AppRoutes.restaurants,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('hotelId')) {
          return _errorScreen('Argument hotelId manquant pour /restaurants');
        }
        return RestaurantsScreen(hotelId: args['hotelId']);
      },
    ),
    GetPage(
      name: AppRoutes.services,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('hotelId')) {
          return _errorScreen('Argument hotelId manquant pour /services');
        }
        return ServicesScreen(hotelId: args['hotelId']);
      },
    ),
    GetPage(
      name: AppRoutes.spa,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('hotelId')) {
          return _errorScreen('Argument hotelId manquant pour /spa');
        }
        return SpaScreen(hotelId: args['hotelId']);
      },
    ),
    GetPage(
      name: AppRoutes.conferences,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('hotelId')) {
          return _errorScreen('Argument hotelId manquant pour /conferences');
        }
        return ConferencesScreen(hotelId: args['hotelId']);
      },
    ),
    GetPage(
      name: AppRoutes.avis,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        if (args == null || !args.containsKey('hotelId') || !args.containsKey('clientId')) {
          return _errorScreen('Arguments hotelId ou clientId manquants pour /avis');
        }
        return ReviewsScreen(
          hotelId: args['hotelId'] is int ? args['hotelId'] : int.tryParse(args['hotelId']?.toString() ?? '0') ?? 0,
          clientId: args['clientId'] is int ? args['clientId'] : int.tryParse(args['clientId']?.toString() ?? '0') ?? 0,
        );
      },
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        final clientId = args?['clientId'] is int
            ? args!['clientId'] as int
            : int.tryParse(args?['clientId']?.toString() ?? '0') ?? 0;
        return ProfilePage(clientId: clientId);
      },
    ),
    GetPage(
      name: AppRoutes.fullList,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        return FullListScreen(
          title: args?['title']?.toString() ?? 'Liste',
          items: args?['items']?.cast<Map<String, dynamic>>() ?? [],
          routeName: args?['routeName']?.toString() ?? '/',
          clientId: args?['clientId'] is int ? args!['clientId'] : int.tryParse(args?['clientId']?.toString() ?? '0') ?? 0,
        );
      },
    ),
    GetPage(
      name: AppRoutes.reservationDetails,
      page: () {
        final args = _normalizeArguments(Get.arguments);
        final notificationId = args?['notificationId'] is int
            ? args!['notificationId']
            : int.tryParse(args?['notificationId']?.toString() ?? '0') ?? 0;
        final clientId = args?['clientId'] is int
            ? args!['clientId']
            : int.tryParse(args?['clientId']?.toString() ?? '0') ?? 0;
        return ReservationDetailsScreen(
          notificationId: notificationId,
          clientId: clientId,
        );
      },
    ),
    GetPage(
      name: AppRoutes.searchResults,
      page: () => const SearchScreen(),
    ),
    GetPage(
      name: AppRoutes.changePassword, // Changé de changePassword à AppRoutes.changePassword
      page: () {
        final args = _normalizeArguments(Get.arguments);
        final clientId = args?['clientId'] is int
            ? args!['clientId'] as int
            : int.tryParse(args?['clientId']?.toString() ?? '0') ?? 0;
        if (clientId == 0) {
          return _errorScreen('clientId invalide pour /change-password');
        }
        return ChangePasswordScreen(clientId: clientId);
      },
    ),
    GetPage(
      name: AppRoutes.reservationHistory, // Changé de reservationHistory à AppRoutes.reservationHistory
      page: () {
        final args = _normalizeArguments(Get.arguments);
        final clientId = args?['clientId'] is int
            ? args!['clientId'] as int
            : int.tryParse(args?['clientId']?.toString() ?? '0') ?? 0;
        if (clientId == 0) {
          return _errorScreen('clientId invalide pour /reservation-history');
        }
        return ReservationHistoryScreen(clientId: clientId);
      },
    ),
    GetPage(
      name: AppRoutes.reclamationForm, // Changé de reclamationForm à AppRoutes.reclamationForm
      page: () {
        final args = _normalizeArguments(Get.arguments);
        final clientId = args?['clientId'] is int
            ? args!['clientId'] as int
            : int.tryParse(args?['clientId']?.toString() ?? '0') ?? 0;
        if (clientId == 0) {
          return _errorScreen('clientId invalide pour /reclamation-form');
        }
        return ReclamationFormScreen(clientId: clientId);
      },
    ),
  ];

  static Widget _errorScreen(String message) {
    debugPrint('ErrorScreen displayed: $message');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Erreur: $message',
              style: const TextStyle(fontSize: 18, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                debugPrint('Redirecting to login from error screen');
                Get.offNamed(AppRoutes.login);
              },
              child: const Text('Retour à la connexion'),
            ),
            ElevatedButton(
              onPressed: () {
                debugPrint('Retrying navigation');
                Get.back();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
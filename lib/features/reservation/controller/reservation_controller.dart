import 'package:get/get.dart';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:hajz_sejours/core/routes/app_route.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ReservationController extends GetxController {
  var isLoading = false.obs;
  var originalPrice = 0.0.obs;
  var discountedPrice = 0.0.obs;
  var hasDiscount = false.obs;
  var clientPoints = 0.obs;
  var totalNights = 0.obs;
  var discountedNights = 0.obs;
  var pointsUsed = 0.obs;

  Future<void> fetchClientData(int clientId, Map<String, dynamic> roomData) async {
    try {
      isLoading.value = true;
      // Validate inputs
      if (clientId <= 0 || roomData['id'] == null) {
        Get.snackbar('Erreur', 'ID client ou chambre invalide');
        Get.log('Invalid clientId=$clientId or roomId=${roomData['id']}', isError: true);
        return;
      }

      // Fetch client data
      final clientUri = Uri.parse('${AppApi.baseUrl}/client/$clientId');
      final clientResponse = await http.get(
        clientUri,
        headers: {'Content-Type': 'application/json'},
      );
      if (clientResponse.statusCode == 200) {
        final data = jsonDecode(clientResponse.body);
        clientPoints.value = (data['point'] as num?)?.toInt() ?? 0;
        Get.log('Client points: ${clientPoints.value}');
      } else {
        Get.snackbar('Erreur', 'Échec de la récupération des données client: ${clientResponse.statusCode}');
        Get.log('Client fetch error: ${clientResponse.statusCode} ${clientResponse.body}', isError: true);
      }

      // Fetch room data
      final roomUri = Uri.parse('${AppApi.baseUrl}/Room/${roomData['id']}');
      final roomResponse = await http.get(
        roomUri,
        headers: {'Content-Type': 'application/json'},
      );
      if (roomResponse.statusCode == 200) {
        final room = jsonDecode(roomResponse.body);
        originalPrice.value = (room['price'] as num?)?.toDouble() ?? 0.0;
        discountedPrice.value = originalPrice.value;
        Get.log('Room price fetched: ${originalPrice.value} for roomId=${roomData['id']}');
      } else {
        Get.snackbar('Erreur', 'Échec de la récupération des données de la chambre: ${roomResponse.statusCode}');
        Get.log('Room fetch error: ${roomResponse.statusCode} ${roomResponse.body}', isError: true);
        // Fallback to roomData['price']
        originalPrice.value = (roomData['price'] as num?)?.toDouble() ?? 0.0;
        discountedPrice.value = originalPrice.value;
        Get.log('Using fallback price from roomData: ${originalPrice.value}', isError: true);
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la récupération des données : $e');
      Get.log('Erreur API fetchClientData : $e', isError: true);
      // Fallback to roomData['price']
      originalPrice.value = (roomData['price'] as num?)?.toDouble() ?? 0.0;
      discountedPrice.value = originalPrice.value;
      Get.log('Using fallback price from roomData due to error: ${originalPrice.value}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void calculateTotalPrice(int nights, bool applyDiscount) {
    totalNights.value = nights;
    discountedNights.value = 0;
    pointsUsed.value = 0;
    hasDiscount.value = false;

    if (applyDiscount && clientPoints.value >= 50) {
      discountedNights.value = (clientPoints.value ~/ 50).clamp(0, nights);
      pointsUsed.value = discountedNights.value * 50;
      hasDiscount.value = discountedNights.value > 0;
    }

    final fullPriceNights = nights - discountedNights.value;
    final discountedNightPrice = originalPrice.value * 0.7;
    discountedPrice.value = double.parse(
      ((fullPriceNights * originalPrice.value) + (discountedNights.value * discountedNightPrice)).toStringAsFixed(2),
    );
    Get.log('Price calculation: nights=$nights, discountedNights=${discountedNights.value}, pointsUsed=${pointsUsed.value}, totalPrice=${discountedPrice.value}');
  }

  Future<void> reserverEtPayerRoom({
    required int clientId,
    required int roomId,
    required double totalPrice,
    required bool applyDiscount,
    required int discountedNights,
    required int pointsUsed,
    required DateTime checkInDate,
    required DateTime checkOutDate,
  }) async {
    try {
      isLoading.value = true;

      // Validate inputs
      if (clientId <= 0 || roomId <= 0) {
        Get.snackbar('Erreur', 'ID client ou chambre invalide');
        Get.log('Invalid clientId=$clientId or roomId=$roomId', isError: true);
        return;
      }
      final now = DateTime.now();
      if (checkInDate.isBefore(now)) {
        Get.snackbar('Erreur', 'La date d\'arrivée doit être aujourd\'hui ou dans le futur');
        Get.log('Invalid checkInDate=$checkInDate, must be >= $now', isError: true);
        return;
      }
      if (checkOutDate.isBefore(checkInDate.add(const Duration(days: 1)))) {
        Get.snackbar('Erreur', 'La date de départ doit être au moins un jour après la date d\'arrivée');
        Get.log('Invalid dates: checkInDate=$checkInDate, checkOutDate=$checkOutDate', isError: true);
        return;
      }
      if (totalPrice <= 0) {
        Get.snackbar('Erreur', 'Prix total invalide');
        Get.log('Invalid totalPrice=$totalPrice', isError: true);
        return;
      }

      // Normalize dates to remove milliseconds
      final dateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');
      final checkInDateStr = dateFormat.format(checkInDate.copyWith(millisecond: 0, microsecond: 0));
      final checkOutDateStr = dateFormat.format(checkOutDate.copyWith(millisecond: 0, microsecond: 0));

      // Normalize totalPrice to 2 decimal places
      final normalizedTotalPrice = double.parse(totalPrice.toStringAsFixed(2));

      // Log all input parameters
      Get.log('Input parameters: clientId=$clientId, roomId=$roomId, applyDiscount=$applyDiscount, '
          'discountedNights=$discountedNights, pointsUsed=$pointsUsed, totalPrice=$normalizedTotalPrice, '
          'checkInDate=$checkInDateStr, checkOutDate=$checkOutDateStr');

      final body = jsonEncode({
        'clientId': clientId,
        'roomId': roomId,
        'applyDiscount': applyDiscount,
        'discountedNights': discountedNights,
        'pointsUsed': pointsUsed,
        'totalPrice': normalizedTotalPrice,
        'checkInDate': checkInDateStr,
        'checkOutDate': checkOutDateStr,
      });

      Get.log('Reservation URL: ${AppApi.reservationRoomsUrl}');
      Get.log('Sending reservation request: $body');

      final response = await http.post(
        Uri.parse(AppApi.reservationRoomsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      Get.log('Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sessionUrl = data['url'];
        if (sessionUrl != null && sessionUrl is String && sessionUrl.isNotEmpty) {
          Get.log('Navigating to PaymentPage with sessionUrl: $sessionUrl');
          Get.toNamed(
            AppRoutes.payment,
            arguments: {
              'sessionUrl': sessionUrl,
              'clientId': clientId,
              'totalPrice': normalizedTotalPrice,
            },
          );
        } else {
          Get.snackbar('Erreur', 'URL de paiement invalide ou manquante');
          Get.log('Invalid or missing sessionUrl: $sessionUrl', isError: true);
        }
      } else {
        String errorMessage = 'Échec de la création de la réservation';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? errorData['message'] ?? response.body;
        } catch (_) {
          errorMessage = 'Erreur serveur: ${response.statusCode} ${response.body}';
        }
        Get.snackbar('Erreur', errorMessage);
        Get.log('Reservation error: $errorMessage', isError: true);
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Une erreur est survenue : $e');
      Get.log('Erreur lors de la requête API : $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
import 'package:get/get.dart';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsController extends GetxController {
  var isLoading = false.obs;
  var notifications = <Map<String, dynamic>>[].obs;

  Future<void> fetchNotifications(int clientId) async {
    try {
      isLoading.value = true;
      final url = Uri.parse(
        '${AppApi.baseUrl}/api/notifications?clientId=$clientId',
      );
      Get.log('Fetching notifications for clientId=$clientId, URL=$url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      Get.log(
        'Notifications response: ${response.statusCode} ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        notifications.assignAll(
          data
              .map(
                (n) => {
                  'id': n['id'],
                  'titre': n['titre'],
                  'contenu': n['contenu'],
                  'date': DateTime.parse(n['date']),
                  'clientId': n['clientId'],
                },
              )
              .toList(),
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Échec de la récupération des notifications: ${response.statusCode}',
        );
        Get.log(
          'Fetch notifications error: ${response.statusCode} ${response.body}',
          isError: true,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la récupération des notifications : $e',
      );
      Get.log('Fetch notifications error: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      final url = Uri.parse(
        '${AppApi.baseUrl}/api/notifications/$notificationId',
      );
      Get.log('Deleting notification: id=$notificationId, URL=$url');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      Get.log(
        'Delete notification response: ${response.statusCode} ${response.body}',
      );

      if (response.statusCode == 200) {
        notifications.removeWhere((n) => n['id'] == notificationId);
      } else {
        Get.snackbar('Erreur', 'Échec de la suppression de la notification');
        Get.log(
          'Delete notification error: ${response.statusCode} ${response.body}',
          isError: true,
        );
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression : $e');
      Get.log('Delete notification error: $e', isError: true);
    }
  }
}

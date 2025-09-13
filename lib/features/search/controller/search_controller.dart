import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchController extends GetxController {
  var searchResults = <String, List<dynamic>>{}.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> search({
    String? query,
    String? category,
    String? minPrice,
    String? maxPrice,
    String? type,
    String? hotelName,
  }) async {
    try {
      isLoading(true);
      errorMessage.value = '';

      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) queryParams['query'] = query;
      if (category != null && category.isNotEmpty) queryParams['category'] = category.toLowerCase();
      if (minPrice != null && minPrice.isNotEmpty) queryParams['minPrice'] = minPrice;
      if (maxPrice != null && maxPrice.isNotEmpty) queryParams['maxPrice'] = maxPrice;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;
      if (hotelName != null && hotelName.isNotEmpty) queryParams['hotelName'] = hotelName;

      debugPrint('Search request: $queryParams');

      final uri = Uri.parse(AppApi.searchUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          searchResults.value = {
            'hotels': data['hotels']?.cast<Map<String, dynamic>>() ?? [],
            'rooms': data['rooms']?.cast<Map<String, dynamic>>() ?? [],
            'restaurants': data['restaurants']?.cast<Map<String, dynamic>>() ?? [],
            'services': data['services']?.cast<Map<String, dynamic>>() ?? [],
            'spas': data['spas']?.cast<Map<String, dynamic>>() ?? [],
            'conferences': data['conferences']?.cast<Map<String, dynamic>>() ?? [],
          };
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors de la recherche: $e';
      Get.snackbar(
        'Erreur de Recherche',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      debugPrint('Search error: $e');
    } finally {
      isLoading(false);
    }
  }

  void clearSearch() {
    searchResults.clear();
    errorMessage.value = '';
    isLoading(false);
  }
}
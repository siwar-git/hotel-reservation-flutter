import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:hajz_sejours/features/Actualites/model/actualite.dart';
import 'package:http/http.dart' as http;

class ActualitesService {
  static Future<List<Actualite>> fetchActualites() async {
    final response = await http.get(Uri.parse(AppApi.actualitesUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Actualite.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load actualites');
    }
  }
}

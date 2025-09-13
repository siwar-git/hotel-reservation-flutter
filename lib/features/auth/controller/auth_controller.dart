import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';

class AuthController extends GetxController {
Future<Map<String, dynamic>> register({
required String role,
required String nom,
required String prenom,
required String email,
required String motDePass,
required String localisation,
required String numTel,
required String username,
required String birthday,
required int point,
}) async {
try {
var request = http.MultipartRequest('POST', Uri.parse(AppApi.registerUrl));
request.headers['Accept'] = 'application/json';
request.fields['role'] = role;
request.fields['nom'] = nom;
request.fields['prenom'] = prenom;
request.fields['email'] = email;
request.fields['motDePass'] = motDePass;
request.fields['localisation'] = localisation;
request.fields['numTel'] = numTel;
request.fields['username'] = username;
request.fields['birthday'] = birthday; // Format: yyyy-MM-dd
request.fields['point'] = point.toString();
request.fields['imageUrl'] = ''; // Empty string for optional imageUrl

Get.log('Register request: URL=${AppApi.registerUrl}, Fields=${request.fields}');
final response = await request.send();
final responseBody = await response.stream.bytesToString();
Get.log('Register response: Status=${response.statusCode}, Headers=${response.headers}, Body=$responseBody');

if (response.statusCode == 200) {
final responseData = jsonDecode(responseBody);
return {
'success': responseData['success'] ?? true,
'message': responseData['message'] ?? 'Inscription réussie',
'clientId': responseData['clientId'].toString(),
};
} else {
final responseData = responseBody.isNotEmpty ? jsonDecode(responseBody) : {};
return {
'success': false,
'message': responseData['message'] ?? 'Erreur: ${response.statusCode} ${response.reasonPhrase}',
};
}
} catch (e) {
Get.log('Register error: $e', isError: true);
return {'success': false, 'message': 'Erreur réseau: $e'};
}
}
}
import 'package:hajz_sejours/core/app_api.dart';

class Actualite {
  final int id;
  final String titre;
  final String contenu;
  final String? imageUrl;

  Actualite({
    required this.id,
    required this.titre,
    required this.contenu,
    this.imageUrl,
  });

  factory Actualite.fromJson(Map<String, dynamic> json) {
    return Actualite(
      id: json['id'],
      titre: json['titre'],
      contenu: json['contenu'],
      imageUrl: AppApi.getImageUrl(json['imageUrl']),
    );
  }
}

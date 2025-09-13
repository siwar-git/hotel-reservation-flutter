import 'package:hajz_sejours/core/app_api.dart';

class Room {
  final int id;
  final String type;
  final List<String> imageUrls;
  final String capacite;
  final String surface;
  final List<String> videoAudio;
  final List<String> internetTelephonie;
  final List<String> electronique;
  final List<String> salleDeBain;
  final List<String> terrainExterieurVue;
  final List<String> lits;
  final List<String> meubles;
  final List<String> autres;
  final double price;
  final String description;

  Room({
    required this.id,
    required this.type,
    required this.imageUrls,
    required this.capacite,
    required this.surface,
    required this.videoAudio,
    required this.internetTelephonie,
    required this.electronique,
    required this.salleDeBain,
    required this.terrainExterieurVue,
    required this.lits,
    required this.meubles,
    required this.autres,
    required this.price,
    required this.description,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    final imageUrls = _processGallery(json['imagesUrls']);
    print('Processed image URLs: $imageUrls'); // Debug log
    return Room(
      id: json['id'] ?? 0,
      type: json['type']?.toString() ?? 'Type non disponible',
      imageUrls: imageUrls,
      capacite: json['capacite']?.toString() ?? 'Capacité non disponible',
      surface: json['surface']?.toString() ?? 'Surface non disponible',
      videoAudio: _ensureList(json['videoAudio']),
      internetTelephonie: _ensureList(json['internetTelephonie']),
      electronique: _ensureList(json['electronique']),
      salleDeBain: _ensureList(json['salleDeBain']),
      terrainExterieurVue: _ensureList(json['terrainExterieurVue']),
      lits: _ensureList(json['lits']),
      meubles: _ensureList(json['meubles']),
      autres: _ensureList(json['autres']),
      price: json['price']?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? 'Non disponible',
    );
  }

  static List<String> _processGallery(dynamic galleryData) {
    if (galleryData == null || !(galleryData is List)) {
      print('Gallery data is null or not a list: $galleryData');
      return [];
    }
    final urls = (galleryData as List)
        .map((url) => _ensureFullUrl(url))
        .where((url) => url != null && url.isNotEmpty)
        .cast<String>()
        .toList();
    if (urls.isEmpty) {
      print('No valid image URLs after processing: $galleryData');
    }
    return urls;
  }

  static String? _ensureFullUrl(dynamic url) {
    if (url == null || url.toString().isEmpty) {
      print('Invalid URL: $url');
      return null;
    }
    final urlStr = url.toString();
    // Handle relative URLs
    if (!urlStr.startsWith('http')) {
      return '${AppApi.baseUrl}/Uploads/$urlStr';
    }
    // Handle localhost for development
    if (urlStr.startsWith('http://localhost:8081')) {
      return urlStr.replaceFirst('http://localhost:8081', AppApi.baseUrl);
    }
    // Return absolute URLs as-is
    return urlStr;
  }

  static List<String> _ensureList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data.cast<String>();
    if (data is String && data.isNotEmpty) return data.split(',').map((e) => e.trim()).toList();
    return [data.toString()];
  }
}
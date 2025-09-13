import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:hajz_sejours/core/routes/app_route.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Map<String, List<dynamic>> searchResults = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSearchResults();
  }

  Future<void> _fetchSearchResults() async {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) {
      setState(() {
        errorMessage = 'Arguments manquants';
        isLoading = false;
      });
      return;
    }

    final query = args['query']?.toString() ?? '';
    final category = args['category']?.toString();
    final minPrice = args['minPrice']?.toString();
    final maxPrice = args['maxPrice']?.toString();
    final type = args['type']?.toString();
    final hotelName = args['hotelName']?.toString();
    final clientId = args['clientId'] is int
        ? args['clientId']
        : int.tryParse(args['clientId']?.toString() ?? '0') ?? 0;

    try {
      final uri = Uri.parse(AppApi.searchUrl).replace(queryParameters: {
        if (query.isNotEmpty) 'query': query,
        if (category != null) 'category': category.toLowerCase(),
        if (minPrice?.isNotEmpty ?? false) 'minPrice': minPrice!,
        if (maxPrice?.isNotEmpty ?? false) 'maxPrice': maxPrice!,
        if (type?.isNotEmpty ?? false) 'type': type!,
        if (hotelName?.isNotEmpty ?? false) 'hotelName': hotelName!,
      });

      debugPrint('Fetching search results from: $uri');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          searchResults = {
            'hotels': data['hotels'] ?? [],
            'rooms': data['rooms'] ?? [],
            'restaurants': data['restaurants'] ?? [],
            'services': data['services'] ?? [],
            'spas': data['spas'] ?? [],
            'conferences': data['conferences'] ?? [],
          };
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur lors de la récupération des résultats: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() {
        errorMessage = 'Erreur: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats de Recherche'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? _buildErrorScreen(context, errorMessage!)
          : searchResults.isEmpty || searchResults.values.every((list) => list.isEmpty)
          ? const Center(child: Text('Aucun résultat trouvé'))
          : _buildResultsList(context),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final clientId = args?['clientId'] is int
        ? args!['clientId']
        : int.tryParse(args?['clientId']?.toString() ?? '0') ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (searchResults['hotels']?.isNotEmpty ?? false) ...[
          _buildSectionHeader(context, 'Hôtels'),
          _buildHotelList(context, searchResults['hotels']!, clientId),
        ],
        if (searchResults['rooms']?.isNotEmpty ?? false) ...[
          _buildSectionHeader(context, 'Chambres'),
          _buildRoomList(context, searchResults['rooms']!, clientId),
        ],
        if (searchResults['restaurants']?.isNotEmpty ?? false) ...[
          _buildSectionHeader(context, 'Restaurants'),
          _buildRestaurantList(context, searchResults['restaurants']!, clientId),
        ],
        if (searchResults['services']?.isNotEmpty ?? false) ...[
          _buildSectionHeader(context, 'Services'),
          _buildServiceList(context, searchResults['services']!, clientId),
        ],
        if (searchResults['spas']?.isNotEmpty ?? false) ...[
          _buildSectionHeader(context, 'Spas'),
          _buildSpaList(context, searchResults['spas']!, clientId),
        ],
        if (searchResults['conferences']?.isNotEmpty ?? false) ...[
          _buildSectionHeader(context, 'Conférences'),
          _buildConferenceList(context, searchResults['conferences']!, clientId),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildHotelList(BuildContext context, List<dynamic> hotels, int clientId) {
    return Column(
      children: hotels.map((hotel) {
        return _buildItemCard(
          context,
          hotel,
          'nom',
          hotel['imageUrl'],
        );
      }).toList(),
    );
  }

  Widget _buildRoomList(BuildContext context, List<dynamic> rooms, int clientId) {
    return Column(
      children: rooms.map((room) {
        return _buildItemCard(
          context,
          room,
          'type',
          room['imageUrl'],
        );
      }).toList(),
    );
  }

  Widget _buildRestaurantList(BuildContext context, List<dynamic> restaurants, int clientId) {
    return Column(
      children: restaurants.map((restaurant) {
        return _buildItemCard(
          context,
          restaurant,
          'name',
          restaurant['imageUrl'],
        );
      }).toList(),
    );
  }

  Widget _buildServiceList(BuildContext context, List<dynamic> services, int clientId) {
    return Column(
      children: services.map((service) {
        return _buildItemCard(
          context,
          service,
          'title',
          service['imageUrl'],
        );
      }).toList(),
    );
  }

  Widget _buildSpaList(BuildContext context, List<dynamic> spas, int clientId) {
    return Column(
      children: spas.map((spa) {
        return _buildItemCard(
          context,
          spa,
          'title',
          spa['imageUrl'],
        );
      }).toList(),
    );
  }

  Widget _buildConferenceList(BuildContext context, List<dynamic> conferences, int clientId) {
    return Column(
      children: conferences.map((conference) {
        return _buildItemCard(
          context,
          conference,
          'title',
          conference['imageUrl'],
        );
      }).toList(),
    );
  }

  Widget _buildItemCard(
      BuildContext context,
      Map<String, dynamic> item,
      String titleKey,
      String? imageUrl,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildImage(context, AppApi.getImageUrl(imageUrl), alt: item[titleKey]),
        title: Text(item[titleKey] ?? 'Sans titre'),
        subtitle: item['price'] != null
            ? Text('${item['price']} €')
            : const Text('Prix indisponible'),
        // Removed onTap to make the item non-clickable
      ),
    );
  }

  Widget _buildImage(BuildContext context, String? imageUrl, {String? alt}) {
    return SizedBox(
      width: 50,
      height: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl == null || imageUrl.isEmpty
            ? Container(
          color: Theme.of(context).cardColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 20,
                color: Theme.of(context).hintColor,
              ),
              if (alt != null)
                Text(
                  alt,
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        )
            : FadeInImage(
          fit: BoxFit.cover,
          placeholder: const AssetImage('assets/placeholder.jpg'),
          image: NetworkImage(imageUrl),
          imageErrorBuilder: (context, error, stackTrace) {
            debugPrint('Image load error: $imageUrl, Error: $error');
            return Container(
              color: Theme.of(context).cardColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 20,
                    color: Theme.of(context).hintColor,
                  ),
                  if (alt != null)
                    Text(
                      alt,
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: Colors.red[300],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _fetchSearchResults,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Réessayer',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
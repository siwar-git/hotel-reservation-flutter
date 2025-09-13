import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajz_sejours/core/routes/app_route.dart';

class FullListScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String routeName;
  final int clientId;

  const FullListScreen({
    super.key,
    this.title = 'Liste',
    this.items = const [],
    this.routeName = '/',
    this.clientId = 0,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('FullListScreen: title=$title, items=${items.length}, routeName=$routeName, clientId=$clientId');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: items.isEmpty
          ? const Center(child: Text('Aucun élément disponible'))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildItemCard(context, items[index], routeName, clientId);
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Map<String, dynamic> item, String routeName, int clientId) {
    // Vérifiez si le routeName correspond à hotelDetails pour permettre la navigation
    final isHotelRoute = routeName == AppRoutes.hotelDetails;

    return GestureDetector(
      // Activez onTap uniquement pour les hôtels
      onTap: isHotelRoute
          ? () {
        debugPrint('Navigating to $routeName: id=${item['id']}');
        Get.toNamed(routeName, arguments: {
          '${routeName.split('-').first}Id': item['id'], // e.g., hotelId
          'clientId': clientId,
        });
      }
          : null, // Pas de navigation pour les autres types
      child: Card(
        elevation: 4,
        color: Color.fromRGBO(48, 39, 38, 0.32941176470588235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context, (item['imageUrl']), height: 160, alt: item['title'] ?? item['nom']),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item['title'] ?? item['nom'] ?? item['type'])?.toString() ?? 'Sans titre',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['price']?.toString() ?? 'Prix indisponible',
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String? imageUrl, {double? height, String? alt}) {
    debugPrint('FullListScreen Image URL: $imageUrl');
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: imageUrl == null || imageUrl.isEmpty
          ? Container(
        height: height,
        width: double.infinity,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported,
              size: 30,
              color: Colors.grey,
            ),
            if (alt != null)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  alt,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      )
          : CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: height,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          debugPrint('FullListScreen Image load error: $url, Error: $error');
          return Container(
            height: height,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_not_supported,
                  size: 30,
                  color: Colors.grey,
                ),
                if (alt != null)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      alt,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
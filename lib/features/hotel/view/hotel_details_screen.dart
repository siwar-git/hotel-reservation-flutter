import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hajz_sejours/features/hotel/controller/hotel_details_controller.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class HotelDetailsScreen extends StatelessWidget {
  final int hotelId;
  final int clientId;

  const HotelDetailsScreen({
    super.key,
    required this.hotelId,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HotelDetailsController()..fetchHotelDetails(hotelId),
      child: Scaffold(
        body: Consumer<HotelDetailsController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return _buildLoadingView();
            }

            if (controller.errorMessage != null) {
              return _buildErrorView(context, controller);
            }

            final hotel = controller.hotelDetails;
            if (hotel == null) {
              return _buildEmptyView();
            }

            return CustomScrollView(
              slivers: [
                _buildAppBar(context, hotel),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildNavigationButtons(context, hotelId),
                        _buildHotelHeader(hotel),
                        _buildDivider(),
                        _buildDescriptionSection(hotel),
                        _buildDivider(),
                        _buildGallerySection(hotel['galleryUrls']),
                        _buildDivider(),
                        _buildContactSection(hotel),
                        _buildDivider(),
                        _buildServicesSection(hotel['services']),
                        _buildDivider(),
                        _buildPresentationSection(hotel['presentationsUrl']),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============ Navigation Buttons ============
  Widget _buildNavigationButtons(BuildContext context, int hotelId) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _buildNavButton(context, 'Chambres', Icons.hotel, '/rooms', hotelId),
          _buildNavButton(context, 'Offres', Icons.local_offer, '/offers', hotelId),
          _buildNavButton(context, 'Restaurant', Icons.restaurant, '/restaurants', hotelId),
          _buildNavButton(context, 'Services', Icons.room_service, '/services', hotelId),
          _buildNavButton(context, 'Spa', Icons.spa, '/spa', hotelId),
          _buildNavButton(context, 'Conférences', Icons.meeting_room, '/conferences', hotelId),
          _buildNavButton(context, 'Avis', Icons.comment, '/avis', hotelId),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String label, IconData icon, String route, int hotelId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          print('Navigating to $route with hotelId: $hotelId, clientId: $clientId');
          Get.toNamed(route, arguments: {
            'hotelId': hotelId,
            'clientId': clientId,
          });
        },
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 0,
        ),
      ),
    );
  }

  // ============ Widget Builders ============
  Widget _buildAppBar(BuildContext context, Map<String, dynamic> hotel) {
    final imageUrl = hotel['imageUrl']?.toString() ?? '';
    return SliverAppBar(
      expandedHeight: 300,
      flexibleSpace: FlexibleSpaceBar(
        background: imageUrl.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildImagePlaceholder(),
          errorWidget: (context, url, error) => _buildImagePlaceholder(),
        )
            : _buildImagePlaceholder(),
      ),
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildHotelHeader(Map<String, dynamic> hotel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hotel['nom'],
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            5,
                (index) => Icon(
              Icons.star,
              color: index < (hotel['nombre_etoiles'] ?? 0)
                  ? Colors.amber
                  : Colors.grey[300],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(Map<String, dynamic> hotel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          hotel['description'],
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildGallerySection(List<String> galleryUrls) {
    if (galleryUrls.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Galerie',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: galleryUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: galleryUrls[index],
                    width: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(),
                    errorWidget: (context, url, error) => _buildImagePlaceholder(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(Map<String, dynamic> hotel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildContactTile(
          icon: Icons.location_on,
          text: hotel['adresse'],
          onTap: () => _launchMaps(hotel['adresse']),
        ),
        _buildContactTile(
          icon: Icons.phone,
          text: hotel['contact']['telephone'],
          onTap: () => _launchPhone(hotel['contact']['telephone']),
        ),
        _buildContactTile(
          icon: Icons.email,
          text: hotel['contact']['email'],
          onTap: () => _launchEmail(hotel['contact']['email']),
        ),
        if (hotel['contact']['whatsApp']?.isNotEmpty ?? false)
          _buildContactTile(
            icon: Icons.chat,
            text: hotel['contact']['whatsApp'],
            onTap: () => _launchWhatsApp(hotel['contact']['whatsApp']),
          ),
      ],
    );
  }

  Widget _buildServicesSection(Map<String, dynamic> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildServiceItem('Parking', services['parking'], Icons.local_parking),
        _buildServiceItem('Wi-Fi', services['wifi'], Icons.wifi),
        _buildServiceItem('Piscine', services['piscine'], Icons.pool),
      ],
    );
  }

  Widget _buildRoomItem(Map<String, dynamic> room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room['type'] ?? 'Chambre Standard',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (room['price'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Prix: ${room['price']} TND'),
              ),
            if (room['description'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(room['description']),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresentationSection(String? presentationUrl) {
    if (presentationUrl == null || presentationUrl.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Présentation',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _launchUrl(presentationUrl),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Voir la présentation PDF'),
                const Spacer(),
                Icon(Icons.chevron_right, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============ Helper Widgets ============
  Widget _buildContactTile({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 24,
    );
  }

  Widget _buildServiceItem(String title, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value ?? 'Non spécifié'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(height: 1),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.image, size: 50)),
    );
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorView(BuildContext context, HotelDetailsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(controller.errorMessage ?? 'Erreur inconnue'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.fetchHotelDetails(hotelId),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(child: Text('Aucune donnée disponible'));
  }

  // ============ Actions ============


  Future<void> _launchMaps(String address) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final url = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
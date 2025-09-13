import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hajz_sejours/features/service/controller/services_controller.dart';

class ServicesScreen extends StatelessWidget {
  final int hotelId;

  const ServicesScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServicesController()..fetchServices(hotelId),
      child: Consumer<ServicesController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.errorMessage != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => controller.fetchServices(hotelId),
                      child: const Text("Réessayer"),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Services de l\'Hôtel',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.deepPurple,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DÉCOUVREZ LES DIFFÉRENTS SERVICES PROPOSÉS',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurpleAccent),
                  ),
                  const SizedBox(height: 20),
                  if (controller.piscines.isNotEmpty) ...[
                    const SectionTitle(title: 'Piscines'),
                    _buildImageCarousel(controller.piscineImages),
                    _serviceList(controller.piscines),
                  ],
                  if (controller.activitesSportives.isNotEmpty) ...[
                    const SectionTitle(title: 'Activités Sportives'),
                    _buildImageCarousel(controller.activitesSportivesImages),
                    _serviceList(controller.activitesSportives),
                  ],
                  if (controller.fitnessSpa.isNotEmpty) ...[
                    const SectionTitle(title: "Fitness & Spa"),
                    _buildImageCarousel(controller.fitnessSpaImages),
                    _serviceList(controller.fitnessSpa),
                  ],
                  if (controller.kidsActivities.isNotEmpty) ...[
                    const SectionTitle(title: 'Kids Activities'),
                    _buildImageCarousel(controller.kidsActivitiesImages),
                    _serviceList(controller.kidsActivities),
                  ],
                  if (controller.autresServices.isNotEmpty) ...[
                    const SectionTitle(title: 'Autres Services'),
                    _buildImageCarousel(controller.autresServicesImages),
                    _serviceList(controller.autresServices),
                  ],
                  if (controller.equipements.isNotEmpty) ...[
                    const SectionTitle(title: 'Équipements de Chambre'),
                    _buildImageCarousel(controller.equipementsImages),
                    _serviceList(controller.equipements.map((equipement) {
                      return {
                        'title': equipement['title'],
                        'description': '',
                        'details': [],
                      };
                    }).toList()),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    int currentPage = 0;
    final PageController _pageController = PageController();
    Timer? _timer;

    _timer = Timer.periodic(const Duration(seconds: 7), (Timer timer) {
      if (images.isEmpty) return;
      if (currentPage < images.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: PageView.builder(
        controller: _pageController,
        itemCount: images.isNotEmpty ? images.length : 1,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              images.isNotEmpty ? images[index] : 'https://via.placeholder.com/200',
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/service_placeholder.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _serviceList(List<Map<String, dynamic>> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: services.map((service) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      service['icon'] ?? Icons.room_service,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      service['title'] ?? 'Titre non disponible',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  service['description'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                if (service['details'] != null &&
                    service['details'] is List<String> &&
                    (service['details'] as List).isNotEmpty)
                  ...(service['details'] as List<String>)
                      .map<Widget>((detail) => Text(
                    '• $detail',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ))
                      .toList(),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
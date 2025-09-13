import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hajz_sejours/features/offer/controller/offers_controller.dart';

class OffersScreen extends StatelessWidget {
  final int hotelId;

  const OffersScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OffersController()..fetchOffers(hotelId),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            title: const Text(
              'Réserver une offre spéciale',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blueAccent,
            elevation: 8,
            shadowColor: Colors.blueAccent.withOpacity(0.3),
          ),
        ),
        body: Consumer<OffersController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => controller.fetchOffers(hotelId),
                      child: const Text("Réessayer"),
                    ),
                  ],
                ),
              );
            }

            final offers = controller.offers;
            if (offers.isEmpty) {
              return const Center(child: Text("Aucune offre disponible"));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return GestureDetector(
                    onTap: () {
                      // TODO: Naviguer vers une page de détails ou un formulaire de réservation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Offre sélectionnée: ${offer['title']}")),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 1,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                            child: Image.network(
                              offer['image'] ?? 'https://via.placeholder.com/200',
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                'assets/offer_placeholder.jpg',
                                fit: BoxFit.cover,
                                height: 200,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              offer['title'] ?? 'Titre non disponible',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              offer['description'] ?? 'Description non disponible',
                              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Prix: ${offer['price'] != null ? offer['price'].toStringAsFixed(2) : 'N/A'} TND',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
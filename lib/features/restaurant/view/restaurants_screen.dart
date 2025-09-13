import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hajz_sejours/features/restaurant/controller/restaurants_controller.dart';

class RestaurantsScreen extends StatefulWidget {
  final int hotelId;

  const RestaurantsScreen({super.key, required this.hotelId});

  @override
  _RestaurantsScreenState createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      final controller = Provider.of<RestaurantsController>(context, listen: false);
      if (controller.images.isEmpty) return;

      if (_currentPage < controller.images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (mounted) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RestaurantsController()..fetchRestaurants(widget.hotelId),
      child: Consumer<RestaurantsController>(
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
                      onPressed: () => controller.fetchRestaurants(widget.hotelId),
                      child: const Text("Réessayer"),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.restaurantsBars.isEmpty) {
            return const Scaffold(
              body: Center(child: Text("Aucun restaurant ou bar disponible")),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Restaurants & Bars'),
              backgroundColor: const Color.fromARGB(255, 85, 108, 229),
            ),
            body: Column(
              children: [
                Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: controller.images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              controller.images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: ${controller.images[index]}');
                                return Image.asset(
                                  'assets/restaurant_placeholder.jpg',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.images.length,
                                (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: _currentPage == index ? 12 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? const Color.fromARGB(255, 255, 198, 0)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: controller.restaurantsBars.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final restaurant = controller.restaurantsBars[index];
                      return ListTile(
                        leading: Icon(
                          restaurant['icon'] ?? Icons.restaurant,
                          color: const Color.fromARGB(255, 106, 69, 219),
                        ),
                        title: Text(
                          restaurant['name'] ?? 'Nom non disponible',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          restaurant['description'] ?? 'Non disponible',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
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
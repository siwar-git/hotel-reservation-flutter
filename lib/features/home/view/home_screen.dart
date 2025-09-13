import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hajz_sejours/core/routes/app_route.dart';
import 'package:hajz_sejours/features/home/controller/home_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final int clientId;

  const HomeScreen({super.key, required this.clientId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _hotelNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('HomeScreen initialized with clientId: ${widget.clientId}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _typeController.dispose();
    _hotelNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(clientId: widget.clientId)..fetchData(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Consumer<HomeController>(
          builder: (context, controller, _) {

            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: controller.fetchData,
              color: Theme.of(context).primaryColor,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false, // Disable the back arrow
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeaderSection(context),
                    ),
                    expandedHeight: 150,
                    pinned: true,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  SliverToBoxAdapter(child: _buildSearchBar(context)),
                  SliverToBoxAdapter(child: _buildHotelsSection(context, controller)),
                  SliverToBoxAdapter(child: _buildRecommendedRoomsSection(context, controller)),
                  SliverToBoxAdapter(child: _buildServicesSection(context, controller)),
                  SliverToBoxAdapter(child: _buildRestaurantsSection(context, controller)),
                  SliverToBoxAdapter(child: _buildSpasSection(context, controller)),
                  SliverToBoxAdapter(child: _buildConferencesSection(context, controller)),
                  SliverToBoxAdapter(child: _buildCustomerReviewsSection(context, controller)),
                ],
              ),

            );
          },
        ),
        bottomNavigationBar: _buildFooter(context),

      ),
    );
  }

  // ============ Header Section ============
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            const Color(0xFF586EE9),
            const Color(0xFF7878F0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Découvrez, explorez et réservez avec Marhaba',
              style: GoogleFonts.montserrat(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ),
          Lottie.asset('assets/animation.json', height: 110),
        ],
      ),
    );
  }

// ============ Search Bar ============
  Widget _buildSearchBar(BuildContext context) {
    final categories = ['Hôtels', 'Chambres', 'Services', 'Restaurants', 'Spas', 'Conférences'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher une chambre ou un service...",
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list, size: 30, color: Color(0xFFF5C506)),
                      onPressed: () {
                        _showFilterDialog(context, categories);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, size: 30, color: Color(0xFFF5C506)),
                      onPressed: () => _performSearch(context),
                    ),
                  ],
                ),
              ),
              onSubmitted: (value) => _performSearch(context),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: categories.map((category) {
              return FilterChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                  debugPrint('Category selected: $_selectedCategory');
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, List<String> categories) {
    String? tempSelectedCategory = _selectedCategory;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtres de Recherche'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _minPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix Minimum (€)',
                    hintText: 'Ex: 50',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _maxPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix Maximum (€)',
                    hintText: 'Ex: 200',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    hintText: 'Ex: Suite, Restaurant, Spa',
                  ),
                ),
                TextField(
                  controller: _hotelNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'Hôtel',
                    hintText: 'Entrez le nom de l\'hôtel',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Catégorie:'),
                Wrap(
                  spacing: 8,
                  children: categories.map((category) {
                    return FilterChip(
                      label: Text(category),
                      selected: tempSelectedCategory == category,
                      onSelected: (selected) {
                        tempSelectedCategory = selected ? category : null;
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = tempSelectedCategory;
                });
                Navigator.of(context).pop();
                _performSearch(context);
              },
              child: const Text('Appliquer'),
            ),
          ],
        );
      },
    );
  }

  void _performSearch(BuildContext context) {
    final query = _searchController.text.trim();
    final minPrice = _minPriceController.text.trim();
    final maxPrice = _maxPriceController.text.trim();
    final type = _typeController.text.trim();
    final hotelName = _hotelNameController.text.trim();

    debugPrint(
        'Search triggered: query=$query, category=$_selectedCategory, '
            'minPrice=$minPrice, maxPrice=$maxPrice, type=$type, hotelName=$hotelName, '
            'clientId=${widget.clientId}');

    if (query.isNotEmpty ||
        _selectedCategory != null ||
        minPrice.isNotEmpty ||
        maxPrice.isNotEmpty ||
        type.isNotEmpty ||
        hotelName.isNotEmpty) {
      if ((minPrice.isNotEmpty && double.tryParse(minPrice) == null) ||
          (maxPrice.isNotEmpty && double.tryParse(maxPrice) == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les prix doivent être des nombres valides')),
        );
        return;
      }
      _navigateTo(context, AppRoutes.searchResults, arguments: {
        'query': query,
        'category': _selectedCategory,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'type': type,
        'hotelName': hotelName,
        'clientId': widget.clientId,
      });
    } else {
      debugPrint('Search blocked: no valid search parameters');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer au moins un critère de recherche')),
      );
    }
  }

  // ============ Section Header ============
  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.amaticSc(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
  // ============ Hotels Section ============
  Widget _buildHotelsSection(BuildContext context, HomeController controller) {
    if (controller.isHotelsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.hotels.isEmpty) {
      debugPrint('Hotels section empty');
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Hôtels Populaires', () {
            Get.toNamed(AppRoutes.fullList, arguments: {
              'title': 'Hôtels Populaires',
              'items': controller.hotels,
              'routeName': AppRoutes.hotelDetails,
              'clientId': widget.clientId,
            });
          }),
          const SizedBox(height: 12),
          _buildHotelCarousel(context, controller.hotels.take(5).toList()),
        ],
      ),
    );
  }

  Widget _buildHotelCarousel(BuildContext context, List<Map<String, dynamic>> hotels) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 270,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 0.85,
            enableInfiniteScroll: hotels.length > 1,
          ),
          items: hotels.map((hotel) {
            return _buildHotelCard(context, hotel);
          }).toList(),
        )
      ],
    );
  }

  Widget _buildHotelCard(BuildContext context, Map<String, dynamic> hotel) {
    final controller = Provider.of<HomeController>(context, listen: false);
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(
            AppRoutes.hotelDetails,
            arguments: {
              'hotelId': hotel['id'],
              'clientId': widget.clientId,
            },
          );
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              _buildImage(context, hotel['imageUrl'], height: 270, alt: hotel['nom']),
              Positioned(
                top: 8,
                right: 8,
                child: hotel['isSpecialOffer'] == true
                    ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Offre spéciale',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                )
                    : hotel['isNew'] == true
                    ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Nouveau',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                )
                    : const SizedBox(),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel['nom']?.toString() ?? 'Hôtel sans nom',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          5,
                              (index) => Icon(
                            Icons.star,
                            size: 14,
                            color: index < (hotel['nombre_etoiles'] ?? 0) ? Colors.amber : Colors.grey[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ Recommended Rooms Section ============
  Widget _buildRecommendedRoomsSection(BuildContext context, HomeController controller) {
    if (controller.isRoomsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.recommendedRooms.isEmpty) {
      debugPrint('Recommended rooms section empty');
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Chambres Recommandées', () {
            Get.toNamed(AppRoutes.fullList, arguments: {
              'type': 'Chambres Recommandées',
              'items': controller.recommendedRooms,
              'routeName': AppRoutes.roomDetails,
              'clientId': widget.clientId,
            });
          }),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.recommendedRooms.take(5).length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return _buildRoomCard(context, controller.recommendedRooms[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, Map<String, dynamic> room) {
    final controller = Provider.of<HomeController>(context, listen: false);
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          color: Color.fromRGBO(48, 39, 38, 0.32941176470588235),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(context, room['imageUrl'], height: 130, alt: room['type']),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room['type']?.toString() ?? 'Chambre',
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
                          room['price']?.toString() ?? 'Prix indisponible',
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
            ],
          ),
        ),
      ),
    );
  }

  // ============ Services Section ============
  Widget _buildServicesSection(BuildContext context, HomeController controller) {
    if (controller.isServicesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.services.isEmpty) {
      debugPrint('Services section empty');
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Services Populaires', () {
            _navigateTo(context, AppRoutes.fullList, arguments: {
              'title': 'Services Populaires',
              'items': controller.services,
              'routeName': AppRoutes.serviceDetails,
              'clientId': widget.clientId,
            });
          }),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.services.take(5).length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return _buildServiceCard(context, controller.services[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    final controller = Provider.of<HomeController>(context, listen: false);
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          color: Color.fromRGBO(48, 39, 38, 0.32941176470588235),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(context, service['imageUrl'], height: 130, alt: service['title']),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['title']?.toString() ?? 'Service',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ Restaurants Section ============
  Widget _buildRestaurantsSection(BuildContext context, HomeController controller) {
    if (controller.isRestaurantsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.restaurants.isEmpty) {
      debugPrint('Restaurants section empty');
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Restaurants', () {
            _navigateTo(context, AppRoutes.fullList, arguments: {
              'title': 'Restaurants',
              'items': controller.restaurants,
              'routeName': AppRoutes.restaurantDetails,
              'clientId': widget.clientId,
            });
          }),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.restaurants.take(5).length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return _buildRestaurantCard(context, controller.restaurants[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Map<String, dynamic> restaurant) {
    final controller = Provider.of<HomeController>(context, listen: false);
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          color: Color.fromRGBO(48, 39, 38, 0.32941176470588235),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(context, restaurant['imageUrl'], height: 130, alt: restaurant['title']),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant['name']?.toString() ?? 'Restaurant',
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
                          restaurant['price']?.toString() ?? 'Prix indisponible',
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
            ],
          ),
        ),
      ),
    );
  }

  // ============ Spas Section ============
  Widget _buildSpasSection(BuildContext context, HomeController controller) {
    if (controller.isSpasLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.spas.isEmpty) {
      debugPrint('Spas section empty');
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Spas', () {
            _navigateTo(context, AppRoutes.fullList, arguments: {
              'title': 'Spas',
              'items': controller.spas,
              'routeName': AppRoutes.spaDetails,
              'clientId': widget.clientId,
            });
          }),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.spas.take(5).length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return _buildSpaCard(context, controller.spas[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpaCard(BuildContext context, Map<String, dynamic> spa) {
    final controller = Provider.of<HomeController>(context, listen: false);
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          color: Color.fromRGBO(48, 39, 38, 0.32941176470588235),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(context, spa['imageUrl'], height: 130, alt: spa['title']),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spa['title']?.toString() ?? 'Spa',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ Conferences Section ============
  Widget _buildConferencesSection(BuildContext context, HomeController controller) {
    if (controller.isConferencesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.conferences.isEmpty) {
      debugPrint('Conferences section empty');
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Conférences', () {
            _navigateTo(context, AppRoutes.fullList, arguments: {
              'title': 'Conférences',
              'items': controller.conferences,
              'routeName': AppRoutes.conferenceDetails,
              'clientId': widget.clientId,
            });
          }),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.conferences.take(5).length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return _buildConferenceCard(context, controller.conferences[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConferenceCard(BuildContext context, Map<String, dynamic> conference) {
    final controller = Provider.of<HomeController>(context, listen: false);
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          color: Color.fromRGBO(48, 39, 38, 0.32941176470588235),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(context, conference['imageUrl'], height: 130, alt: conference['title']),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conference['title']?.toString() ?? 'Conférence',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ Customer Reviews Section ============
  Widget _buildCustomerReviewsSection(BuildContext context, HomeController controller) {
    if (controller.isReviewsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 2.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.customerReviews.isEmpty) {
      debugPrint('Customer reviews section empty');
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Avis des Clients', null),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: controller.customerReviews.map((review) {
                return _buildReviewCard(context, review);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Map<String, dynamic> review) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Card(
        color: Color.fromRGBO(48, 39, 38, 0.32941176470588235),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 7),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15.0,right: 25.0,left: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  Text(
                    review['date']?.toString() ?? '',
                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: List.generate(
                  10,
                      (index) => Icon(
                    Icons.star,
                    size: 16,
                    color: index < (review['rating'] ?? 0) ? Colors.amber : Theme.of(context).hintColor,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                review['review']?.toString() ?? 'Aucun commentaire',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============= Navigation method(ensures clientId is passed) ==================
  void _navigateTo(BuildContext context, String route, {Map<String, dynamic>? arguments}) {
    try {
      final updatedArguments = arguments != null ? Map<String, dynamic>.from(arguments) : {};
      if (!updatedArguments.containsKey('clientId')) {
        updatedArguments['clientId'] = widget.clientId;
      }
      Get.toNamed(route, arguments: updatedArguments);
    } catch (e) {
      debugPrint('Navigation error to $route: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de navigation vers $route: $e')),
      );
    }
  }

  // ============ Helper Widgets ============
  Widget _buildErrorScreen(BuildContext context, HomeController controller) {
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
            controller.errorMessage ?? 'Erreur inconnue',
            style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: controller.fetchData,
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

  Widget _buildImage(BuildContext context, String? imageUrl, {double? height, String? alt}) {
    debugPrint('Image URL: $imageUrl');
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: imageUrl == null || imageUrl.isEmpty
          ? Container(
        height: height,
        width: double.infinity,
        color: Theme.of(context).cardColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 30,
              color: Theme.of(context).hintColor,
            ),
            if (alt != null)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  alt,
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      )
          : FadeInImage(
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: const AssetImage('assets/placeholder.jpg'),
        image: NetworkImage(imageUrl),
        imageErrorBuilder: (context, error, stackTrace) {
          debugPrint('Image load error: $imageUrl, Error: $error');
          return Container(
            height: height,
            color: Theme.of(context).cardColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 30,
                  color: Theme.of(context).hintColor,
                ),
                if (alt != null)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      alt,
                      style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
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

  // ================ Footer navigation(uses _navigateTo) =====================
  Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            const Color(0xFF586EE9),
            const Color(0xFF7878F0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 5),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterIcon(context, Icons.person, 'Profil', AppRoutes.profile),
          _buildFooterIcon(context, Icons.notifications, 'Notifications', AppRoutes.notifications),
          _buildHomeIcon(context),
          _buildFooterIcon(context, Icons.chat_outlined, 'Chatbot', AppRoutes.chatbot),
          _buildFooterIcon(context, Icons.newspaper, 'Actualites', AppRoutes.Actualites),
        ],
      ),
    );
  }

  Widget _buildFooterIcon(BuildContext context, IconData icon, String label, String route) {
    return IconButton(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
      onPressed: () => _navigateTo(context, route),
    );
  }

  Widget _buildHomeIcon(BuildContext context) {
    return IconButton(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.home, color: Color(0xFFF5C506), size: 30),
          const SizedBox(height: 4),
          const Text(
            'Accueil',
            style: TextStyle(color: Color(0xFFF5C506), fontSize: 12),
          ),
        ],
      ),
      onPressed: () => _navigateTo(context, AppRoutes.home),
    );
  }
}
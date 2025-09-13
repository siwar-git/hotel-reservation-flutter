import 'dart:async';
import 'dart:developer' as Get;
import 'package:flutter/material.dart';
import 'package:hajz_sejours/features/reservation/view/reservation_screen.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hajz_sejours/features/room/controller/room_details_controller.dart';

class RoomDetailsScreen extends StatefulWidget {
  final int roomId;
  final int clientId;

  const RoomDetailsScreen({
    super.key,
    required this.roomId,
    required this.clientId,
  });

  @override
  _RoomDetailsScreenState createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  late PageController _pageController;
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final controller = Provider.of<RoomDetailsController>(context, listen: false);
      final room = controller.roomDetails;
      if (room == null || room.imageUrls.isEmpty) return;

      if (_currentIndex < room.imageUrls.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _shareRoom(BuildContext context) async {
    final room = context.read<RoomDetailsController>().roomDetails;
    if (room == null) return;

    await Share.share(
      'Découvrez cette chambre : ${room.type}\n'
          'Capacité : ${room.capacite}\n'
          'Surface : ${room.surface}',
      subject: 'Chambre à découvrir',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use Theme.of(context) to get the current theme (light or dark)
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => RoomDetailsController()..fetchRoomDetails(widget.roomId),
      child: Consumer<RoomDetailsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator(color: theme.primaryColor)),
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
                      style: TextStyle(color: isDarkMode ? Colors.red[300] : Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => controller.fetchRoomDetails(widget.roomId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: isDarkMode ? Colors.white : Colors.black,
                      ),
                      child: const Text("Réessayer"),
                    ),
                  ],
                ),
              ),
            );
          }

          final room = controller.roomDetails;
          if (room == null) {
            return Scaffold(
              body: Center(
                child: Text(
                  "Aucune donnée disponible",
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
              ),
            );
          }

          return Scaffold(
            // Let Scaffold use the theme's scaffoldBackgroundColor
            appBar: AppBar(
              title: const Text('Détails de la Chambre'),
              centerTitle: true,
              backgroundColor: theme.primaryColor,
              foregroundColor: isDarkMode ? Colors.white : Colors.white,
            ),
            body: CustomScrollView(
              slivers: [

                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         SizedBox(
                             height:MediaQuery.sizeOf(context).height*.4,
                             child: _buildImageCarousel(context, room.imageUrls)),
                          Text(
                            room.type,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color.fromARGB(255, 39, 128, 237),
                            ),
                          ),
                          if (room.price > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Row(
                                children: [
                                  Icon(Icons.euro_symbol, color: isDarkMode ? Colors.green[300] : Colors.green.shade700),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${room.price.toStringAsFixed(2)} €",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.green[300] : Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                          _buildDetailRow('Capacité', room.capacite, Icons.person, isDarkMode),
                          _buildDetailRow('Surface', room.surface, Icons.square_foot, isDarkMode),
                          const SizedBox(height: 20),
                          if (room.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white70 : const Color.fromARGB(255, 40, 90, 190),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    room.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDarkMode ? Colors.grey[300] : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _buildEquipmentsSection(
                            'Équipements Vidéo / Audio',
                            room.videoAudio,
                            Icons.tv,
                            isDarkMode,
                          ),
                          _buildEquipmentsSection(
                            'Internet / Téléphonie',
                            room.internetTelephonie,
                            Icons.phone_in_talk,
                            isDarkMode,
                          ),
                          _buildEquipmentsSection(
                            'Électronique',
                            room.electronique,
                            Icons.electrical_services,
                            isDarkMode,
                          ),
                          _buildEquipmentsSection(
                            'Salle de bain',
                            room.salleDeBain,
                            Icons.bathtub,
                            isDarkMode,
                          ),
                          _buildEquipmentsSection(
                            'Vue extérieure',
                            room.terrainExterieurVue,
                            Icons.landscape,
                            isDarkMode,
                          ),
                          _buildEquipmentsSection(
                            'Lits',
                            room.lits,
                            Icons.bed,
                            isDarkMode,
                          ),
                          _buildEquipmentsSection(
                            'Meubles',
                            room.meubles,
                            Icons.chair,
                            isDarkMode,
                          ),
                          _buildEquipmentsSection(
                            'Autres',
                            room.autres,
                            Icons.settings,
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'shareButton',
                  onPressed: () => _shareRoom(context),
                  backgroundColor: isDarkMode ? Colors.orange[700] : Colors.orange,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.share),
                  tooltip: 'Partager la chambre',
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'reserveButton',
                  onPressed: () {
                    Get.log('Navigating to ReservationPage with roomId=${room.id}, clientId=${widget.clientId}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationPage(
                          roomData: {
                            'id': room.id,
                            'type': room.type,
                            'imageUrls': room.imageUrls,
                            'capacité': room.capacite,
                            'surface': room.surface,
                            'videoAudio': room.videoAudio,
                            'internetTelephonie': room.internetTelephonie,
                            'electronique': room.electronique,
                            'salleDeBain': room.salleDeBain,
                            'terrainExterieurVue': room.terrainExterieurVue,
                            'lits': room.lits,
                            'meubles': room.meubles,
                            'autres': room.autres,
                            'price': room.price,
                            'description': room.description,
                          },
                          clientId: widget.clientId,
                        ),
                      ),
                    );
                  },
                  backgroundColor: theme.primaryColor,
                  foregroundColor: isDarkMode ? Colors.white : Colors.white,
                  child: const Icon(Icons.book_online),
                  tooltip: 'Réserver cette chambre',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context, List<String> images) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (images.isEmpty) {
      return Image.asset(
        'assets/room_placeholder.jpg',
        fit: BoxFit.cover,
      );
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Failed to load image: ${images[index]}, Error: $error');
                  return Image.asset(
                    'assets/room_placeholder.jpg',
                    fit: BoxFit.cover,
                  );
                },
              ),
            );
          },
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.map((url) {
              int index = images.indexOf(url);
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? (isDarkMode ? Colors.white : Colors.black).withOpacity(0.9)
                      : (isDarkMode ? Colors.white : Colors.black).withOpacity(0.4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon, bool isDarkMode) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: isDarkMode ? Colors.blue[300] : Colors.blueAccent),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[400] : Colors.grey,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentsSection(String title, List<String> items, IconData icon, bool isDarkMode) {
    final validItems = items.where((item) => item.isNotEmpty).toList();
    if (validItems.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isDarkMode ? Colors.indigo[300] : Colors.indigo),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: validItems
                .map((item) => ActionChip(
              label: Text(item, style: TextStyle(color: isDarkMode ? Colors.indigo[100] : Colors.indigo)),
              onPressed: () {},
              backgroundColor: isDarkMode ? Colors.grey[700] : Colors.indigo.withOpacity(0.1),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
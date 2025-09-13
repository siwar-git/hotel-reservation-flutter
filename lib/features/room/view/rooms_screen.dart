import 'package:flutter/material.dart';
import 'package:hajz_sejours/features/room/model/room_model.dart';
import 'package:provider/provider.dart';
import 'package:hajz_sejours/features/room/controller/rooms_controller.dart';
import 'package:hajz_sejours/features/room/view/room_details_screen.dart';

class RoomsScreen extends StatelessWidget {
  final int hotelId;
  final int clientId;

  const RoomsScreen({super.key, required this.hotelId, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoomsController()..fetchRooms(hotelId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Chambres de l'Hôtel",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 85, 108, 229),
        ),
        body: Consumer<RoomsController>(
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
                      onPressed: () => controller.fetchRooms(hotelId),
                      child: const Text("Réessayer"),
                    ),
                  ],
                ),
              );
            }

            final rooms = controller.rooms;
            if (rooms.isEmpty) {
              return const Center(child: Text("Aucune chambre disponible"));
            }

            return ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                return _buildRoomCard(context, rooms[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, Room room) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailsScreen(
              roomId: room.id,
              clientId: clientId,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: room.imageUrls.isNotEmpty
                    ? Image.network(
                  room.imageUrls[0],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('Failed to load image: ${room.imageUrls[0]}, Error: $error');
                    return Image.asset(
                      'assets/room_placeholder.jpg',
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    );
                  },
                )
                    : Image.asset(
                  'assets/room_placeholder.jpg',
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.type,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 85, 108, 229),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.group_outlined, 'Capacité: ', room.capacite),
                  _buildDetailRow(Icons.straighten, 'Surface: ', room.surface),
                  _buildDetailRow(Icons.tv_outlined, 'TV/Audio: ', room.videoAudio),
                  _buildDetailRow(Icons.wifi, 'Internet/Téléphone: ', room.internetTelephonie),
                  _buildDetailRow(Icons.electrical_services_outlined, 'Électronique: ', room.electronique),
                  _buildDetailRow(Icons.bathtub_outlined, 'Salle de bain: ', room.salleDeBain),
                  _buildDetailRow(Icons.view_in_ar_outlined, 'Vue: ', room.terrainExterieurVue),
                  _buildDetailRow(Icons.bed_outlined, 'Lits: ', room.lits),
                  _buildDetailRow(Icons.chair_outlined, 'Meubles: ', room.meubles),
                  if (room.autres.isNotEmpty)
                    _buildDetailRow(Icons.more_horiz, 'Autres: ', room.autres),
                  const SizedBox(height: 8),
                  Text(
                    'Prix: ${room.price > 0 ? '${room.price.toStringAsFixed(2)} €' : 'Non disponible'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                  if (room.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Description: ${room.description}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, dynamic value) {
    String displayValue;
    if (value is List<String>) {
      displayValue = value.isNotEmpty ? value.join(', ') : 'Non disponible';
    } else {
      displayValue = value?.toString() ?? 'Non disponible';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[600],
            size: 16,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '$label$displayValue',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
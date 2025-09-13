import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajz_sejours/features/reservation/controller/reservation_controller.dart';
import 'package:intl/intl.dart';

class ReservationPage extends StatefulWidget {
  final Map<String, dynamic> roomData;
  final int clientId;

  const ReservationPage({
    Key? key,
    required this.roomData,
    required this.clientId,
  }) : super(key: key);

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final ReservationController controller = Get.put(ReservationController());
  bool applyDiscount = false;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  bool isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    Get.log('ReservationPage init: clientId=${widget.clientId}, roomId=${widget.roomData['id']}');
    controller.fetchClientData(widget.clientId, widget.roomData);
  }

  Future<void> _selectCheckInDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now, // Start with current date
      firstDate: now, // Prevent selecting past dates
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null && picked != checkInDate) {
      setState(() {
        // Set time to 12:00:00 to ensure future time
        checkInDate = DateTime(picked.year, picked.month, picked.day, 12, 0, 0);
        if (checkOutDate != null && checkOutDate!.isBefore(checkInDate!)) {
          checkOutDate = null;
        }
        _updatePriceAndDiscount();
      });
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: checkInDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: checkInDate?.add(const Duration(days: 1)) ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != checkOutDate) {
      setState(() {
        // Set time to 12:00:00 for consistency
        checkOutDate = DateTime(picked.year, picked.month, picked.day, 12, 0, 0);
        _updatePriceAndDiscount();
      });
    }
  }

  void _updatePriceAndDiscount() {
    if (checkInDate != null && checkOutDate != null) {
      final nights = checkOutDate!.difference(checkInDate!).inDays;
      controller.calculateTotalPrice(nights, applyDiscount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Réservation de chambre"),
        backgroundColor: theme.primaryColor,
        foregroundColor: isDarkMode ? Colors.white : Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPointsInfo(context, isDarkMode),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.clientPoints.value == 0) {
          return Center(child: CircularProgressIndicator(color: theme.primaryColor));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRoomInfoSection(isDarkMode),
              const SizedBox(height: 20),
              _buildDateSelectionSection(isDarkMode),
              const SizedBox(height: 20),
              _buildClientPointsSection(isDarkMode),
              const SizedBox(height: 20),
              _buildPriceSection(isDarkMode),
              const SizedBox(height: 30),
              _buildReservationButton(isDarkMode),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRoomInfoSection(bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.roomData['type'] ?? 'Chambre',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.roomData['imageUrls']?[0] ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  child: const Icon(Icons.image, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              widget.roomData['description'] ?? 'Pas de description disponible',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.people, size: 20, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 5),
                Text(
                  "Capacité: ${widget.roomData['capacité'] ?? 'N/A'}",
                  style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.aspect_ratio, size: 20, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 5),
                Text(
                  "Surface: ${widget.roomData['surface'] ?? 'N/A'}",
                  style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectionSection(bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélection des dates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text(
                checkInDate == null
                    ? 'Sélectionner la date d\'arrivée'
                    : 'Arrivée: ${DateFormat('dd/MM/yyyy').format(checkInDate!)}',
                style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black87),
              ),
              trailing: Icon(Icons.calendar_today, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              onTap: () => _selectCheckInDate(context),
            ),
            ListTile(
              title: Text(
                checkOutDate == null
                    ? 'Sélectionner la date de départ'
                    : 'Départ: ${DateFormat('dd/MM/yyyy').format(checkOutDate!)}',
                style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black87),
              ),
              trailing: Icon(Icons.calendar_today, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              onTap: checkInDate == null ? null : () => _selectCheckOutDate(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientPointsSection(bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vos points de fidélité',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: controller.clientPoints.value / 100,
              backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(isDarkMode ? Colors.amber[300] : Colors.amber),
              minHeight: 10,
            ),
            const SizedBox(height: 10),
            Text(
              '${controller.clientPoints.value} points disponibles',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            if (checkInDate != null && checkOutDate != null) ...[
              const SizedBox(height: 10),
              Text(
                '${controller.discountedNights.value} nuit(s) avec réduction (${controller.pointsUsed.value} points utilisés)',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.green[300] : Colors.green,
                ),
              ),
              Text(
                '${controller.clientPoints.value - controller.pointsUsed.value + 15} points restants après réservation',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.black87,
                ),
              ),
            ],
            if (controller.clientPoints.value >= 50) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: applyDiscount,
                    onChanged: (value) {
                      setState(() {
                        applyDiscount = value ?? false;
                        _updatePriceAndDiscount();
                      });
                    },
                    activeColor: isDarkMode ? Colors.blue[300] : Colors.blue,
                  ),
                  Text(
                    'Utiliser points de réduction(50/nuit)',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails du prix',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            if (checkInDate != null && checkOutDate != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.totalNights.value} nuit(s) à ${controller.originalPrice.value.toStringAsFixed(2)} DT/nuit',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.black87,
                    ),
                  ),
                  Text(
                    '${(controller.totalNights.value * controller.originalPrice.value).toStringAsFixed(2)} DT',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.black87,
                    ),
                  ),
                ],
              ),
              if (controller.discountedNights.value > 0) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${controller.discountedNights.value} nuit(s) avec réduction (30%)',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[300] : Colors.black87,
                      ),
                    ),
                    Text(
                      '-${(controller.discountedNights.value * controller.originalPrice.value * 0.3).toStringAsFixed(2)} DT',
                      style: TextStyle(
                        color: isDarkMode ? Colors.green[300] : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ],
            Divider(
              height: 30,
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${controller.discountedPrice.value.toStringAsFixed(2)} DT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.blue[300] : Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: isDarkMode ? Colors.white : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: controller.isLoading.value ||
            isButtonDisabled ||
            checkInDate == null ||
            checkOutDate == null ||
            checkOutDate!.isBefore(checkInDate!.add(const Duration(days: 1)))
            ? null
            : () {
          setState(() {
            isButtonDisabled = true;
          });
          Get.log('Confirming reservation: clientId=${widget.clientId}, roomId=${widget.roomData['id']}, '
              'totalPrice=${controller.discountedPrice.value}, applyDiscount=$applyDiscount, '
              'discountedNights=${controller.discountedNights.value}, pointsUsed=${controller.pointsUsed.value}, '
              'checkInDate=$checkInDate, checkOutDate=$checkOutDate');
          controller.reserverEtPayerRoom(
            clientId: widget.clientId,
            roomId: widget.roomData['id'],
            totalPrice: controller.discountedPrice.value,
            applyDiscount: applyDiscount,
            discountedNights: controller.discountedNights.value,
            pointsUsed: controller.pointsUsed.value,
            checkInDate: checkInDate!,
            checkOutDate: checkOutDate!,
          ).then((_) {
            setState(() {
              isButtonDisabled = false;
            });
          });
        },
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Confirmer la réservation',
          style: TextStyle(fontSize: 18),
        ),
      )),
    );
  }

  void _showPointsInfo(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        title: Text(
          'Programme de fidélité',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• 1 point pour chaque dinar dépensé',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '• 50 points = 30% de réduction par nuit',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '• 15 points offerts après chaque réservation',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: isDarkMode ? Colors.blue[300] : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
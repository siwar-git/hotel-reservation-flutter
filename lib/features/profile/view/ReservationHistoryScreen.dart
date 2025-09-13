import 'package:flutter/material.dart';
import 'package:hajz_sejours/core/routes/app_route.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:intl/intl.dart'; // For date formatting

class ReservationModel {
  final int id;
  final String? reservationDate;
  final String? checkInDate;
  final String? checkOutDate;
  final double? discount;
  final double? discountedPrice;

  ReservationModel({
    required this.id,
    this.reservationDate,
    this.checkInDate,
    this.checkOutDate,
    this.discount,
    this.discountedPrice,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as int,
      reservationDate: json['reservationDate'] as String?,
      checkInDate: json['checkInDate'] as String?,
      checkOutDate: json['checkOutDate'] as String?,
      discount: (json['discount'] as num?)?.toDouble(),
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
    );
  }
}

class ReservationHistoryScreen extends StatefulWidget {
  final int clientId;

  const ReservationHistoryScreen({super.key, required this.clientId});

  @override
  _ReservationHistoryScreenState createState() => _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  List<ReservationModel> _reservations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppApi.baseUrl}/client/${widget.clientId}/reservations'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _reservations = data.map((json) => ReservationModel.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Échec du chargement des réservations';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur : $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? date) {
    if (date == null) return 'Non spécifié';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des réservations'),
        backgroundColor: const Color(0xFF0D2180),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchReservations,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : _reservations.isEmpty
          ? const Center(child: Text('Aucune réservation trouvée'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final reservation = _reservations[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text('Réservation #${reservation.id}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date de réservation: ${_formatDate(reservation.reservationDate)}'),
                  Text('Date d\'arrivée: ${_formatDate(reservation.checkInDate)}'),
                  Text('Date de départ: ${_formatDate(reservation.checkOutDate)}'),
                  Text('Remise: ${reservation.discount?.toStringAsFixed(0) ?? '0'}%'),
                  Text('Prix réduit: ${reservation.discountedPrice?.toStringAsFixed(2) ?? '0.00'} €'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
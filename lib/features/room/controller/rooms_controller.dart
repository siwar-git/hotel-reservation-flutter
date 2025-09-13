import 'package:flutter/material.dart';
import 'package:hajz_sejours/features/room/model/room_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';

class RoomsController extends ChangeNotifier {
  List<Room> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRooms(int hotelId) async {
    _isLoading = true;
    _errorMessage = null;
    _rooms = [];
    notifyListeners();

    try {
      final uri = Uri.parse(AppApi.hotelRoomsUrl(hotelId));
      print('Fetching rooms from: $uri'); // For debugging
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _rooms = data.map((room) => Room.fromJson(room)).toList();
      } else {
        print('Failed to fetch rooms: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Erreur lors de la récupération des chambres: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching rooms: $e');
      _errorMessage = 'Erreur lors de la récupération des chambres: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
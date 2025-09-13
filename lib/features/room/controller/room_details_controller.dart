import 'package:flutter/material.dart';
import 'package:hajz_sejours/features/room/model/room_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';

class RoomDetailsController extends ChangeNotifier {
  Room? _roomDetails;
  bool _isLoading = false;
  String? _errorMessage;

  Room? get roomDetails => _roomDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRoomDetails(int roomId) async {
    _isLoading = true;
    _errorMessage = null;
    _roomDetails = null;
    notifyListeners();

    try {
      final uri = Uri.parse(AppApi.roomDetailsUrl(roomId));
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _roomDetails = Room.fromJson(data);
      } else {
        throw Exception('Erreur lors de la récupération des détails: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération des détails: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
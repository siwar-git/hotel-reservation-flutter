import 'package:flutter/material.dart';

// Thème global de l'application
class AppTheme {
  static const primaryColor = Color(0xFF1628AB);
  static const accentColor = Color(0xFF976DD1);
  static const backgroundGradient = LinearGradient(
    colors: [Color(0xFF976DD1), Color(0xFF1628AB), Color(0xFF111B4B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const textStyle = TextStyle(
    color: Colors.white,
    fontFamily: 'Roboto',
    fontSize: 16,
  );
  static const headingStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
}
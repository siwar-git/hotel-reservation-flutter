import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hajz_sejours/core/routes/app_route.dart';
import 'package:hajz_sejours/features/splash/view/splash_screen.dart';
import 'package:hajz_sejours/features/profile/controller/profile_controller.dart';
import 'package:provider/provider.dart';

// Palette de couleurs personnalisée pour Hajz Sejours
const hajzPrimaryColor = Color(0xFF586EE9); // Bleu-violet élégant
const hajzSecondaryColor = Color(0xFFF5C506); // Jaune-or pour les accents
const hajzSurfaceColor = Color(0xFFF8F9FA); // Fond clair
const hajzDarkSurfaceColor = Color(0xFF1C2526); // Fond sombre
const hajzTextColor = Color(0xFF302726); // Texte principal
const hajzTextColorDark = Color(0xFFE0E0E0); // Texte principal en mode sombre

// Définition du thème clair
final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: hajzPrimaryColor,
    secondary: hajzSecondaryColor,
    surface: hajzSurfaceColor,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: hajzTextColor,
    error: Colors.redAccent,
  ),
  scaffoldBackgroundColor: hajzSurfaceColor,
  cardColor: Colors.white,
  textTheme: GoogleFonts.montserratTextTheme(
    const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: hajzTextColor,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: hajzTextColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: hajzTextColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: hajzTextColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: hajzTextColor,
      ),
    ),
  ),
  hintColor: Colors.grey[600],
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: hajzPrimaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: hajzPrimaryColor,
      textStyle: GoogleFonts.montserrat(fontSize: 14),
    ),
  ),
  iconTheme: const IconThemeData(color: hajzTextColor, size: 24),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: hajzPrimaryColor, width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
    hintStyle: GoogleFonts.montserrat(color: Colors.grey[600], fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: hajzPrimaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
);

// Définition du thème sombre
final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: hajzPrimaryColor,
    secondary: hajzSecondaryColor,
    surface: hajzDarkSurfaceColor,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: hajzTextColorDark,
    error: Colors.redAccent,
  ),
  scaffoldBackgroundColor: hajzDarkSurfaceColor,
  cardColor: Colors.grey[850],
  textTheme: GoogleFonts.montserratTextTheme(
    const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: hajzTextColorDark,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: hajzTextColorDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: hajzTextColorDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: hajzTextColorDark,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: hajzTextColorDark,
      ),
    ),
  ),
  hintColor: Colors.grey[400],
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: hajzPrimaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: hajzSecondaryColor,
      textStyle: GoogleFonts.montserrat(fontSize: 14),
    ),
  ),
  iconTheme: const IconThemeData(color: hajzTextColorDark, size: 24),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Colors.grey[700]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Colors.grey[700]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: hajzPrimaryColor, width: 2),
    ),
    filled: true,
    fillColor: Colors.grey[900],
    hintStyle: GoogleFonts.montserrat(color: Colors.grey[400], fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: hajzPrimaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
        // Add other providers here if needed
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hajz Sejours',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,
      ),
    );
  }
}

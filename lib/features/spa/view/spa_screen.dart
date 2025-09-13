import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hajz_sejours/features/spa/controller/spa_controller.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class SpaScreen extends StatelessWidget {
  final int hotelId;

  const SpaScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SpaController()..fetchSpa(hotelId),
      child: Consumer<SpaController>(
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
                      onPressed: () => controller.fetchSpa(hotelId),
                      child: const Text("Réessayer"),
                    ),
                  ],
                ),
              ),
            );
          }

          final spa = controller.spa;
          if (spa == null) {
            return const Scaffold(
              body: Center(child: Text("Aucune donnée disponible")),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text("Spa & Bien-être", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.blue[100],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 500,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: spa['image'] != null
                            ? NetworkImage(spa['image'])
                            : const AssetImage('assets/spa_placeholder.jpg') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spa['title'] ?? 'SPA HOTEL',
                          style: TextStyle(fontSize: 22, color: Colors.orange[300]),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          spa['description'] ?? 'Aucune description disponible.',
                          style: TextStyle(fontSize: 18, color: Colors.blue[900]),
                        ),
                        const SizedBox(height: 20),
                        if (spa['catalogue'] != null && spa['catalogue'].isNotEmpty)
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SpaPdfScreen(catalogueUrl: spa['catalogue']),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                              label: const Text(
                                "Voir le catalogue du Spa",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(12),
                                backgroundColor: Colors.blue[100],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SpaPdfScreen extends StatelessWidget {
  final String catalogueUrl;

  const SpaPdfScreen({super.key, required this.catalogueUrl});

  Future<String> _downloadPdfToLocal() async {
    try {
      final response = await http.get(Uri.parse(catalogueUrl));
      if (response.statusCode == 200) {
        final Directory dir = await getApplicationDocumentsDirectory();
        final File file = File("${dir.path}/catalogue_spa.pdf");
        await file.writeAsBytes(response.bodyBytes, flush: true);
        return file.path;
      } else {
        throw Exception('Erreur lors du téléchargement du PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du téléchargement du PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catalogue Spa")),
      body: FutureBuilder<String>(
        future: _downloadPdfToLocal(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur de chargement du PDF: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Aucun fichier PDF disponible"));
          }
          return PDFView(filePath: snapshot.data!);
        },
      ),
    );
  }
}
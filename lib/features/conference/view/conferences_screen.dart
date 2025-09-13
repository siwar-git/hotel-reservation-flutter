import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hajz_sejours/features/conference/controller/conferences_controller.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ConferencesScreen extends StatefulWidget {
  final int hotelId;

  const ConferencesScreen({super.key, required this.hotelId});

  @override
  _ConferencesScreenState createState() => _ConferencesScreenState();
}

class _ConferencesScreenState extends State<ConferencesScreen> {
  late PageController _pageController;
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
      final controller = Provider.of<ConferencesController>(context, listen: false);
      if (controller.images.isEmpty) return;

      if (_currentIndex < controller.images.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConferencesController()..fetchConferences(widget.hotelId),
      child: Consumer<ConferencesController>(
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
                      onPressed: () => controller.fetchConferences(widget.hotelId),
                      child: const Text("Réessayer"),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.conferences.isEmpty) {
            return const Scaffold(
              body: Center(child: Text("Aucune conférence disponible")),
            );
          }

          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 233, 232, 238),
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 450.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: controller.images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            controller.images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/conference_placeholder.jpg',
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  backgroundColor: const Color.fromARGB(74, 224, 226, 248),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    controller.conferences.map((conference) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conference['title'] ?? 'Séminaires & Conférences',
                              style: TextStyle(color: Colors.blue[800], fontSize: 30),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              conference['description'] ?? 'Aucune description disponible.',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            if (conference['presentationsUrl'] != null && conference['presentationsUrl'].isNotEmpty)
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfScreen(
                                          newsletterUrl: conference['presentationsUrl'],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 30),
                                  label: const Text(
                                    "Voir les détails (MICE newsletter)",
                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(12),
                                    backgroundColor: Colors.blue[800],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PdfScreen extends StatelessWidget {
  final String newsletterUrl;

  const PdfScreen({super.key, required this.newsletterUrl});

  Future<String> _downloadPdfToLocal() async {
    try {
      final response = await http.get(Uri.parse(newsletterUrl));
      if (response.statusCode == 200) {
        final Directory dir = await getApplicationDocumentsDirectory();
        final File file = File("${dir.path}/MICE_newsletter.pdf");
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
      appBar: AppBar(title: const Text("MICE Newsletter")),
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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:hajz_sejours/features/review/controller/reviews_controller.dart';
import 'package:http/http.dart' as http;
import 'package:hajz_sejours/core/app_api.dart';

class ReviewsScreen extends StatefulWidget {
  final int hotelId;
  final int clientId;

  const ReviewsScreen({
  super.key,
  required this.hotelId,
  required this.clientId,
  });

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String _selectedSort = "Date";
  String _searchQuery = "";
  final TextEditingController _reviewController = TextEditingController();
  double _selectedRating = 5.0;

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  void _sortReviews(String criteria, ReviewsController controller) {
    setState(() {
      if (criteria == "Rating") {
        controller.reviews.sort((a, b) => b["rating"].compareTo(a["rating"]));
      } else {
        controller.reviews.sort((a, b) => b["date"].compareTo(a["date"]));
      }
      _selectedSort = criteria;
    });
  }

  Future<void> _addReview(ReviewsController controller) async {
    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le champ commentaire ne peut pas être vide")),
      );
      return;
    }

    final rating = _selectedRating.round();
    if (rating < 1 || rating > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La note doit être entre 1 et 10")),
      );
      return;
    }

    try {
      final uri = Uri.parse(AppApi.addReviewUrl(widget.hotelId));
      print('Posting review to: $uri');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rating': rating,
          'review': _reviewController.text,
          'name': 'Utilisateur',
        }),
      );

      if (response.statusCode == 200) {
        await controller.fetchReviews(widget.hotelId);
        _reviewController.clear();
        setState(() {
          _selectedRating = 5.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Avis ajouté avec succès !")),
        );
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur lors de l\'ajout de l\'avis';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error posting review: $e, StackTrace: ${StackTrace.current}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewsController()..fetchReviews(widget.hotelId),
      child: Consumer<ReviewsController>(
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
                      onPressed: () => controller.fetchReviews(widget.hotelId),
                      child: const Text("Réessayer"),
                    ),
                  ],
                ),
              ),
            );
          }

          List<Map<String, dynamic>> filteredReviews = controller.reviews
              .where((review) =>
          review["name"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              review["review"].toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text("Commentaires"),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) => _sortReviews(value, controller),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "Date", child: Text("Trier par Date")),
                    const PopupMenuItem(value: "Rating", child: Text("Trier par Note")),
                  ],
                  icon: const Icon(Icons.sort),
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Rechercher un avis...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredReviews.length,
                    itemBuilder: (context, index) {
                      final review = filteredReviews[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              review["rating"].toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            "${review["name"]}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(review["review"]),
                              const SizedBox(height: 5),
                              Text(
                                _formatDate(review["date"]),
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2, curve: Curves.easeOut);
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const Text("Ajoutez votre avis :", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _reviewController,
                        decoration: InputDecoration(
                          hintText: "Écrivez votre commentaire...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("Note : "),
                          Expanded(
                            child: Slider(
                              value: _selectedRating,
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: _selectedRating.round().toString(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRating = value;
                                });
                              },
                            ),
                          ),
                          Text(_selectedRating.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _addReview(controller),
                        icon: const Icon(Icons.send),
                        label: const Text("Envoyer"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
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
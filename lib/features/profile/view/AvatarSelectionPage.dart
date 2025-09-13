import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajz_sejours/features/profile/model/avatar_data.dart';

class AvatarSelectionPage extends StatelessWidget {
  const AvatarSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final avatars = AvatarData.getByCategory('Personnages');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un avatar'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: avatars.length,
        itemBuilder: (context, index) {
          final avatar = avatars[index];
          return GestureDetector(
            onTap: () {
              print('Selected avatar: ${avatar.id}'); // Debug
              Get.back(result: avatar); // Retourne l'objet Avatar complet
            },
            child: Semantics(
              label: avatar.label,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  avatar.path,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

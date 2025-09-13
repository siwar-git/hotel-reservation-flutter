import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajz_sejours/core/routes/app_route.dart';
import 'package:hajz_sejours/features/Actualites/controller/actualites_controller.dart';

class ActualitesPage extends StatelessWidget {
  final int clientId;
  const ActualitesPage({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActualitesController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable the back arrow
        title: const Text(
          "Actualités du Groupe Marhaba",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 13, 33, 128),
                Color(0xFF586EE9),
                Color.fromARGB(255, 120, 120, 240),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.actualites.isEmpty) {
          return const Center(child: Text("Aucune actualité disponible."));
        }
        return ListView.builder(
          itemCount: controller.actualites.length,
          itemBuilder: (context, index) {
            final actualite = controller.actualites[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                    child: _buildImage(context, actualite.imageUrl, height: 200),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      actualite.titre,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      actualite.contenu,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      }),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  /*Widget buildImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/spa_placeholder.jpg',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }*/

  Widget _buildImage(BuildContext context, String? imageUrl, {double? height, String? alt}) {
    debugPrint('Image URL: $imageUrl');
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: imageUrl == null || imageUrl.isEmpty
          ? Container(
        height: height,
        width: double.infinity,
        color: Theme.of(context).cardColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 30,
              color: Theme.of(context).hintColor,
            ),
            if (alt != null)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  alt,
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      )
          : FadeInImage(
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: const AssetImage('assets/placeholder.jpg'),
        image: NetworkImage(imageUrl),
        imageErrorBuilder: (context, error, stackTrace) {
          debugPrint('Image load error: $imageUrl, Error: $error');
          return Container(
            height: height,
            color: Theme.of(context).cardColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 30,
                  color: Theme.of(context).hintColor,
                ),
                if (alt != null)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      alt,
                      style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /*Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 13, 33, 128),
            Color(0xFF586EE9),
            Color.fromARGB(255, 120, 120, 240),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterIcon(context, Icons.person, 'Profil', AppRoutes.profile),
          _buildFooterIcon(context, Icons.notifications, 'Notifications',
              AppRoutes.notifications),
          _buildFooterIcon(context, Icons.home, 'Accueil', AppRoutes.home),
          _buildFooterIcon(
              context, Icons.chat_outlined, 'Chatbot', AppRoutes.chatbot),
          _buildFooterIcon2(
              context, Icons.newspaper, 'Actualites', AppRoutes.Actualites),
        ],
      ),
    );
  }*/

  Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme
                .of(context)
                .primaryColor,
            const Color(0xFF586EE9),
            const Color(0xFF7878F0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 5),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterIcon(
            context,
            Icons.person,
            'Profil',
            AppRoutes.profile,
          ),
          _buildFooterIcon(
            context,
            Icons.notifications,
            'Notifications',
            AppRoutes.notifications,
          ),
          _buildFooterIcon(
              context,
              Icons.home,
              'Accueil',
              AppRoutes.home
          ),
          _buildFooterIcon(
            context,
            Icons.chat_outlined,
            'Chatbot',
            AppRoutes.chatbot,
          ),
          _buildActualitesIcon(
              context
          ),
        ],
      ),
    );
  }

  Widget _buildFooterIcon(BuildContext context,
      IconData icon,
      String label,
      String route,) {
    return IconButton(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
      onPressed: () => _navigateTo(context, route),
    );
  }

  Widget _buildActualitesIcon(BuildContext context) {
    return IconButton(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.newspaper, color: Color(0xFFF5C506), size: 30),
          const SizedBox(height: 4),
          const Text(
            'Actualites',
            style: TextStyle(color: Color(0xFFF5C506), fontSize: 12),
          ),
        ],
      ),
      onPressed: () => _navigateTo(context, AppRoutes.Actualites),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Get.toNamed(route, arguments: {'clientId': clientId});
  }

}

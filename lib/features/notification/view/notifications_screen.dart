import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajz_sejours/features/notification/controller/notification_controller.dart';
import 'package:intl/intl.dart';
import 'package:hajz_sejours/core/routes/app_route.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends StatefulWidget {
  final int clientId;

  const NotificationsPage({Key? key, required this.clientId}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationsController controller = Get.put(NotificationsController());

  @override
  void initState() {
    super.initState();
    Get.log('NotificationsPage init: clientId=${widget.clientId}');
    controller.fetchNotifications(widget.clientId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable the back arrow
        title: Text(
          "Notifications",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 13, 33, 128),
                Color(0xFF586EE9), // hajzPrimaryColor
                Color.fromARGB(255, 120, 120, 240),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [theme.colorScheme.surface, Colors.grey[850]!]
                : [theme.scaffoldBackgroundColor, const Color(0xF9FBEFF4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
                }
                if (controller.notifications.isEmpty) {
                  return Center(
                    child: Text(
                      "Aucune notification disponible",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  itemCount: controller.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = controller.notifications[index];
                    return _buildNotificationItem(
                      id: notification['id'],
                      icon: _getIconForNotification(notification['titre']),
                      title: notification['titre'],
                      subtitle: notification['contenu'],
                      date: notification['date'],
                      iconColor: _getIconColorForNotification(notification['titre']),
                      onTap: () => _handleNotificationTap(notification),
                      onDelete: () => controller.deleteNotification(notification['id']),
                      isDarkMode: isDarkMode,
                      theme: theme,
                    );
                  },
                );
              }),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required int id,
    required IconData icon,
    required String title,
    required String subtitle,
    required DateTime date,
    required Color iconColor,
    required VoidCallback onTap,
    required VoidCallback onDelete,
    required bool isDarkMode,
    required ThemeData theme,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: theme.cardColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
              }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Text('Supprimer'),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

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
          _buildNotificationIcon(
              context
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
          _buildFooterIcon(
            context,
            Icons.newspaper,
            'Actualites',
            AppRoutes.Actualites,
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

  Widget _buildNotificationIcon(BuildContext context) {
    return IconButton(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications, color: Color(0xFFF5C506), size: 30),
          const SizedBox(height: 4),
          const Text(
            'Notifications',
            style: TextStyle(color: Color(0xFFF5C506), fontSize: 12),
          ),
        ],
      ),
      onPressed: () => _navigateTo(context, AppRoutes.notifications),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Get.toNamed(route, arguments: {'clientId': widget.clientId});
  }

  IconData _getIconForNotification(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('réservation')) {
      return Icons.notifications_active;
    } else if (lowerTitle.contains('offre')) {
      return Icons.local_offer;
    } else if (lowerTitle.contains('points')) {
      return Icons.star;
    } else if (lowerTitle.contains('profil') || lowerTitle.contains('mot de passe')) {
      return Icons.person;
    } else if (lowerTitle.contains('anniversaire')) {
      return Icons.cake;
    } else if (lowerTitle.contains('avis')) {
      return Icons.rate_review;
    } else if (lowerTitle.contains('bienvenue')) {
      return Icons.waving_hand;
    } else {
      return Icons.info;
    }
  }

  Color _getIconColorForNotification(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('réservation')) {
      return Colors.greenAccent;
    } else if (lowerTitle.contains('offre')) {
      return Colors.purpleAccent;
    } else if (lowerTitle.contains('points')) {
      return Colors.yellowAccent;
    } else if (lowerTitle.contains('profil') || lowerTitle.contains('mot de passe')) {
      return Colors.blueAccent;
    } else if (lowerTitle.contains('anniversaire')) {
      return Colors.pinkAccent;
    } else if (lowerTitle.contains('avis')) {
      return Colors.orangeAccent;
    } else if (lowerTitle.contains('bienvenue')) {
      return Colors.tealAccent;
    } else {
      return Colors.blueAccent;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final title = notification['titre'].toString().toLowerCase();
    final content = notification['contenu'].toString();

    if (title.contains('réservation')) {
      // Extract reservation ID from content (e.g., "ID: 123")
      final match = RegExp(r'ID: (\d+)').firstMatch(content);
      final reservationId = match != null ? int.tryParse(match.group(1)!) : null;
      Get.toNamed(
        AppRoutes.reservationDetails,
        arguments: {
          'notificationId': notification['id'],
          'clientId': widget.clientId,
          'reservationId': reservationId,
        },
      );
    } else if (title.contains('offre')) {
      // Extract hotel name or ID if available, or navigate to offers list
      Get.toNamed(
        AppRoutes.offers,
        arguments: {
          'clientId': widget.clientId,
          // Add hotelId if extractable from content (e.g., "hôtel XYZ")
        },
      );
    } else if (title.contains('profil') || title.contains('mot de passe')) {
      Get.toNamed(
        AppRoutes.profile,
        arguments: {'clientId': widget.clientId},
      );
    } else if (title.contains('avis')) {
      // Navigate to reviews screen, ideally with hotelId if extractable
      Get.toNamed(
        AppRoutes.avis,
        arguments: {
          'clientId': widget.clientId,
          // Add hotelId if extractable
        },
      );
    } else {
      // No navigation for welcome, birthday, points, or generic notifications
      Get.snackbar('Info', 'Aucune action disponible pour cette notification');
    }
  }
}
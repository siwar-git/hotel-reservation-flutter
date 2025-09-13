import 'package:flutter/material.dart';

class facturePage extends StatelessWidget {
  const facturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black54],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          children: [
            _buildNotificationItem(
              icon: Icons.notifications_active,
              title: "Nouvelle réservation confirmée",
              subtitle: "Votre réservation a été confirmée avec succès.",
              iconColor: Colors.greenAccent,
            ),
            _buildNotificationItem(
              icon: Icons.warning,
              title: "Problème de paiement",
              subtitle: "Votre dernier paiement a échoué. Veuillez réessayer.",
              iconColor: Colors.orangeAccent,
            ),
            _buildNotificationItem(
              icon: Icons.info,
              title: "Mise à jour de votre compte",
              subtitle: "Vos informations personnelles ont été modifiées.",
              iconColor: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white70)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
        onTap: () {},
      ),
    );
  }
}

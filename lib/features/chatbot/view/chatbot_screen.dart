import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:hajz_sejours/core/routes/app_route.dart';

class ChatbotPage extends StatefulWidget {
  final int clientId;

  const ChatbotPage({super.key, required this.clientId});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    // Append clientId to URL for potential personalization
    final chatbotUrl = 'https://www.chatbase.co/chatbot-iframe/1a_bBVCXMNah6D9kWIqQs?clientId=${widget.clientId}';
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(chatbotUrl));
    debugPrint('ChatbotPage initialized with clientId: ${widget.clientId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: WebViewWidget(controller: controller)),
            const SizedBox(height: 10),
            _buildFooter(context),
          ],
        ),
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
          _buildChatbotIcon(
              context
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

  Widget _buildChatbotIcon(BuildContext context) {
    return IconButton(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_outlined, color: Color(0xFFF5C506), size: 30),
          const SizedBox(height: 4),
          const Text(
            'Chatbot',
            style: TextStyle(color: Color(0xFFF5C506), fontSize: 12),
          ),
        ],
      ),
      onPressed: () => _navigateTo(context, AppRoutes.chatbot),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Get.toNamed(route, arguments: {'clientId': widget.clientId});
  }
}
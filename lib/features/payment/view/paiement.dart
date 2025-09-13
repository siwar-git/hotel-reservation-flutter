import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final String sessionUrl;

  const PaymentPage({super.key, required this.sessionUrl});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
            });
            Get.log('Chargement de la page : $url');
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
            Get.log('Page chargée : $url');
            if (url.contains('success')) {
              Get.snackbar('Succès', 'Paiement effectué avec succès');
              Get.offAllNamed('/home', arguments: {'clientId': Get.arguments?['clientId']});
            } else if (url.contains('cancel')) {
              Get.snackbar('Annulé', 'Paiement annulé');
              Get.back();
            }
          },
          onWebResourceError: (error) {
            setState(() {
              isLoading = false;
            });
            Get.snackbar('Erreur', 'Échec du chargement de la page : ${error.description}');
            Get.log('Erreur WebView : ${error.description}', isError: true);
            Get.back();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.sessionUrl));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: theme.primaryColor,
        foregroundColor: isDarkMode ? Colors.white : Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              Center(child: CircularProgressIndicator(color: theme.primaryColor)),
          ],
        ),
      ),
    );
  }
}
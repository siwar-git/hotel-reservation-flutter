import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:hajz_sejours/core/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _canResend = true;
  int _resendTimer = 60;
  Timer? _timer;
  Offset _offset = const Offset(1, 0);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _offset = Offset.zero);
    });
  }

  // Envoie un code de réinitialisation à l'email
  Future<Map<String, dynamic>> _sendResetCode() async {
    try {
      final jsonBody = jsonEncode({
        'email': _emailController.text,
        'isResetPassword': true,
      });
      Get.log('Send reset code body: $jsonBody');
      var response = await http.post(
        Uri.parse(AppApi.sendVerificationUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );
      Get.log('Send reset code response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Code envoyé avec succès'};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['error'] ?? 'Erreur lors de l\'envoi du code',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Erreur serveur: ${response.body}',
          };
        }
      }
    } catch (e) {
      Get.log('Send reset code error: $e');
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  // Démarre le timer pour le renvoi du code
  void _startResendTimer() {
    _resendTimer = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  // Gère l'envoi du code de réinitialisation
  void _handleSendResetCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _sendResetCode();

      setState(() => _isLoading = false);

      if (result['success']) {
        _startResendTimer();
        Get.log('Navigating to /reset-password-verify with email: ${_emailController.text}');
        Get.toNamed(
          '/reset-password-verify',
          arguments: _emailController.text,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: AppTheme.primaryColor,
        textTheme: const TextTheme(
          bodyMedium: AppTheme.textStyle,
          headlineMedium: AppTheme.headingStyle,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Réinitialiser le mot de passe", style: AppTheme.headingStyle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.offNamed('/login'),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedSlide(
                  offset: _offset,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 2),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Entrez votre email pour recevoir un code de vérification",
                            style: AppTheme.textStyle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: AppTheme.textStyle,
                            validator: (value) {
                              if (value == null || value.isEmpty) return "Email requis";
                              if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value))
                                return "Email invalide";
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Email",
                              labelStyle: const TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
                              ),
                              prefixIcon: const Icon(Icons.email, color: AppTheme.accentColor),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(height: 24),
                          LinearProgressIndicator(
                            value: _resendTimer / 60,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation(AppTheme.accentColor),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isLoading || !_canResend ? null : _handleSendResetCode,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(_canResend ? "Envoyer le code" : "Renvoyer dans $_resendTimer s"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Get.toNamed('/login'),
                            child: const Text("Retour à la connexion", style: TextStyle(color: Colors.white70)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
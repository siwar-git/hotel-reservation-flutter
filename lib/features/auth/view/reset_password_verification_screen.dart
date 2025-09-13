import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:hajz_sejours/core/app_theme.dart';

class ResetPasswordVerificationScreen extends StatefulWidget {
  final String email;

  const ResetPasswordVerificationScreen({super.key, required this.email});

  @override
  _ResetPasswordVerificationScreenState createState() => _ResetPasswordVerificationScreenState();
}

class _ResetPasswordVerificationScreenState extends State<ResetPasswordVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _codeControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isVerified = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _canResend = false;
  int _resendTimer = 60;
  int _expirationTimer = 300;
  Timer? _resendTimerObj;
  Timer? _expirationTimerObj;
  Offset _offset = const Offset(1, 0);

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _startExpirationTimer();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _offset = Offset.zero);
    });
  }

  // Démarre le timer pour le renvoi du code
  void _startResendTimer() {
    _resendTimerObj?.cancel();
    _resendTimer = 60;
    _canResend = false;
    _resendTimerObj = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  // Démarre le timer pour l'expiration du code
  void _startExpirationTimer() {
    _expirationTimerObj?.cancel();
    _expirationTimer = 300;
    _expirationTimerObj = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_expirationTimer > 0) {
          _expirationTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant ResetPasswordVerificationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resendTimerObj?.cancel();
    _expirationTimerObj?.cancel();
    _startResendTimer();
    _startExpirationTimer();
  }

  // Vérifie le code auprès du backend
  Future<Map<String, dynamic>> _verifyCodeBackend(String enteredCode) async {
    try {
      final jsonBody = jsonEncode({
        'email': widget.email,
        'code': enteredCode,
        'isResetPassword': true,
      });
      Get.log('Verify code body: $jsonBody');
      var response = await http.post(
        Uri.parse(AppApi.verifyUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );
      Get.log('Verify code response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Code vérifié avec succès'};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['error'] ?? 'Code invalide ou expiré',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Erreur serveur: ${response.body}',
          };
        }
      }
    } catch (e) {
      Get.log('Verify code error: $e');
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  // Réinitialise le mot de passe
  Future<Map<String, dynamic>> _resetPassword(String newPassword) async {
    try {
      final jsonBody = jsonEncode({
        'email': widget.email,
        'newPassword': newPassword,
      });
      Get.log('Reset password body: $jsonBody');
      var response = await http.post(
        Uri.parse(AppApi.resetPasswordUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );
      Get.log('Reset password response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Mot de passe réinitialisé avec succès'};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['error'] ?? 'Erreur lors de la réinitialisation',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Erreur serveur: ${response.body}',
          };
        }
      }
    } catch (e) {
      Get.log('Reset password error: $e');
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  // Envoie un nouveau code de réinitialisation
  Future<Map<String, dynamic>> _resendCode() async {
    try {
      final jsonBody = jsonEncode({
        'email': widget.email,
        'isResetPassword': true,
      });
      Get.log('Resend code body: $jsonBody');
      var response = await http.post(
        Uri.parse(AppApi.sendVerificationUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );
      Get.log('Resend code response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Nouveau code envoyé'};
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
      Get.log('Resend code error: $e');
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  // Vérifie le code saisi
  void _verifyCode() async {
    if (_expirationTimer <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code expiré. Veuillez demander un nouveau code.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final enteredCode = _codeControllers.map((c) => c.text).join();
    final result = await _verifyCodeBackend(enteredCode);

    setState(() => _isLoading = false);

    if (result['success']) {
      setState(() {
        _isVerified = true;
        _offset = const Offset(1, 0);
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() => _offset = Offset.zero);
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Gère le renvoi du code
  void _handleResendCode() async {
    setState(() => _isLoading = true);

    final result = await _resendCode();

    setState(() => _isLoading = false);

    if (result['success']) {
      _startResendTimer();
      _startExpirationTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Réinitialise le mot de passe après vérification
  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _resetPassword(_newPasswordController.text);

      setState(() => _isLoading = false);

      if (result['success']) {
        Get.log('Password reset successful, navigating to /login');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        Get.offNamed('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _resendTimerObj?.cancel();
    _expirationTimerObj?.cancel();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
          title: const Text("Vérification et réinitialisation", style: AppTheme.headingStyle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Quitter la réinitialisation ?'),
                  content: const Text('Si vous quittez, vous devrez recommencer le processus de réinitialisation.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.offNamed('/login');
                      },
                      child: const Text('Quitter'),
                    ),
                  ],
                ),
              );
            },
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
                      child: _isVerified ? _buildResetPasswordForm() : _buildVerificationForm(),
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

  // Formulaire de vérification du code
  Widget _buildVerificationForm() {
    final minutes = (_expirationTimer ~/ 60).toString().padLeft(2, '0');
    final seconds = (_expirationTimer % 60).toString().padLeft(2, '0');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Entrez le code envoyé à votre email", style: AppTheme.headingStyle),
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: _expirationTimer / 300,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation(AppTheme.accentColor),
              ),
            ),
            Text(
              "$minutes:$seconds",
              style: AppTheme.textStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
                (index) => SizedBox(
              width: 50,
              height: 60,
              child: TextFormField(
                controller: _codeControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: AppTheme.textStyle.copyWith(fontSize: 24),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (value.length == 1 && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                  if (_codeControllers.every((c) => c.text.isNotEmpty)) {
                    _verifyCode();
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyCode,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Vérifier"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading || !_canResend ? null : _handleResendCode,
          child: Text(
            _canResend ? "Renvoyer le code" : "Renvoyer dans $_resendTimer s",
            style: AppTheme.textStyle.copyWith(color: _canResend ? Colors.white : Colors.white70),
          ),
        ),
      ],
    );
  }

  // Formulaire de réinitialisation du mot de passe
  Widget _buildResetPasswordForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Entrez votre nouveau mot de passe", style: AppTheme.headingStyle),
        const SizedBox(height: 24),
        TextFormField(
          controller: _newPasswordController,
          obscureText: !_isPasswordVisible,
          style: AppTheme.textStyle,
          validator: (value) {
            if (value == null || value.isEmpty) return "Champ requis";
            if (value.length < 8) return "Au moins 8 caractères requis";
            if (!RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$').hasMatch(value))
              return "Doit contenir un chiffre et un caractère spécial";
            return null;
          },
          decoration: InputDecoration(
            labelText: "Nouveau mot de passe",
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
            prefixIcon: const Icon(Icons.lock, color: AppTheme.accentColor),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          style: AppTheme.textStyle,
          validator: (value) {
            if (value == null || value.isEmpty) return "Champ requis";
            if (value != _newPasswordController.text) return "Les mots de passe ne correspondent pas";
            return null;
          },
          decoration: InputDecoration(
            labelText: "Confirmer le mot de passe",
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
            prefixIcon: const Icon(Icons.lock, color: AppTheme.accentColor),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleResetPassword,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Réinitialiser"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
}
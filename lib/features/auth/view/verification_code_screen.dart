import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:hajz_sejours/core/app_api.dart';
import 'package:hajz_sejours/core/app_theme.dart';
import 'package:hajz_sejours/features/auth/controller/auth_controller.dart';
import 'package:get/get.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;
  final Map<String, dynamic> formData;

  const VerificationCodeScreen({
    Key? key,
    required this.email,
    required this.formData,
  }) : super(key: key);

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _canResend = false;
  int _resendTimer = 60;
  int _expirationTimer = 300;
  Timer? _resendTimerObj;
  Timer? _expirationTimerObj;

  @override
  void initState() {
    super.initState();
    Get.log(
      'VerificationCodeScreen init: email=${widget.email}, formData=${widget.formData}',
    );
    _startResendTimer();
    _startExpirationTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  void _startResendTimer() {
    _resendTimerObj?.cancel();
    _resendTimer = 60;
    _canResend = false;
    _resendTimerObj = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _startExpirationTimer() {
    _expirationTimerObj?.cancel();
    _expirationTimer = 300;
    _expirationTimerObj = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_expirationTimer > 0) {
        setState(() => _expirationTimer--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<Map<String, dynamic>> _verifyCodeBackend(String enteredCode) async {
    try {
      final jsonBody = jsonEncode({
        'email': widget.email,
        'code': enteredCode,
        'isResetPassword': false,
      });
      Get.log('Verify code request: URL=${AppApi.verifyUrl}, Body=$jsonBody');
      final response = await http.post(
        Uri.parse(AppApi.verifyUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );
      Get.log(
        'Verify code response: Status=${response.statusCode}, Headers=${response.headers}, Body=${response.body}',
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': responseData['success'] ?? true,
          'message': responseData['message'] ?? 'Email vérifié avec succès',
        };
      } else {
        final responseData =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Erreur: ${response.statusCode} ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      Get.log('Verify code error: $e', isError: true);
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  Future<Map<String, dynamic>> _registerUser() async {
    final authController = AuthController();
    Get.log('Registering user with formData: ${widget.formData}');
    return await authController.register(
      role: widget.formData['role'],
      nom: widget.formData['nom'],
      prenom: widget.formData['prenom'],
      email: widget.formData['email'],
      motDePass: widget.formData['motDePass'],
      localisation: widget.formData['localisation'],
      numTel: widget.formData['numTel'],
      username: widget.formData['username'],
      birthday: widget.formData['birthday'],
      point: widget.formData['point'],
    );
  }

  Future<void> _verifyCode() async {
    if (_expirationTimer <= 0) {
      _showSnackbar(
        'Code expiré. Veuillez demander un nouveau code.',
        Colors.red,
      );
      return;
    }

    final enteredCode = _codeControllers.map((c) => c.text).join();
    if (enteredCode.length != 6) {
      _showSnackbar(
        'Veuillez entrer un code complet à 6 chiffres.',
        Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    final verificationResult = await _verifyCodeBackend(enteredCode);

    if (verificationResult['success']) {
      final registerResult = await _registerUser();
      if (registerResult['success']) {
        final clientId = registerResult['clientId'];
        Get.log('Registration successful, clientId: $clientId');
        Get.offNamed('/login');
      } else {
        _showSnackbar(registerResult['message'], Colors.red);
      }
    } else {
      _showSnackbar(verificationResult['message'], Colors.red);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleResendCode() async {
    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse(AppApi.sendVerificationUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': widget.email, 'isResetPassword': false}),
    );
    Get.log(
      'Resend code response: Status=${response.statusCode}, Body=${response.body}',
    );

    if (response.statusCode == 200) {
      _startResendTimer();
      _startExpirationTimer();
      _showSnackbar('Nouveau code envoyé.', Colors.green);
    } else {
      final responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};
      _showSnackbar(
        responseData['message'] ?? 'Erreur lors de l\'envoi du code.',
        Colors.red,
      );
    }

    setState(() => _isLoading = false);
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text('Vérification', style: AppTheme.headingStyle),
                  const SizedBox(height: 10),
                  Text(
                    'Entrez le code reçu à ${widget.email}',
                    style: AppTheme.textStyle.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: TextField(
                          controller: _codeControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor:
                                isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color:
                                    isDarkMode
                                        ? Colors.white.withOpacity(0.3)
                                        : Colors.grey,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color:
                                    isDarkMode
                                        ? Colors.white.withOpacity(0.3)
                                        : Colors.grey,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppTheme.accentColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_focusNodes[index + 1]);
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_focusNodes[index - 1]);
                            }
                            if (index == 5 && value.isNotEmpty) {
                              _verifyCode();
                            }
                          },
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator(
                        color: AppTheme.accentColor,
                      )
                      : ElevatedButton(
                        onPressed: _verifyCode,
                        child: const Text('     Vérifier le code    '),
                      ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _canResend ? _handleResendCode : null,
                    child: Text(
                      _canResend
                          ? 'Renvoyer le code'
                          : 'Renvoyer dans $_resendTimer s',
                      style: AppTheme.textStyle.copyWith(
                        color:
                            _canResend ? AppTheme.accentColor : Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

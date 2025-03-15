import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer;
  int _countdown = 30;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail(); // Send email on screen load
    _startTimer();
    _checkEmailVerified(); // Periodically check verification status
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendVerificationEmail() async {
    setState(() => _isLoading = true);
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending verification email: $e')),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _checkEmailVerified() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _auth.currentUser?.reload();
      if (_auth.currentUser?.emailVerified ?? false) {
        timer.cancel();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/email_verified');
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String email = _auth.currentUser?.email ?? 'your email';
    String maskedEmail = email.replaceRange(3, email.indexOf('@'), '...');

    return Scaffold(
      backgroundColor: const Color(0xFF34978A),
      body: Stack(
        children: [
          // Back arrow
          Positioned(
            top: 45,
            left: 5,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // White card with content
          Positioned(
            top: 96,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verify your account',
                        style: TextStyle(
                          color: Color(0xFF202020),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'We sent a verification link to your email – $maskedEmail',
                        style: const TextStyle(
                          color: Color(0xFF606060),
                          fontSize: 16,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Check Email...',
                        style: TextStyle(
                          color: Color(0xFF202020),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _countdown == 0 && !_isLoading
                            ? () async {
                                setState(() {
                                  _countdown = 30;
                                  _startTimer();
                                });
                                await _sendVerificationEmail();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF202020),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80),
                          ),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Resend Email',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Didn\'t receive the email? Resend in 00:${_countdown.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Color(0xFF505050),
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
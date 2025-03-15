import 'package:flutter/material.dart';

class PasswordResetScreen extends StatelessWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => Navigator.pop(context),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Password Reset',
                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Click below to log in to your account',
                      style: TextStyle(
                        color: Color(0xFF606060),
                        fontSize: 16,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 38),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF202020),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80),
                        ),
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

void main() {
  runApp(const MaterialApp(home: CreateAccountScreen()));
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _passwordVisible = false;

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF34978A), // Teal-green background
    body: Stack(
      children: [
        // Back arrow positioned above the white card
        Positioned(
          top: 45, // Positioned above the white card
          left: 5, // Aligned to the left with padding
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () {
              Navigator.pop(context); // Back navigation
            },
          ),
        ),
        // White card with content
        Positioned(
          top: 96, // Start of the white card
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            width: 390, // Set width
            height: 748, // Set height
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
                      'Create Account',
                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Color(0xFF606060),
                            fontSize: 14,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to login screen
                          },
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              color: Color(0xFF34978A),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Email Field
                    const Text(
                      'Email',
                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'e.g user@inrida.com',
                        filled: true,
                        fillColor: const Color(0xFFE5E5E5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(80),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 23,
                          horizontal: 30,
                        ),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF909090),
                        fontSize: 14,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Phone Number Field
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    IntlPhoneField(
                      decoration: InputDecoration(
                        hintText: '00 000 00000',
                        filled: true,
                        fillColor: const Color(0xFFE5E5E5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(80),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 23,
                          horizontal: 40,
                        ),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF909090),
                        fontSize: 14,
                        fontFamily: 'DM Sans',
                      ),
                      initialCountryCode: 'RW', // Rwanda flag with +250
                      onChanged: (phone) {
                        // Handle phone number input
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    const Text(
                      'Password',
                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        filled: true,
                        fillColor: const Color(0xFFE5E5E5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(80),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 23,
                          horizontal: 30,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF909090),
                        fontSize: 14,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Minimum of 8 characters',
                      style: TextStyle(
                        color: Color(0xFF606060),
                        fontSize: 14,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 38),
                    // Terms and Conditions
                    Text.rich(
                      TextSpan(
                        text: 'By signing up, I agree to the ',
                        style: const TextStyle(
                          color: Color(0xFF505050),
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF34978A),
                              fontWeight: FontWeight.w400,
                            ),
                            // Add navigation if needed
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 14,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Create Account Button
                    ElevatedButton(
                      onPressed: () {
                        // Handle account creation
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF202020),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80),
                        ),
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Divider with "or" text
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: Color(0xFF505050),
                              fontSize: 16,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Continue with Google Button
                    OutlinedButton.icon(
                      onPressed: () {
                        // Handle Google sign-in
                      },
                      icon: Image.asset(
                        'assets/google_logo.png', // Ensure asset is added
                        width: 24,
                        height: 24,
                      ),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: Color(0xFF202020),
                          fontSize: 16,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFD2D2D2),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        minimumSize: const Size(double.infinity, 60),
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
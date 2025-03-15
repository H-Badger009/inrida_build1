import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import for Firestore

class CreateAccountScreen extends StatefulWidget {
  final String selectedRole; // Add this to accept the selected role

  const CreateAccountScreen({super.key, required this.selectedRole}); // Update constructor

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _passwordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _createAccount() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;
      if (user != null) {
        // Store user data in Firestore, including the selected role
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'phone': _phoneController.text.trim(),
          'role': widget.selectedRole, // Store the selected role
          'createdAt': FieldValue.serverTimestamp(),
        });

        await user.sendEmailVerification();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/verify_account');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating account: $e')),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF34978A),
      body: Stack(
        children: [
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
                              Navigator.pushNamed(context, '/login'); // Adjust route
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
                        controller: _emailController,
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
                        controller: _phoneController,
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
                        initialCountryCode: 'RW',
                        onChanged: (phone) {
                          // Handle phone number change if needed
                        },
                      ),
                      const SizedBox(height: 20),
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
                        controller: _passwordController,
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
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
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
                      ElevatedButton(
                        onPressed: _isLoading ? null : _createAccount,
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
                      OutlinedButton.icon(
                        onPressed: () {
                          // Handle Google sign-in (implement if needed)
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
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:inrida/providers/user_provider.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool _passwordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _logIn() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Fetch user data and store in provider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.fetchUserData(userCredential.user!.uid);

        // Navigate based on role from provider
        final role = userProvider.userProfile?.role;
        if (role == 'Car Owner') {
          Navigator.pushReplacementNamed(context, '/car_owner_home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Role not authorized for this dashboard')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging in: $e')),
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
              onPressed: () => Navigator.pop(context),
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
                      const Text('Log In', style: TextStyle(color: Color(0xFF202020), fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'DM Sans')),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF606060), fontSize: 14, fontFamily: 'DM Sans')),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/create_account'),
                            child: const Text('Create Account', style: TextStyle(color: Color(0xFF34978A), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'DM Sans')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Email', style: TextStyle(color: Color(0xFF202020), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'DM Sans')),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'e.g user@inrida.com',
                          filled: true,
                          fillColor: const Color(0xFFE5E5E5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(80), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 23, horizontal: 30),
                        ),
                        style: const TextStyle(color: Color(0xFF909090), fontSize: 14, fontFamily: 'DM Sans'),
                      ),
                      const SizedBox(height: 20),
                      const Text('Password', style: TextStyle(color: Color(0xFF202020), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'DM Sans')),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          filled: true,
                          fillColor: const Color(0xFFE5E5E5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(80), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 23, horizontal: 30),
                          suffixIcon: IconButton(
                            icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                          ),
                        ),
                        style: const TextStyle(color: Color(0xFF909090), fontSize: 14, fontFamily: 'DM Sans'),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
                          child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF34978A), fontSize: 14, fontFamily: 'DM Sans')),
                        ),
                      ),
                      const SizedBox(height: 38),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _logIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF202020),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Log In', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'DM Sans')),
                      ),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('or', style: TextStyle(color: Color(0xFF505050), fontSize: 16, fontFamily: 'DM Sans'))),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ]),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: Image.asset('assets/google_logo.png', width: 24, height: 24),
                        label: const Text('Continue with Google', style: TextStyle(color: Color(0xFF202020), fontSize: 16, fontFamily: 'DM Sans')),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD2D2D2), width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
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
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/log_in_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/verify_account_screen.dart';
import 'screens/email_verified_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'package:inrida/screens/check_email_screen.dart';
import 'package:inrida/screens/password_reset_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InRidaApp());
}

class InRidaApp extends StatelessWidget {
  const InRidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InRida',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => LogInScreen(),
        '/create_account': (context) => const CreateAccountScreen(),
        '/verify_account': (context) => const VerifyAccountScreen(),
        '/email_verified': (context) => const EmailVerifiedScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/check_email': (context) => const CheckEmailScreen(),
        '/password_reset': (context) => const PasswordResetScreen(),
      },
    );
  }
}
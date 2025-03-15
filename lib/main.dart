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
import 'package:provider/provider.dart';
import 'package:inrida/screens/car_owner/car_owner_home_screen.dart';
import 'package:inrida/providers/driver_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DriverProvider()),
      ],
      child: const InRidaApp(),
    ),
  );
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
        '/create_account': (context) => CreateAccountScreen(selectedRole: 'defaultRole'),
        '/verify_account': (context) => const VerifyAccountScreen(),
        '/email_verified': (context) => const EmailVerifiedScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/check_email': (context) => const CheckEmailScreen(),
        '/password_reset': (context) => const PasswordResetScreen(),
        '/car_owner_home': (context) => const CarOwnerHomeScreen(),
        '/tracking': (context) => const TrackingScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/account': (context) => const AccountScreen(),
        '/my_cars': (context) => const MyCarsScreen(),
        '/trip_history': (context) => const TripHistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}


// Placeholder screens
class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Tracking')));
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Notifications')));
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Account')));
}

class MyCarsScreen extends StatelessWidget {
  const MyCarsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('My Cars')));
}

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Trip History')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Settings')));
}
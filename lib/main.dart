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
import 'package:inrida/screens/driver/driver_home_screen.dart';
import 'package:inrida/screens/account_screen.dart';
import 'package:inrida/screens/driver/driver_account_screen.dart';
import 'package:inrida/screens/driver/driver_verify_account_screen.dart';
import 'package:inrida/providers/driver_provider.dart';
import 'package:inrida/providers/user_provider.dart';
import 'package:inrida/providers/vehicle_provider.dart';
import 'package:inrida/screens/vehicles_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DriverProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
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
      initialRoute: '/splash', // Set the intro animation as the initial route
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LogInScreen(),
        '/create_account': (context) => const CreateAccountScreen(selectedRole: 'defaultRole'),
        '/verify_account': (context) => const VerifyAccountScreen(),
        '/email_verified': (context) => const EmailVerifiedScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/check_email': (context) => const CheckEmailScreen(),
        '/password_reset': (context) => const PasswordResetScreen(),
        '/car_owner_home': (context) => const CarOwnerHomeScreen(),
        '/driver_home': (context) => const DriverHomeScreen(),
        '/tracking': (context) => const TrackingScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/account': (context) => const ProfileScreen(),
        '/driver_account': (context) => const DriverAccountScreen(),
        '/driver_verify_account': (context) => const DriverVerifyAccountScreen(),
        '/my_cars': (context) => const MyCarsScreen(),
        '/trip_history': (context) => const TripHistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/vehicles': (context) => const VehiclesScreen(),
      },
    );
  }
}

// Placeholder screens (unchanged)
class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Tracking')));
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Notifications')));
}

class MyCarsScreen extends StatelessWidget {
  const MyCarsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('My Cars')));
}

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Trip History')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Settings')));
}
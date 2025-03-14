import 'dart:async';
import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Track the current stage of the splash screen (0, 1, 2)
  int _currentStage = 0;
  // Timer to control the 3-second transitions
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start the timer sequence
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        if (_currentStage < 2) {
          _currentStage++;
        } else {
          // After 3 stages (15 seconds), navigate to Role Selection
          _timer.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Clean up the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF34978A), // Updated background color
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Stage 2: Concentric circles (only visible in stage 2)
              if (_currentStage == 2)
                AnimatedContainer(
                  duration: const Duration(seconds: 4),
                  curve: Curves.easeInOut,
                  width: 133,
                  height: 133,
                  child: CustomPaint(
                    painter: ConcentricCirclesPainter(),
                  ),
                ),
              // Stage 1: Single opaque circle (only visible in stage 1)
              if (_currentStage == 1)
                AnimatedContainer(
                  duration: const Duration(seconds: 5),
                  curve: Curves.easeInOut,
                  width: 140, // 120 (logo size) + 3 (radius) * 2
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha((0.5 * 255).toInt()), // Opaque circle
                  ),
                ),
              // Stage 0, 1, 2: Logo (always visible)
              Image.asset(
                'assets/InRida Logo Frame.png',
                width: 98,
                height: 98,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for concentric circles
class ConcentricCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint();

    // Inner circle (most transparent)
    paint.color = Colors.white.withAlpha((0.1 * 255).toInt());
    canvas.drawCircle(center, 54, paint); // 120 + 3 radius

    // Middle circle (more transparent)
    paint.color = Colors.white.withAlpha((0.2 * 255).toInt());
    canvas.drawCircle(center, 63, paint); // Slightly larger
    // Outer circle (least transparent)
    paint.color = Colors.white.withAlpha((0.4 * 255).toInt());
    canvas.drawCircle(center, 72, paint); // Largest
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
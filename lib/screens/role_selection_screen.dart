import 'package:flutter/material.dart';
import 'create_account_screen.dart'; // Add this import

void main() {
  runApp(const MaterialApp(
    home: RoleSelectionScreen(),
  ));
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF34978A), // Teal background
      body: Stack(
        children: [
          // Header with centered logo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.transparent, // Let teal background show through
              child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/InRida Logo.png',
                width: 28,
                height: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'inRida',
                style: TextStyle(
            color: Color(0xFFFBFBFB), // Contrast with teal
            fontSize: 20,
            fontFamily: 'Audiowide',
            fontWeight: FontWeight.w400,
            height: 1.0,
            letterSpacing: 0.0,
                ),
              ),
            ],
          ),
              ),
            ),
          ),
          // Main content with top radius
          Positioned(
            top: 96, // Adjusted top position
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
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
          children: [
            
            // Header texts (replaced Positioned with Padding for positioning)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 25), // Adjusted top padding to match top: 137
              child: const Text(
                "Let's Get Started",
                style: TextStyle(
            color: Color(0xFF202020),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
            height: 1.3,
            letterSpacing: -0.02,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 20), // Align with the above text
              child: const Text(
                "Please select your preferred profile role",
                style: TextStyle(
            color: Color(0xFF606060),
            fontSize: 14,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: -0.01,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Role cards in GridView
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
            RoleCard(
              iconPath: 'assets/ion_car-sport-sharp.png',
              label: 'Car Owner',
              isSelected: selectedRole == 'car_owner',
              onTap: () => setState(() => selectedRole = 'car_owner'),
            ),
            RoleCard(
              iconPath: 'assets/mingcute_steering-wheel-fill.png',
              label: 'Driver',
              isSelected: selectedRole == 'driver',
              onTap: () => setState(() => selectedRole = 'driver'),
            ),
            RoleCard(
              iconPath: 'assets/tabler_user-filled.png',
              label: 'Rider (Client)',
              isSelected: selectedRole == 'rider',
              onTap: () => setState(() => selectedRole = 'rider'),
            ),
                ],
              ),
            ),
            // Continue button with bottom padding to reveal wavy pattern
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: selectedRole != null
              ? () {
                  Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
                  );
                }
              : null,
                style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            minimumSize: const Size(350, 56),
                ),
                child: const Text(
            'Continue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'SansSerif',
            ),
                ),
              ),
            ),
          ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.grey[200] : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 40,
              height: 40,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: -0.01,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
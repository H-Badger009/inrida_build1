// my_car_screen.dart
import 'package:flutter/material.dart';
import 'search_cars_screen.dart'; // Import the new SearchCarsScreen

class MyCarScreen extends StatelessWidget {
  const MyCarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        title: const Text(
          'My Car',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Car Icon
            Image.asset(
              'assets/openmoji_autonomous-car.png', // Consistent with sidebar icon
              width: 105,
              height: 105,
              color: const Color(0xFF34978A), // Updated color to match #34978A
            ),
            const SizedBox(height: 12), // Spacing between icon and text
            // "No Car Assigned?" Text
            const Text(
              'No Car Assigned?',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.0, // Line height as a multiplier
                letterSpacing: 0.0,
                textBaseline: TextBaseline.alphabetic,
                color: Color(0xFF202020),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8), // Spacing between text elements
            // Description Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "You haven't picked a car yet. Find an available car to start earning.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 1.0, // Line height as a multiplier
                  letterSpacing: 0.0,
                  color: Color(0xFF606060),
                ),
              ),
            ),
            const SizedBox(height: 32), // Spacing between text and button
            // "Search Available Cars" Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: double.infinity, // Full width with padding
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to SearchCarsScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchCarsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34978A), // Updated color to #34978A
                    fixedSize: const Size(200, 48), // Set width to 200 and height to 48
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Search Available Cars',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.0, // Line height as a multiplier
                      letterSpacing: 0.0,
                      color: Colors.white,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
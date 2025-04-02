import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    print(selectedIndex);
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black, // Tint for selected items if needed
      unselectedItemColor: Colors.grey, // Tint for unselected items if needed
      elevation: 8.0,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/home_icon.png',
            width: 24,
            height: 24,
            color: Colors.black, // Optional tint
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/tracking_icon.png',
            width: 24,
            height: 24,
            color: selectedIndex == 1 ? Colors.black : Colors.grey, // Optional tint
          ),
          label: 'Tracking',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/notifications_icon.png',
            width: 24,
            height: 24,
            color: selectedIndex == 2 ? Colors.black : Colors.grey, // Optional tint
          ),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/account_icon.png',
            width: 24,
            height: 24,
            color: selectedIndex == 3 ? Colors.black : Colors.grey, // Optional tint
          ),
          label: 'Account',
        ),
      ],
    );
  }
}
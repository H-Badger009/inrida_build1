import 'package:flutter/material.dart';

class DriverBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const DriverBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xFF34978A),
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/home_icon.png',
            width: 24,
            height: 24,
            color: selectedIndex == 0 ? Color(0xFF34978A) : Colors.grey,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/saved.png',
            width: 24,
            height: 24,
            color: selectedIndex == 1 ? Color(0xFF34978A) : Colors.grey,
          ),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
            icon: Image.asset(
            'assets/rides.png',
            width: 24,
            height: 24,
            color: selectedIndex == 2 ? Color(0xFF34978A) : Colors.grey,
          ),
          label: 'Rides',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Image.asset(
                'assets/messages.png',
                width: 24,
                height: 24,
                color: selectedIndex == 3 ? Color(0xFF34978A) : Colors.grey,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/account_icon.png',
            width: 24,
            height: 24,
            color: selectedIndex == 4 ? Color(0xFF34978A) : Colors.grey,
          ),
          label: 'Account',
        ),
      ],
    );
  }
}
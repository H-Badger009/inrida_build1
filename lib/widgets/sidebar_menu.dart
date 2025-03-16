import 'package:flutter/material.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({super.key});

  @override
  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  int _selectedIndex = -1; // No item selected by default

  // Menu items and corresponding icons
  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Drivers', 'icon': Icons.directions_car, 'route': '/drivers'},
    {'title': 'Vehicles', 'icon': Icons.car_rental, 'route': '/vehicles'},
    {'title': 'Performance', 'icon': Icons.bar_chart, 'route': '/performance'},
    {'title': 'Payments', 'icon': Icons.payment, 'route': '/payments'},
    {'title': 'Promotions', 'icon': Icons.campaign, 'route': '/promotions'},
    {'title': 'Live Map', 'icon': Icons.map, 'route': '/'},
  ];

  void _onMenuItemTapped(int index, BuildContext context) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer
    // Navigate to the corresponding screen if a route is defined
    if (_menuItems[index]['route'] != null && _menuItems[index]['route'] != '/') {
      Navigator.pushNamed(context, _menuItems[index]['route']);
    }
    // If 'Live Map' is selected (route '/'), stay on the home screen (no navigation)
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white, // White background as shown in images
        child: Column(
          children: [
            // Header with user profile
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[200], // Light gray background for header
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/profile_image.jpg'), // Placeholder; replace with actual image
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Excel Asaph', // User name from images
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Car Owner', // Role from images
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Menu items
            Expanded(
              child: ListView.builder(
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedIndex == index;
                  return ListTile(
                    leading: Icon(
                      _menuItems[index]['icon'],
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                    title: Text(
                      _menuItems[index]['title'],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : Colors.grey[800],
                      ),
                    ),
                    tileColor: isSelected ? Colors.grey[300] : null, // Highlight selected item
                    onTap: () => _onMenuItemTapped(index, context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
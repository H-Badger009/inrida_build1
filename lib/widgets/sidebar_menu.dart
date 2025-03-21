import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inrida/providers/user_provider.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({super.key});

  @override
  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  int _selectedIndex = -1;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Drivers', 'icon': Icons.directions_car, 'route': '/drivers'},
    {'title': 'Vehicles', 'icon': Icons.car_rental, 'route': '/vehicles'}, // Already correct
    {'title': 'Performance', 'icon': Icons.bar_chart, 'route': '/performance'},
    {'title': 'Payments', 'icon': Icons.payment, 'route': '/payments'},
    {'title': 'Promotions', 'icon': Icons.campaign, 'route': '/promotions'},
    {'title': 'Live Map', 'icon': Icons.map, 'route': '/'},
  ];

  void _onMenuItemTapped(int index, BuildContext context) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
    if (_menuItems[index]['route'] != null && _menuItems[index]['route'] != '/') {
      Navigator.pushNamed(context, _menuItems[index]['route']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProvider>(context).userProfile;

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: 301,
              height: 80,
              margin: const EdgeInsets.only(top: 74, left: 10, right: 10),
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1, color: Colors.grey),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 21.5,
                    backgroundImage: userProfile?.profileImage != null && userProfile!.profileImage!.isNotEmpty
                        ? NetworkImage(userProfile!.profileImage!)
                        : const AssetImage('assets/profile_image.jpg') as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile?.name ?? 'Name',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: -0.01, color: Colors.black, fontFamily: 'DM Sans'),
                      ),
                      Text(
                        userProfile?.role ?? 'Role',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4, letterSpacing: -0.01, fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedIndex == index;
                  return ListTile(
                    leading: Icon(_menuItems[index]['icon'], color: isSelected ? Colors.black : Colors.grey),
                    title: Text(
                      _menuItems[index]['title'],
                      style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.black : Colors.grey[800]),
                    ),
                    tileColor: isSelected ? Colors.grey[300] : null,
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
import 'package:flutter/material.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: const Color(0xFF34978A),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    "https://randomuser.me/api/portraits/men/4.jpg",
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Car Owner",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const Text(
                  "owner@example.com",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home', style: TextStyle(fontFamily: 'DM Sans')),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/car_owner_home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('My Cars', style: TextStyle(fontFamily: 'DM Sans')),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/my_cars');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Trip History', style: TextStyle(fontFamily: 'DM Sans')),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/trip_history');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings', style: TextStyle(fontFamily: 'DM Sans')),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout', style: TextStyle(fontFamily: 'DM Sans')),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inrida/providers/user_provider.dart';
import 'package:inrida/screens/driver/my_car_screen.dart'; // Import the new MyCarScreen

class DriverSideBarMenu extends StatefulWidget {
  const DriverSideBarMenu({super.key});

  @override
  _DriverSideBarMenuState createState() => _DriverSideBarMenuState();
}

class _DriverSideBarMenuState extends State<DriverSideBarMenu> {
  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProvider>(context).userProfile;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header with driver avatar and info
          DrawerHeader(
            decoration: const BoxDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 21.5,
                  backgroundImage:
                      userProfile?.profileImage != null &&
                              userProfile!.profileImage!.isNotEmpty
                          ? NetworkImage(userProfile.profileImage!)
                          : const AssetImage('assets/profile_image.jpg')
                              as ImageProvider,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${userProfile?.firstName ?? ''} ${userProfile?.lastName ?? ''}'
                              .trim()
                              .isNotEmpty
                          ? '${userProfile?.firstName ?? ''} ${userProfile?.lastName ?? ''}'
                              .trim()
                          : 'Name',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      userProfile?.role ?? 'Role',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Menu items with custom icons
          ListTile(
            leading: Image.asset(
              'assets/ph_steering-wheel.png',
              width: 24,
              height: 24,
            ),
            title: const Text(
              'Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer; already on Dashboard
            },
          ),
          ListTile(
            leading: Image.asset(
              'assets/ion_car-sport-outline.png',
              width: 24,
              height: 24,
            ),
            title: const Text(
              'My Car',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyCarScreen()),
              ); // Navigate to MyCarScreen
            },
          ),
          ListTile(
            leading: Image.asset(
              'assets/mingcute_announcement-line (1).png',
              width: 24,
              height: 24,
            ),
            title: const Text(
              'My Rides',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/rides');
            },
          ),
          ListTile(
            leading: Image.asset(
              'assets/mingcute_announcement-line.png',
              width: 24,
              height: 24,
            ),
            title: const Text(
              'Earnings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              // Add navigation to Earnings screen if needed
            },
          ),
          ListTile(
            leading: Image.asset(
              'assets/material-symbols-light_payments-outline.png',
              width: 24,
              height: 24,
            ),
            title: const Text(
              'Rewards',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              // Add navigation to Rewards screen if needed
            },
          ),
          ListTile(
            leading: Image.asset(
              'assets/mingcute_announcement-line (2).png',
              width: 24,
              height: 24,
            ),
            title: const Text(
              'Support',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              // Add navigation to Support screen if needed
            },
          ),
        ],
      ),
    );
  }
}
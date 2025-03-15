// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:inrida/widgets/driver_marker.dart';
import 'package:inrida/widgets/sidebar_menu.dart';
import 'package:inrida/widgets/bottom_nav_bar.dart';
import 'package:inrida/providers/driver_provider.dart';

class CarOwnerHomeScreen extends StatefulWidget {
  const CarOwnerHomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CarOwnerHomeScreenState createState() => _CarOwnerHomeScreenState();
}

class _CarOwnerHomeScreenState extends State<CarOwnerHomeScreen> {
  late GoogleMapController _mapController;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/car_owner_home');
        break;
      case 1:
        Navigator.pushNamed(context, '/tracking');
        break;
      case 2:
        Navigator.pushNamed(context, '/notifications');
        break;
      case 3:
        Navigator.pushNamed(context, '/account');
        break;
    }
  }

  void _moveCameraToPosition(LatLng position) {
    _mapController.animateCamera(CameraUpdate.newLatLng(position));
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);

    return Scaffold(
      drawer: const SidebarMenu(),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7830, -122.4050), // Center of San Francisco
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: driverProvider.drivers.asMap().entries.map((entry) {
              int idx = entry.key;
              var driver = entry.value;
              return Marker(
                markerId: MarkerId('driver_$idx'),
                position: LatLng(driver.latitude, driver.longitude),
                icon: BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(
                  title: driver.firstName,
                  snippet: driver.status,
                ),
                onTap: () {
                  _moveCameraToPosition(LatLng(driver.latitude, driver.longitude));
                },
              );
            }).toSet(),
          ),
          ...driverProvider.drivers.asMap().entries.map((entry) {
            int idx = entry.key;
            var driver = entry.value;
            return Positioned(
              left: 50,
              top: 100 + (idx * 100), // Adjust position for each driver
              child: DriverMarker(
                firstName: driver.firstName,
                isOnline: driver.isOnline,
                status: driver.status,
                avatarUrl: driver.avatarUrl,
              ),
            );
          }).toList(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
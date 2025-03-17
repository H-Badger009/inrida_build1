import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:inrida/widgets/bottom_nav_bar.dart'; // Import the modularized bottom nav bar
import 'package:inrida/widgets/sidebar_menu.dart'; // Import the sidebar menu

class CarOwnerHomeScreen extends StatefulWidget {
  const CarOwnerHomeScreen({super.key});

  @override
  _CarOwnerHomeScreenState createState() => _CarOwnerHomeScreenState();
}

class _CarOwnerHomeScreenState extends State<CarOwnerHomeScreen> {
  late GoogleMapController _mapController;
  final Location _location = Location();
  LatLng? _currentPosition;
  bool _isLoading = true;
  int _selectedIndex = 0; // Default to Home screen (index 0)
  double _mapBearing = 0.0; // Track the map's rotation

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => _isLoading = false);
        return;
      }
    }

    try {
      LocationData locationData = await _location.getLocation();
      setState(() {
        _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching location: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // Already on Home screen, no navigation needed
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

  // Function to reset the map rotation to 0 degrees
  void _resetMapRotation() {
    if (_mapController != null && _currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 14,
            bearing: 0.0, // Reset rotation
          ),
        ),
      );
      setState(() {
        _mapBearing = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenu(), // Keep the side-bar menu as a Drawer
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? const Center(
                  child: Text('Unable to fetch location. Please enable location services.'))
              : Stack(
                  children: [
                    // Map as the background
                    GoogleMap(
                      compassEnabled: false, // Disable default compass
                      zoomControlsEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,
                        zoom: 14,
                        bearing: _mapBearing,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      onCameraMove: (CameraPosition position) {
                        setState(() {
                          _mapBearing = position.bearing;
                        });
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                    ),
                    // Hamburger menu icon at the top-left
                    Positioned(
                      top: 66, // Adjust based on status bar height
                      left: 20,
                      width: 72,
                      height: 72,
                      child: Builder(
                        builder: (context) => GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: Center(
                            child: Icon(
                              Icons.menu,
                              color: Colors.black,
                              size: 35,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Custom compass at the top-right
                    Positioned(
                      top: 66, // Same vertical position as hamburger menu
                      right: 20, // Positioned at the right
                      width: 72, // Same size as hamburger menu
                      height: 72,
                      child: GestureDetector(
                        onTap: _resetMapRotation, // Reset rotation on tap
                        child: Center(
                          child: Transform.rotate(
                            angle: -_mapBearing * (3.14159 / 180), // Rotate based on map bearing
                            child: Icon(
                              Icons.navigation, // Compass-like icon
                              color: Colors.black,
                              size: 35,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:inrida/widgets/driver_side_bar_menu.dart';
import 'package:inrida/widgets/driver_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:inrida/providers/user_provider.dart';
import 'dart:ui'; // For ImageFilter.blur

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  GoogleMapController? _mapController;
  final Location _location = Location();
  LatLng? _currentPosition;
  bool _isLoading = true;
  int _selectedIndex = 0;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
    _requestLocationPermissionAsync();
  }

  void _checkVerificationStatus() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _isVerified = userProvider.userProfile?.isVerified ?? false;
    });
  }

  Future<void> _requestLocationPermissionAsync() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        _showLocationError('Location services are disabled.');
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => _isLoading = false);
        _showLocationError('Location permission denied.');
        return;
      }
    } else if (permissionGranted == PermissionStatus.deniedForever) {
      setState(() => _isLoading = false);
      _showLocationError('Location permission denied permanently.');
      return;
    }

    try {
      LocationData locationData = await _location.getLocation();
      setState(() {
        _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
        _isLoading = false;
      });
      if (_mapController != null) {
        _updateMapCamera();
      }
    } catch (e) {
      print('Location fetch error: $e');
      setState(() => _isLoading = false);
      _showLocationError('Error fetching location: $e');
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _updateMapCamera() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 14,
          ),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    if (!_isVerified) return; // Disable navigation if not verified
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        // Navigator.pushNamed(context, '/saved');
        break;
      case 2:
        Navigator.pushNamed(context, '/rides');
        break;
      case 3:
        // Navigator.pushNamed(context, '/messages');
        break;
      case 4:
        Navigator.pushNamed(context, '/driver_account');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DriverSideBarMenu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? const Center(
                  child: Text('Unable to fetch location. Please enable location services.'),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      compassEnabled: false,
                      zoomControlsEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition ?? const LatLng(0.0, 0.0),
                        zoom: 14,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        _updateMapCamera();
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                    ),
                    if (!_isVerified) ...[
                      // Blur effect over the map
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                      // Overlay message
                      Center(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Please complete your KYC verification to enable features on InRida',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/driver_verify_account')
                                        .then((_) => _checkVerificationStatus());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF34978A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Verify Now',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Menu button
                    Positioned(
                      top: 66,
                      left: 20,
                      width: 50,
                      height: 50,
                      child: Builder(
                        builder: (context) => GestureDetector(
                          onTap: !_isVerified ? () => Scaffold.of(context).openDrawer() : null,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.menu,
                              color: Colors.black,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Notifications button
                    Positioned(
                      top: 66,
                      right: 20,
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: _isVerified
                            ? () => Navigator.pushNamed(context, '/notifications')
                            : null,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.notifications,
                                color: Colors.black,
                                size: 35,
                              ),
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
                                child: const Text(
                                  '2',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Go Online button
                    Positioned(
                      bottom: 80,
                      left: 20,
                      right: 20,
                      child: GestureDetector(
                        onTap: _isVerified
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Driver is now online!')),
                                );
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Icon(Icons.arrow_forward, color: Colors.green),
                              Text(
                                'Go Online',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: DriverBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
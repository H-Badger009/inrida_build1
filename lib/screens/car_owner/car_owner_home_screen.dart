import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:inrida/widgets/bottom_nav_bar.dart';
import 'package:inrida/widgets/sidebar_menu.dart';

class CarOwnerHomeScreen extends StatefulWidget {
  const CarOwnerHomeScreen({super.key});

  @override
  _CarOwnerHomeScreenState createState() => _CarOwnerHomeScreenState();
}

class _CarOwnerHomeScreenState extends State<CarOwnerHomeScreen> {
  GoogleMapController? _mapController; // Nullable, not late
  final Location _location = Location();
  LatLng? _currentPosition;
  bool _isLoading = true;
  int _selectedIndex = 0;
  double _mapBearing = 0.0;

  @override
  void initState() {
    super.initState();
    _requestLocationPermissionAsync();
  }

  Future<void> _requestLocationPermissionAsync() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showLocationError('Location services are disabled.');
        }
        return;
      }
    }

    // Check and request location permission
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showLocationError('Location permission denied.');
        }
        return;
      }
    } else if (permissionGranted == PermissionStatus.deniedForever) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showLocationError(
            'Location permission denied permanently. Please enable it in app settings.');
      }
      return;
    }

    // Fetch location
    try {
      LocationData locationData = await _location.getLocation();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
          _isLoading = false;
        });
        // Update map camera if controller is already initialized
        if (_mapController != null) {
          _updateMapCamera();
        }
      }
    } catch (e) {
      if (mounted) {
        print('Location fetch error: $e');
        setState(() => _isLoading = false);
        _showLocationError('Error fetching location: $e');
      }
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
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

  void _resetMapRotation() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 14,
            bearing: 0.0,
          ),
        ),
      );
      setState(() {
        _mapBearing = 0.0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Map is still loading...')),
      );
    }
  }

  void _updateMapCamera() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 14,
            bearing: _mapBearing,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? const Center(
                  child: Text('Unable to fetch location. Please enable location services.'))
              : Stack(
                  children: [
                    GoogleMap(
                      compassEnabled: false,
                      zoomControlsEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition ?? const LatLng(0.0, 0.0), // Fallback
                        zoom: 14,
                        bearing: _mapBearing,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        print('Map created, initializing controller');
                        _mapController = controller;
                        _updateMapCamera(); // Center map once controller is ready
                      },
                      onCameraMove: (CameraPosition position) {
                        setState(() {
                          _mapBearing = position.bearing;
                        });
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                    ),
                    Positioned(
                      top: 66,
                      left: 20,
                      width: 50,
                      height: 50,
                      child: Builder(
                        builder: (context) => GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
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
                    Positioned(
                      top: 66,
                      right: 20,
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: _resetMapRotation,
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
                          child: Transform.rotate(
                            angle: -_mapBearing * (3.14159 / 180),
                            child: const Icon(
                              Icons.navigation,
                              color: Colors.black,
                              size: 35,
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
    _mapController?.dispose();
    super.dispose();
  }
}
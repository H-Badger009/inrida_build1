import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/foundation.dart'; // For compute
import 'package:inrida/widgets/bottom_nav_bar.dart';
import 'package:inrida/widgets/sidebar_menu.dart';

// Class to hold location data for compute
class LocationDataResult {
  final LatLng? position;
  final String? error;

  LocationDataResult({this.position, this.error});
}

// Function to fetch location off the main thread
Future<LocationDataResult> fetchLocationData(Location location) async {
  try {
    LocationData locationData = await location.getLocation();
    return LocationDataResult(
      position: LatLng(locationData.latitude!, locationData.longitude!),
    );
  } catch (e) {
    return LocationDataResult(error: 'Error fetching location: $e');
  }
}

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

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }
    }

    // Fetch location off the main thread
    LocationDataResult result = await compute(fetchLocationData, _location);

    if (mounted) {
      setState(() {
        if (result.error != null) {
          print(result.error);
          _isLoading = false;
          return;
        }
        _currentPosition = result.position;
        _isLoading = false;
      });
    }
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
      _mapController.animateCamera(
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
    _mapController.dispose();
    super.dispose();
  }
}
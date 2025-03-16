import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart'; // Add this for location services

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

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }
    }

    // Request location permission
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => _isLoading = false);
        return;
      }
    }

    // Fetch the current location
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? const Center(child: Text('Unable to fetch location. Please enable location services.'))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 14,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true, // Show user's location dot
                  myLocationButtonEnabled: true, // Show button to center on user
                ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
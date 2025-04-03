import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inrida/services/car_database_service.dart';
import 'package:inrida/models/vehicle.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:inrida/providers/vehicle_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'package:inrida/screens/search_by_radius_screen.dart';

class AvailableCarsScreen extends StatefulWidget {
  final String location;

  const AvailableCarsScreen({super.key, required this.location});

  @override
  _AvailableCarsScreenState createState() => _AvailableCarsScreenState();
}

class _AvailableCarsScreenState extends State<AvailableCarsScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Vehicle> _availableCars = [];
  final CarDatabaseService _databaseService = CarDatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  LatLng? _initialPosition;
  StreamSubscription<List<Vehicle>>? _carSubscription;
  LatLng? _userLocation;
  BitmapDescriptor? _customCarIcon;

  // Filter state variables
  String? _selectedManufacturer;
  String? _selectedModel;
  String? _selectedYear;
  String? _selectedColor;
  double? _radiusFilter; // Add this for radius filtering

  // Sample manufacturers and models (should ideally be fetched dynamically)
  final Map<String, List<String>> _manufacturersAndModels = {
    'Toyota': ['Camry', 'Corolla', 'RAV4', 'Prius', 'Highlander'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'Pilot', 'Fit'],
    'Ford': ['F-150', 'Mustang', 'Explorer', 'Escape', 'Focus'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLC', 'GLE'],
    'BMW': ['3 Series', '5 Series', 'X3', 'X5', '7 Series'],
    'Volkswagen': ['Golf', 'Passat', 'Tiguan', 'Jetta', 'Atlas'],
  };

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
    _geocodeLocation();
    _fetchAvailableCars();
    _getDeviceLocation();
  }

  Future<void> _loadCustomIcon() async {
    try {
      final BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(24, 15)),
        'assets/marker_icon.png',
      );
      setState(() {
        _customCarIcon = bitmapDescriptor;
      });
    } catch (e) {
      print('Error loading custom icon: $e');
    }
  }

  Future<void> _geocodeLocation() async {
    try {
      if (widget.location.isNotEmpty) {
        List<Location> locations = await locationFromAddress(widget.location);
        if (locations.isNotEmpty) {
          setState(() {
            _initialPosition = LatLng(
              locations.first.latitude,
              locations.first.longitude,
            );
          });
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(_initialPosition!),
          );
        } else {
          await _getDeviceLocation();
        }
      } else {
        await _getDeviceLocation();
      }
    } catch (e) {
      print('Error geocoding location: $e');
      await _getDeviceLocation();
    }
  }

  Future<void> _getDeviceLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied');
      }

      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _userLocation = _initialPosition;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(_initialPosition!));
    } catch (e) {
      setState(() {
        _initialPosition = const LatLng(0.0, 0.0);
        _userLocation = _initialPosition;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(_initialPosition!));
    }
  }

  void _fetchAvailableCars() {
    _carSubscription?.cancel();
    Query query = _firestore
        .collectionGroup('vehicles')
        .where('status', isEqualTo: 'Available');

    bool triedSearching = true;

    // Apply filters
    if (_selectedManufacturer != null) {
      query = query.where('manufacture', isEqualTo: _selectedManufacturer);
    }
    if (_selectedModel != null) {
      query = query.where('model', isEqualTo: _selectedModel);
    }
    if (_selectedYear != null) {
      query = query.where('year', isEqualTo: int.parse(_selectedYear!));
    }
    if (_selectedColor != null) {
      query = query.where('color', isEqualTo: _selectedColor);
    }

    _carSubscription = query
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList();
        })
        .listen(
          (cars) {
            List<Vehicle> filteredCars = cars.where((car) {
              // Location filter
              bool locationMatch = widget.location.isEmpty ||
                  car.location.toLowerCase().contains(widget.location.toLowerCase());
              // Radius filter
              bool radiusMatch = _radiusFilter == null ||
                  (car.coordinates != null &&
                      _calculateDistanceInKm(
                            _initialPosition!,
                            LatLng(car.coordinates!.latitude, car.coordinates!.longitude),
                          ) <=
                          _radiusFilter!);
              return locationMatch && radiusMatch;
            }).toList();

            print('Stream update: ${filteredCars.length} cars available after filters');
            print('Car IDs: ${filteredCars.map((c) => c.id).toList()}');
            triedSearching = false;
            setState(() {
              _availableCars = filteredCars;
              _updateMarkers();
              if (_availableCars.isEmpty) {
                _resetFilters();
              }
            });
          },
          onError: (error) {
            if (_availableCars.isEmpty) {
              setState(() {
                _availableCars = [];
                _markers.clear();
              });
              _resetFilters();
            } else if (triedSearching) {
              setState(() {
                _availableCars = [];
                _markers.clear();
              });
              _resetFilters();
            }
          },
        );
  }

  double _calculateDistanceInKm(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double lat1 = pos1.latitude * math.pi / 180;
    double lat2 = pos2.latitude * math.pi / 180;
    double deltaLat = (pos2.latitude - pos1.latitude) * math.pi / 180;
    double deltaLon = (pos2.longitude - pos1.longitude) * math.pi / 180;

    double a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(deltaLon / 2) * math.sin(deltaLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  void _resetFilters() {
    setState(() {
      _selectedManufacturer = null;
      _selectedModel = null;
      _selectedYear = null;
      _selectedColor = null;
      _radiusFilter = null; // Reset radius filter as well
    });
  }

  void _updateMarkers() {
    print('Updating markers for ${_availableCars.length} cars');
    _markers.clear();
    for (var car in _availableCars) {
      if (car.coordinates != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(car.id),
            position: LatLng(
              car.coordinates!.latitude,
              car.coordinates!.longitude,
            ),
            icon: _customCarIcon ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            onTap: () => _showCarDetails(car),
          ),
        );
      }
    }
  }

  void _showCarDetails(Vehicle car) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          insetPadding: const EdgeInsets.all(16.0),
          child: Container(
            height: 180,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: car.exteriorPhotoUrl.isNotEmpty
                      ? Image.network(
                          car.exteriorPhotoUrl,
                          width: 150,
                          height: 180,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.car_rental,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Text(
                              car.name,
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                color: Color(0xFF202020),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.02,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: GestureDetector(
                              onTap: () => _toggleFavorite(car),
                              child: Icon(
                                _isFavoritedByUser(car)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavoritedByUser(car)
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        car.location,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'DM Sans',
                          color: Color(0xFF707072),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_getDistanceString(car)} away',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'DM Sans',
                          color: Color(0xFF707072),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Verified Owner',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371;
    double lat1 = pos1.latitude * math.pi / 180;
    double lat2 = pos2.latitude * math.pi / 180;
    double deltaLat = (pos2.latitude - pos1.latitude) * math.pi / 180;
    double deltaLon = (pos2.longitude - pos1.longitude) * math.pi / 180;

    double a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;
    double hours = distance / 20;
    double minutes = hours * 60;
    return minutes;
  }

  String _getDistanceString(Vehicle car) {
    if (_userLocation == null || car.coordinates == null) return 'N/A';
    double distanceInMinutes = _calculateDistance(
      _userLocation!,
      LatLng(car.coordinates!.latitude, car.coordinates!.longitude),
    );
    if (distanceInMinutes >= 60) {
      int hours = (distanceInMinutes / 60).floor();
      int minutes = (distanceInMinutes % 60).round();
      return '$hours hr $minutes min';
    } else {
      return '${distanceInMinutes.round()} min';
    }
  }

  bool _isFavoritedByUser(Vehicle car) {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null && car.favoritedBy.contains(user.uid);
  }

  void _toggleFavorite(Vehicle car) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final vehicleProvider = Provider.of<VehicleProvider>(
        context,
        listen: false,
      );
      await vehicleProvider.toggleFavorite(car.id, user.uid);
      _fetchAvailableCars();
    }
  }

  void _resetMapOrientation() {
    if (_mapController != null && _initialPosition != null) {
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _initialPosition!,
          zoom: 11.85,
          bearing: 0,
        ),
      ));
    }
  }

  void _showSearchByRadius() async {
    if (_initialPosition == null) return; // Ensure position is available
    final selectedRadius = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchByRadiusScreen(
          location: widget.location,
          initialPosition: _initialPosition!,
        ),
      ),
    );
    if (selectedRadius != null) {
      setState(() {
        _radiusFilter = selectedRadius;
      });
      _fetchAvailableCars();
    }
  }

  @override
  void dispose() {
    _carSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _initialPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition!,
                    zoom: 11.85,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                  mapToolbarEnabled: true,
                ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(71.83),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5.75,
                              spreadRadius: 1.44,
                              offset: const Offset(0, 0),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 3.38,
                              spreadRadius: -8.62,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 26.14,
                        ),
                      ),
                    ),
                    Container(
                      width: 180,
                      height: 49,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.location.isEmpty ? 'All' : widget.location,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          height: 0.9,
                          letterSpacing: 0,
                          color: Color(0xFF202020),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showFilterMenu,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5.75,
                              spreadRadius: 1.44,
                              offset: const Offset(0, 0),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 3.38,
                              spreadRadius: -8.62,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.settings_input_composite_rounded,
                          color: Colors.black,
                          size: 26.14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 130.0,
            right: 16.0,
            child: GestureDetector(
              onTap: _resetMapOrientation,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5.75,
                      spreadRadius: 1.44,
                      offset: const Offset(0, 0),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 3.38,
                      spreadRadius: -8.62,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.zoom_in_map,
                  color: Colors.black,
                  size: 26.14,
                ),
              ),
            ),
          ),
          Positioned(
            top: 220.0,
            right: 16.0,
            child: GestureDetector(
              onTap: _showSearchByRadius,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5.75,
                      spreadRadius: 1.44,
                      offset: const Offset(0, 0),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 3.38,
                      spreadRadius: -8.62,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.explore,
                  color: Colors.black,
                  size: 26.14,
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.1,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F000000),
                      offset: Offset(0, 0),
                      blurRadius: 5.6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _availableCars.isEmpty
                            ? 'No Results'
                            : '${_availableCars.length} Cars Available',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF202020),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _availableCars.isEmpty
                          ? const Center(
                              child: Text(
                                'No cars found for the selected filters.',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 16,
                                  color: Color(0xFF707072),
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: _availableCars.length,
                              itemBuilder: (context, index) {
                                final car = _availableCars[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  child: InkWell(
                                    onTap: () {},
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(21.16),
                                              ),
                                              child: car.exteriorPhotoUrl
                                                      .isNotEmpty
                                                  ? Image.network(
                                                      car.exteriorPhotoUrl,
                                                      width: double.infinity,
                                                      height: 200,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Container(
                                                      width: double.infinity,
                                                      height: 200,
                                                      color: Colors.grey[300],
                                                      child: const Icon(
                                                        Icons.car_rental,
                                                        size: 100,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _toggleFavorite(car),
                                                child: Icon(
                                                  _isFavoritedByUser(car)
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: _isFavoritedByUser(car)
                                                      ? Colors.red
                                                      : Colors.grey,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      car.name,
                                                      style: const TextStyle(
                                                        fontFamily: 'DM Sans',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 18,
                                                        color:
                                                            Color(0xFF202020),
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                        color:
                                                            Color(0xFF34978A),
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${car.favoriteCount}',
                                                        style: const TextStyle(
                                                          fontFamily: 'DM Sans',
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                car.location,
                                                style: const TextStyle(
                                                  fontFamily: 'DM Sans',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF707072),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${_getDistanceString(car)} away',
                                                style: const TextStyle(
                                                  fontFamily: 'DM Sans',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'Available',
                                                style: TextStyle(
                                                  fontFamily: 'DM Sans',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: Color(0xFF4CAF50),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter Options',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedManufacturer,
                    hint: const Text('Manufacturer'),
                    onChanged: (value) {
                      setState(() {
                        _selectedManufacturer = value;
                        _selectedModel = null; // Reset model when manufacturer changes
                      });
                    },
                    items: _manufacturersAndModels.keys.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  if (_selectedManufacturer != null)
                    DropdownButtonFormField<String>(
                      value: _selectedModel,
                      hint: const Text('Model'),
                      onChanged: (value) {
                        setState(() {
                          _selectedModel = value;
                        });
                      },
                      items:
                          (_manufacturersAndModels[_selectedManufacturer] ?? [])
                              .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  DropdownButtonFormField<String>(
                    value: _selectedYear,
                    hint: const Text('Year'),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                      });
                    },
                    items: List.generate(
                      50,
                      (index) => (DateTime.now().year - index).toString(),
                    ).map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedColor,
                    hint: const Text('Color'),
                    onChanged: (value) {
                      setState(() {
                        _selectedColor = value;
                      });
                    },
                    items: ['Black', 'White', 'Blue', 'Red'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedManufacturer = null;
                            _selectedModel = null;
                            _selectedYear = null;
                            _selectedColor = null;
                          });
                        },
                        child: const Text('Clear Filters'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _fetchAvailableCars();
                        },
                        child: const Text('Apply Filters'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
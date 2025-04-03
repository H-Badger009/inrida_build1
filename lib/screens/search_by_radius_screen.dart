import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchByRadiusScreen extends StatefulWidget {
  final String location;
  final LatLng initialPosition;

  const SearchByRadiusScreen({
    super.key,
    required this.location,
    required this.initialPosition,
  });

  @override
  _SearchByRadiusScreenState createState() => _SearchByRadiusScreenState();
}

class _SearchByRadiusScreenState extends State<SearchByRadiusScreen> {
  GoogleMapController? _mapController;
  double _radius = 1.0; // Default radius in kilometers
  late TextEditingController _radiusController;

  @override
  void initState() {
    super.initState();
    _radiusController = TextEditingController(text: _radius.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map with radius circle and center marker
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition,
              zoom: 11.85,
            ),
            circles: {
              Circle(
                circleId: const CircleId('searchRadius'),
                center: widget.initialPosition,
                radius: _radius * 1000, // Convert km to meters for Google Maps
                fillColor: Colors.green.withOpacity(0.2),
                strokeColor: Colors.green,
                strokeWidth: 1,
              ),
            },
            markers: {
              Marker(
              markerId: const MarkerId('center'),
              position: widget.initialPosition,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              ),
            },
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          // Back button (top-left)
          Positioned(
            top: 55,
            left: 16,
            child: GestureDetector(
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
          ),
          // Location card (top-center)
          Positioned(
            top: 55,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 180,
                height: 49,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            ),
          ),
          // Radius adjustment controls (bottom-center)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Color(0xFFFFFFFF)),
                  onPressed: () {
                    setState(() {
                      if (_radius > 1) _radius -= 1;
                      _radiusController.text = _radius.toStringAsFixed(0);
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF707072),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    elevation: 4,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 220,
                  height: 56,
                  child: TextFormField(
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFFFFFFFF),
                    ),
                    controller: _radiusController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(                      
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(35.31)),
                      ),
                      filled: true,
                      fillColor: Color(0xFF505050),
                    ),
                    onChanged: (value) {
                      final newRadius = double.tryParse(value);
                      if (newRadius != null && newRadius > 0) {
                        setState(() {
                          _radius = newRadius;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF202020)),
                  onPressed: () {
                    setState(() {
                      _radius += 1;
                      _radiusController.text = _radius.toStringAsFixed(0);
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFB9C0C9),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ),
          // Continue button (bottom-right)
          Positioned(
            bottom: 32,
            right: 15,
            left: 15,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _radius);
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(350, 56),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35.31),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
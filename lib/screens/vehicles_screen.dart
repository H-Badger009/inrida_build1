import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inrida/models/vehicle.dart';
import 'package:inrida/widgets/vehicle_card.dart';
import 'package:inrida/screens/add_vehicle_screen.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  String selectedFilter = 'All';
  final ValueNotifier<String> searchNotifier = ValueNotifier('');
  final List<String> filters = ['All', 'Pending', 'Inactive', 'Available', 'In use'];
  Timer? _debounce;

  @override
  void dispose() {
    searchNotifier.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchNotifier.value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view vehicles')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF202020), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vehicles',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            height: 1.4,
            letterSpacing: -0.02,
            color: Color(0xFF202020),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchField(
              onSearchChanged: _onSearchChanged,
              onClear: () => _onSearchChanged(''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters
                    .map((filter) => _buildFilterTab(
                          filter,
                          filter == selectedFilter,
                          () => setState(() => selectedFilter = filter),
                        ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('vehicles')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final vehicles = snapshot.data!.docs.map((doc) => Vehicle.fromFirestore(doc)).toList();
                if (vehicles.isEmpty) {
                  return _buildNoListState(context);
                }
                return _buildFilledState(context, vehicles);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoListState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/empty_list.png', width: 124, height: 124),
          const Text(
            'Empty List',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w500,
              fontSize: 24,
              height: 1.0,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9 - 64,
              child: const Text(
                'Your list is empty and waiting to be filled. Add your vehicles now and let drivers discover the quality, style, and performance you have to offer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  height: 1.0,
                  letterSpacing: 0.0,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              fixedSize: const Size(200, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            ),
            child: const Text(
              'Add Vehicle',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.0,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilledState(BuildContext context, List<Vehicle> vehicles) {
    return ValueListenableBuilder<String>(
      valueListenable: searchNotifier,
      builder: (context, searchText, child) {
        final filteredVehicles = vehicles.where((vehicle) {
          if (selectedFilter != 'All' && vehicle.status != selectedFilter) return false;
          final searchLower = searchText.toLowerCase();
          return vehicle.name.toLowerCase().contains(searchLower) ||
              vehicle.licensePlate.toLowerCase().contains(searchLower) ||
              vehicle.year.toString().contains(searchLower) ||
              vehicle.location.toLowerCase().contains(searchLower);
        }).toList();
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = (constraints.maxWidth / 200).floor();
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredVehicles.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddVehicleCard(context);
                }
                final vehicle = filteredVehicles[index - 1];
                return VehicleCard(vehicle: vehicle);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterTab(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.teal : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(color: isActive ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildAddVehicleCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
      ),
      child: Container(
        width: 165,
        height: 199,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned(
              bottom: 40,
              left: 15,
              child: Text(
                'Add New Vehicle',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  height: 1.4,
                  letterSpacing: -0.02,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 70,
              left: 15,
              child: Image.asset(
                'assets/add_newcar.png',
                width: 31,
                height: 22,
                color: Colors.white,
              ),
            ),
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                width: 49,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2C94C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'ADD +',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 12,
              left: 15,
              child: Icon(
                Icons.more_horiz,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchField extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onClear;

  const SearchField({required this.onSearchChanged, required this.onClear, super.key});

  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      widget.onSearchChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: 'Search name or model',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onClear();
                  _focusNode.requestFocus(); // Keep keyboard open after clearing
                },
              )
            : const Icon(Icons.filter_list),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }
}
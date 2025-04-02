import 'package:flutter/material.dart';
import 'package:inrida/screens/driver/available_cars_screen.dart';
import 'package:inrida/services/car_database_service.dart';

class SearchCarsScreen extends StatefulWidget {
  const SearchCarsScreen({super.key});

  @override
  State<SearchCarsScreen> createState() => _SearchCarsScreenState();
}

class _SearchCarsScreenState extends State<SearchCarsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CarDatabaseService _databaseService = CarDatabaseService();
  String _query = '';
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _query = _searchController.text.trim();
      _showClearButton = _query.isNotEmpty;
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Where?',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF202020),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search locations',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _showClearButton
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                color: Color(0xFF202020),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: StreamBuilder<List<Map<String, String>>>(
                  stream: _databaseService.streamSuggestedLocations(_query),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final locations = snapshot.data ?? [];
                    if (locations.isEmpty) {
                      return const Center(child: Text('No available cars'));
                    }

                    final displayCount = locations.length > 3 ? 3 : locations.length;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayCount,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final location = locations[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.location_pin,
                                color: Colors.black,
                              ),
                              title: Text(
                                location['name']!,
                                style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF202020),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AvailableCarsScreen(
                                      location: location['name']!,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        if (locations.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AvailableCarsScreen(
                                          location: _query.isEmpty ? '' : _query,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'See All',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
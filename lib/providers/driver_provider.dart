import 'package:flutter/material.dart';
import 'package:inrida/models/driver.dart';

class DriverProvider with ChangeNotifier {
  List<Driver> _drivers = [
    Driver(
      firstName: "Javier",
      isOnline: true,
      status: "On Trip",
      latitude: 37.7830,
      longitude: -122.4050,
      avatarUrl: "https://randomuser.me/api/portraits/men/1.jpg",
    ),
    Driver(
      firstName: "Iguadala",
      isOnline: false,
      status: "5 min",
      latitude: 37.7750,
      longitude: -122.4180,
      avatarUrl: "https://randomuser.me/api/portraits/men/2.jpg",
    ),
    Driver(
      firstName: "Antor",
      isOnline: true,
      status: "13 min",
      latitude: 37.7900,
      longitude: -122.4000,
      avatarUrl: "https://randomuser.me/api/portraits/men/3.jpg",
    ),
  ];

  List<Driver> get drivers => _drivers;

  // Simulate real-time updates (for demo purposes)
  void updateDriverLocation(int index, double latitude, double longitude) {
    _drivers[index] = Driver(
      firstName: _drivers[index].firstName,
      isOnline: _drivers[index].isOnline,
      status: _drivers[index].status,
      latitude: latitude,
      longitude: longitude,
      avatarUrl: _drivers[index].avatarUrl,
    );
    notifyListeners();
  }
}
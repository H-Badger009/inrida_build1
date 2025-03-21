import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inrida/models/vehicle.dart';

class VehicleProvider with ChangeNotifier {
  Future<void> addVehicle(Vehicle vehicle) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('vehicles')
            .add(vehicle.toFirestore());
        // No need to update local list or notify listeners; stream will handle UI updates
      } catch (e) {
        print('Error adding vehicle: $e');
      }
    }
  }
}
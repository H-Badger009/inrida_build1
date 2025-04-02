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

  Future<void> toggleFavorite(String vehicleId, String userId) async {
    try {
      DocumentReference vehicleRef = FirebaseFirestore.instance
          .collection('vehicles') // Adjust collection path if needed
          .doc(vehicleId);

      DocumentSnapshot vehicleDoc = await vehicleRef.get();
      if (vehicleDoc.exists) {
        Vehicle vehicle = Vehicle.fromFirestore(vehicleDoc);
        List<String> updatedFavoritedBy = List.from(vehicle.favoritedBy);
        bool isFavorited = updatedFavoritedBy.contains(userId);

        if (isFavorited) {
          updatedFavoritedBy.remove(userId); // Unfavorite
        } else {
          updatedFavoritedBy.add(userId); // Favorite
        }

        await vehicleRef.update({
          'favoritedBy': updatedFavoritedBy,
          'favoriteCount': updatedFavoritedBy.length,
        });
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inrida/models/vehicle.dart';

class CarDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Vehicle>> streamAvailableVehicles(String location) {
    return _firestore
        .collectionGroup('vehicles')
        .where('status', isEqualTo: 'Available')
        .snapshots()
        .map((snapshot) {
          print('New snapshot received with ${snapshot.docs.length} docs');
          snapshot.docChanges.forEach((change) {
            if (change.type == DocumentChangeType.removed) {
              print('Document removed: ${change.doc.id}');
            } else if (change.type == DocumentChangeType.added) {
              print('Document added: ${change.doc.id}');
            } else if (change.type == DocumentChangeType.modified) {
              print('Document modified: ${change.doc.id}');
            }
          });
          return snapshot.docs
              .where(
                (doc) => (doc['location'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(location.toLowerCase()),
              )
              .map((doc) => Vehicle.fromFirestore(doc))
              .toList();
        });
  }

  Stream<List<Map<String, String>>> streamSuggestedLocations(String query) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Car Owner')
        .snapshots()
        .asyncMap((userSnapshot) async {
          List<Map<String, String>> locations = [];

          for (var userDoc in userSnapshot.docs) {
            QuerySnapshot vehicleSnapshot = await userDoc.reference
                .collection('vehicles')
                .where('status', isEqualTo: 'Available')
                .get();

            for (var vehicleDoc in vehicleSnapshot.docs) {
              String location = vehicleDoc['location'] ?? 'Unknown';
              locations.add({'name': location});
            }
          }

          List<Map<String, String>> filteredLocations = locations
              .where(
                (location) => location['name']!.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();

          return query.isEmpty ? filteredLocations.take(3).toList() : filteredLocations;
        });
  }
}
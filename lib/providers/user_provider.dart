import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String? uid;
  String? email;
  String? phone;
  String? name;
  String? profileImage;
  String? location;
  String? about;
  String? role; // Added for role-based navigation
  Map<String, dynamic>? settings;

  UserProfile({
    this.uid,
    this.email,
    this.phone,
    this.name,
    this.profileImage,
    this.location,
    this.about,
    this.role,
    this.settings,
  });

  // Factory to create from Firestore data
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    return UserProfile(
      uid: doc.id,
      email: data?['email'] as String?,
      phone: data?['phone'] as String?,
      name: data?['name'] as String?,
      profileImage: data?['profileImage'] as String?,
      location: data?['location'] as String?,
      about: data?['about'] as String?,
      role: data?['role'] as String?,
      settings: data?['settings'] as Map<String, dynamic>?,
    );
  }

  // Convert to map for Firestore update
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
      'name': name,
      'profileImage': profileImage,
      'location': location,
      'about': about,
      'role': role,
      'settings': settings,
    };
  }
}

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  Future<void> fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        _userProfile = UserProfile.fromFirestore(doc);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void updateUserProfile(UserProfile newProfile) {
    _userProfile = newProfile;
    notifyListeners();
  }

  void clearUserData() {
    _userProfile = null;
    notifyListeners();
  }
}
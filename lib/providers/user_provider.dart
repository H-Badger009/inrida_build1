import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String? uid;
  String? email;
  String? phone;
  String? firstName;
  String? lastName;
  String? profileImage;
  Map<String, String>? location; // Changed to Map<String, String>?
  String? about;
  String? role;
  Map<String, dynamic>? settings;
  bool? isVerified;

  UserProfile({
    this.uid,
    this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.location,
    this.about,
    this.role,
    this.settings,
    this.isVerified,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    return UserProfile(
      uid: doc.id,
      email: data?['email'] as String?,
      phone: data?['phone'] as String?,
      firstName: data?['firstName'] as String?,
      lastName: data?['lastName'] as String?,
      profileImage: data?['profileImage'] as String?,
      location: data?['location'] is Map ? Map<String, String>.from(data!['location']) : null,
      about: data?['about'] as String?,
      role: data?['role'] as String?,
      settings: data?['settings'] as Map<String, dynamic>?,
      isVerified: data?['isVerified'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'location': location,
      'about': about,
      'role': role,
      'settings': settings,
      'isVerified': isVerified,
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
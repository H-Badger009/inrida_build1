import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:inrida/widgets/profile/profile_header.dart';
import 'package:inrida/widgets/profile/profile_info_section.dart';
import 'package:inrida/widgets/profile/profile_about_section.dart';
import 'package:inrida/widgets/profile/profile_settings_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  String? _name;
  String? _profileImage;
  String? _email;
  String? _phone;
  String? _location;
  String? _about;
  bool _pushNotifications = false;
  bool _newsletter = false;
  bool _twoFactorAuth = false;

  XFile? _newImage; // For holding the new image before saving

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _email = userDoc.get('email') ?? '';
            _phone = userDoc.get('phone') ?? '';
            _name = userDoc.get('name') ?? '';
            _profileImage = userDoc.get('profileImage');
            _location = userDoc.get('location') ?? 'City, Country';
            _about = userDoc.get('about') ?? '';
            Map<String, dynamic>? settings = userDoc.get('settings');
            if (settings != null) {
              _pushNotifications = settings['pushNotifications'] ?? false;
              _newsletter = settings['newsletter'] ?? false;
              _twoFactorAuth = settings['twoFactorAuth'] ?? false;
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? imageUrl = _profileImage;

        // Upload new profile image if selected
        if (_newImage != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}.jpg');
          await storageRef.putFile(File(_newImage!.path));
          imageUrl = await storageRef.getDownloadURL();
        }

        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _name,
          'email': _email,
          'phone': _phone,
          'location': _location,
          'about': _about,
          'profileImage': imageUrl,
          'settings': {
            'pushNotifications': _pushNotifications,
            'newsletter': _newsletter,
            'twoFactorAuth': _twoFactorAuth,
          },
        });

        // Update email in Firebase Auth if changed
        if (_email != user.email) {
          await user.updateEmail(_email!);
          await user.sendEmailVerification();
        }

        setState(() {
          _isEditing = false;
          _newImage = null; // Clear the temporary image
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  // Helper to parse City and Country from full address
  String _parseLocation(String fullAddress) {
    if (fullAddress == 'City, Country' || fullAddress.isEmpty) {
      return 'City, Country';
    }
    List<String> parts = fullAddress.split(',');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2].trim()}, ${parts.last.trim()}';
    }
    return fullAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: _isLoading || _email == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(
                    name: _name ?? '',
                    profileImage: _profileImage,
                    isEditing: _isEditing,
                    onNameChanged: (value) => setState(() => _name = value),
                    onImageChanged: (image) => setState(() => _newImage = image),
                  ),
                  const SizedBox(height: 24),
                  ProfileInfoSection(
                    email: _email!,
                    phone: _phone!,
                    location: _parseLocation(_location!),
                    isEditing: _isEditing,
                    onEmailChanged: (value) => setState(() => _email = value),
                    onPhoneChanged: (value) => setState(() => _phone = value),
                    onLocationChanged: (value) => setState(() => _location = value),
                  ),
                  ProfileAboutSection(
                    about: _about ?? '',
                    isEditing: _isEditing,
                    onAboutChanged: (value) => setState(() => _about = value),
                  ),
                  ProfileSettingsSection(
                    pushNotifications: _pushNotifications,
                    newsletter: _newsletter,
                    twoFactorAuth: _twoFactorAuth,
                    isEditing: _isEditing,
                    onPushNotificationsChanged: (value) =>
                        setState(() => _pushNotifications = value),
                    onNewsletterChanged: (value) =>
                        setState(() => _newsletter = value),
                    onTwoFactorAuthChanged: (value) =>
                        setState(() => _twoFactorAuth = value),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isEditing ? _saveProfile : () => setState(() => _isEditing = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'Save Profile' : 'Edit Profile',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
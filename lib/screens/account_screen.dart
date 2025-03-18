import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:inrida/widgets/profile/profile_header.dart';
import 'package:inrida/widgets/profile/profile_info_section.dart';
import 'package:inrida/widgets/profile/profile_about_section.dart';
import 'package:inrida/widgets/profile/profile_settings_section.dart';

class UserData {
  final String? email;
  final String? phone;
  final String? name;
  final String? profileImage;
  final String? location;
  final String? about;
  final Map<String, dynamic>? settings;

  UserData({
    this.email,
    this.phone,
    this.name,
    this.profileImage,
    this.location,
    this.about,
    this.settings,
  });
}

Future<UserData> processUserData(DocumentSnapshot userDoc) async {
  return UserData(
    email: userDoc.get('email') ?? '',
    phone: userDoc.get('phone') ?? '',
    name: userDoc.get('name') ?? '',
    profileImage: userDoc.get('profileImage'),
    location: userDoc.get('location') ?? '',
    about: userDoc.get('about') ?? '',
    settings: userDoc.get('settings') as Map<String, dynamic>?,
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = true;
  String? _name;
  String? _profileImage;
  String? _email;
  String? _phone;
  String? _location;
  String? _about;
  bool _pushNotifications = false;
  bool _newsletter = false;
  bool _twoFactorAuth = false;

  // Initialize controllers directly, no 'late' keyword
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _aboutController = TextEditingController();

  XFile? _newImage;

  @override
  void initState() {
    super.initState();
    _fetchUserDataAsync();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDataAsync() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          UserData processedData = await compute(processUserData, userDoc);
          if (mounted) {
            setState(() {
              _email = processedData.email;
              _phone = processedData.phone;
              _name = processedData.name;
              _profileImage = processedData.profileImage;
              _location = processedData.location;
              _about = processedData.about;
              _nameController.text = _name ?? '';
              _emailController.text = _email ?? '';
              _phoneController.text = _phone ?? '';
              _locationController.text = _location ?? '';
              _aboutController.text = _about ?? '';
              Map<String, dynamic>? settings = processedData.settings;
              if (settings != null) {
                _pushNotifications = settings['pushNotifications'] ?? false;
                _newsletter = settings['newsletter'] ?? false;
                _twoFactorAuth = settings['twoFactorAuth'] ?? false;
              }
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching profile: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? imageUrl = _profileImage;

        if (_newImage != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}.jpg');
          await storageRef.putFile(File(_newImage!.path));
          imageUrl = await storageRef.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          'about': _aboutController.text,
          'profileImage': imageUrl,
          'settings': {
            'pushNotifications': _pushNotifications,
            'newsletter': _newsletter,
            'twoFactorAuth': _twoFactorAuth,
          },
        });

        if (_emailController.text != user.email) {
          await user.updateEmail(_emailController.text);
          await user.sendEmailVerification();
        }

        if (mounted) {
          setState(() {
            _isEditing = false;
            _newImage = null;
            _name = _nameController.text;
            _email = _emailController.text;
            _phone = _phoneController.text;
            _location = _locationController.text;
            _about = _aboutController.text;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
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
      body: _isLoading
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
                    nameController: _nameController,
                    onImageChanged: (image) => setState(() => _newImage = image), newImage: null,
                  ),
                  const SizedBox(height: 24),
                  ProfileInfoSection(
                    emailController: _emailController,
                    phoneController: _phoneController,
                    locationController: _locationController,
                    isEditing: _isEditing,
                    onEmailChanged: (value) => setState(() => _email = value),
                    onPhoneChanged: (value) => setState(() => _phone = value),
                    onLocationChanged: (value) => setState(() => _location = value),
                  ),
                  ProfileAboutSection(
                    aboutController: _aboutController,
                    isEditing: _isEditing,
                    onAboutChanged: (value) => setState(() => _about = value),
                  ),
                  ProfileSettingsSection(
                    pushNotifications: _pushNotifications,
                    newsletter: _newsletter,
                    twoFactorAuth: _twoFactorAuth,
                    isEditing: _isEditing,
                    onPushNotificationsChanged: (value) => setState(() => _pushNotifications = value),
                    onNewsletterChanged: (value) => setState(() => _newsletter = value),
                    onTwoFactorAuthChanged: (value) => setState(() => _twoFactorAuth = value),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isEditing ? _saveProfile : () => setState(() => _isEditing = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        _isEditing ? 'Save Profile' : 'Edit Profile',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:inrida/providers/user_provider.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  XFile? _newImage;

  @override
  void initState() {
    super.initState();
    _syncControllersWithProvider();
  }

  void _syncControllersWithProvider() {
    final userProfile = Provider.of<UserProvider>(context, listen: false).userProfile;
    _nameController.text = userProfile?.name ?? '';
    _emailController.text = userProfile?.email ?? '';
    _phoneController.text = userProfile?.phone ?? '';
    _locationController.text = userProfile?.location ?? '';
    _aboutController.text = userProfile?.about ?? '';
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

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? imageUrl = Provider.of<UserProvider>(context, listen: false).userProfile?.profileImage;

        if (_newImage != null) {
          final storageRef = FirebaseStorage.instance.ref().child('profile_images').child('${user.uid}.jpg');
          await storageRef.putFile(File(_newImage!.path));
          imageUrl = await storageRef.getDownloadURL();
        }

        UserProfile updatedProfile = UserProfile(
          uid: user.uid,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          location: _locationController.text,
          about: _aboutController.text,
          profileImage: imageUrl,
          role: Provider.of<UserProvider>(context, listen: false).userProfile?.role,
          settings: {
            'pushNotifications': Provider.of<UserProvider>(context, listen: false).userProfile?.settings?['pushNotifications'] ?? false,
            'newsletter': Provider.of<UserProvider>(context, listen: false).userProfile?.settings?['newsletter'] ?? false,
            'twoFactorAuth': Provider.of<UserProvider>(context, listen: false).userProfile?.settings?['twoFactorAuth'] ?? false,
          },
        );

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updatedProfile.toMap());

        if (_emailController.text != user.email) {
          await user.verifyBeforeUpdateEmail(_emailController.text);
        }

        Provider.of<UserProvider>(context, listen: false).updateUserProfile(updatedProfile);

        if (mounted) {
          setState(() {
            _isEditing = false;
            _newImage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProvider>(context).userProfile;

    return Scaffold(
      backgroundColor: Colors.white, // Match the design
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // Set the height of the AppBar
        child: Container(
          color: Colors.white, // Match the background
          padding: const EdgeInsets.only(top: 90.0), // Add padding for status bar
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
          Icons.arrow_back_ios, // Match the arrow from login_screen.dart
          color: Colors.black, // Match the design
          size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Profile',
            style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
            ),
          ),
          const SizedBox(width: 48), // Placeholder for alignment
        ],
          ),
        ),
      ),
      body: userProfile == null
          ? const Center(child: Text('No user data available'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40), // Add space to lower the header
                  ProfileHeader(
                    name: userProfile.name ?? '',
                    profileImage: userProfile.profileImage,
                    newImage: _newImage,
                    isEditing: _isEditing,
                    nameController: _nameController,
                    onImageChanged: (image) => setState(() => _newImage = image),
                  ),
                  const SizedBox(height: 24),
                  ProfileInfoSection(
                    emailController: _emailController,
                    phoneController: _phoneController,
                    locationController: _locationController,
                    isEditing: _isEditing,
                    onEmailChanged: (value) {},
                    onPhoneChanged: (value) {},
                    onLocationChanged: (value) {},
                  ),
                  ProfileAboutSection(
                    aboutController: _aboutController,
                    isEditing: _isEditing,
                    onAboutChanged: (value) {},
                  ),
                  ProfileSettingsSection(
                    pushNotifications: userProfile.settings?['pushNotifications'] ?? false,
                    newsletter: userProfile.settings?['newsletter'] ?? false,
                    twoFactorAuth: userProfile.settings?['twoFactorAuth'] ?? false,
                    isEditing: _isEditing,
                    onPushNotificationsChanged: (value) => setState(() {
                      userProfile.settings?['pushNotifications'] = value;
                    }),
                    onNewsletterChanged: (value) => setState(() {
                      userProfile.settings?['newsletter'] = value;
                    }),
                    onTwoFactorAuthChanged: (value) => setState(() {
                      userProfile.settings?['twoFactorAuth'] = value;
                    }),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : (_isEditing ? _saveProfile : () => setState(() => _isEditing = true)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
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
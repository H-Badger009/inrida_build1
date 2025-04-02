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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _townController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  XFile? _newImage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _syncControllersWithProvider();
  }

  void _syncControllersWithProvider() {
    final userProfile = Provider.of<UserProvider>(context, listen: false).userProfile;
    _firstNameController.text = userProfile?.firstName ?? '';
    _lastNameController.text = userProfile?.lastName ?? '';
    _emailController.text = userProfile?.email ?? '';
    _phoneController.text = userProfile?.phone ?? '';
    final location = userProfile?.location is Map ? userProfile?.location as Map<String, dynamic>? : {};
    _streetAddressController.text = location?['streetAddress'] ?? '';
    _townController.text = location?['town'] ?? '';
    _cityController.text = location?['city'] ?? '';
    _countryController.text = location?['country'] ?? '';
    _postalCodeController.text = location?['postalCode'] ?? '';
    _aboutController.text = userProfile?.about ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetAddressController.dispose();
    _townController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('No user logged in');

        String? imageUrl = Provider.of<UserProvider>(context, listen: false).userProfile?.profileImage;

        if (_newImage != null) {
          final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg');
          await storageRef.putFile(File(_newImage!.path));
          imageUrl = await storageRef.getDownloadURL();
        }

        final Map<String, String> location = {
          'streetAddress': _streetAddressController.text.trim(),
          'town': _townController.text.trim(),
          'city': _cityController.text.trim(),
          'country': _countryController.text.trim(),
          'postalCode': _postalCodeController.text.trim(),
        };

        final UserProfile updatedProfile = UserProfile(
          uid: user.uid,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: user.email, // Use original email, as it's non-editable
          phone: _phoneController.text.trim(),
          location: location,
          about: _aboutController.text.trim(),
          profileImage: imageUrl,
          role: Provider.of<UserProvider>(context, listen: false).userProfile?.role,
          settings: {
            'pushNotifications': Provider.of<UserProvider>(context, listen: false).userProfile?.settings?['pushNotifications'] ?? false,
            'newsletter': Provider.of<UserProvider>(context, listen: false).userProfile?.settings?['newsletter'] ?? false,
            'twoFactorAuth': Provider.of<UserProvider>(context, listen: false).userProfile?.settings?['twoFactorAuth'] ?? false,
          },
        );

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updatedProfile.toMap());

        Provider.of<UserProvider>(context, listen: false).updateUserProfile(updatedProfile);

        if (mounted) {
          setState(() {
            _isEditing = false;
            _newImage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Provider.of<UserProvider>(context, listen: false).clearUserData();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProvider>(context).userProfile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 90.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
      body: userProfile == null
          ? const Center(child: Text('No user data available'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    ProfileHeader(
                      name: '${userProfile.firstName ?? ''} ${userProfile.lastName ?? ''}'.trim(),
                      profileImage: userProfile.profileImage,
                      newImage: _newImage,
                      isEditing: _isEditing,
                      nameController: _firstNameController,
                      onImageChanged: (image) => setState(() => _newImage = image),
                    ),
                    const SizedBox(height: 24),
                    ProfileInfoSection(
                      emailController: _emailController,
                      phoneController: _phoneController,
                      streetAddressController: _streetAddressController,
                      townController: _townController,
                      cityController: _cityController,
                      countryController: _countryController,
                      postalCodeController: _postalCodeController,
                      isEditing: _isEditing,
                      onPhoneChanged: (value) {},
                      onStreetAddressChanged: (value) {},
                      onTownChanged: (value) {},
                      onCityChanged: (value) {},
                      onCountryChanged: (value) {},
                      onPostalCodeChanged: (value) {}, onEmailChanged: (String ) {  },
                    ),
                    ProfileAboutSection(
                      aboutController: _aboutController,
                      isEditing: _isEditing,
                      onAboutChanged: (value) {},
                    ),
                    const SizedBox(height: 16),
                    // **Payment Section**
                    const Text(
                      'Payment',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.5,
                        letterSpacing: 0.0,
                        color: Color(0xFF202020),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        // Placeholder for navigation to payment methods screen
                        // Navigator.pushNamed(context, '/payment_methods');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF34978A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.credit_card,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payment Methods',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      height: 1.5,
                                      letterSpacing: 0.0,
                                      color: Color(0xFF202020),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Add or remove payment methods',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      height: 1.5,
                                      letterSpacing: 0.0,
                                      color: Color(0xFF606060),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        onPressed: _isLoading
                            ? null
                            : (_isEditing ? _saveProfile : () => setState(() => _isEditing = true)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            ),
                            fixedSize: const Size(286, 48),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isEditing ? 'Save Profile' : 'Edit Profile',
                                style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // **Logout Button**
                    Center(
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFDCDC),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          fixedSize: const Size(286, 48),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Color(0xFFF44336), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF44336),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
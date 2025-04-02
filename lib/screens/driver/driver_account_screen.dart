import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:inrida/providers/user_provider.dart';

class DriverAccountScreen extends StatefulWidget {
  const DriverAccountScreen({super.key});

  @override
  _DriverAccountScreenState createState() => _DriverAccountScreenState();
}

class _DriverAccountScreenState extends State<DriverAccountScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isEditing = false;

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
    _locationController.text = userProfile?.location as String? ?? '';
    _aboutController.text = userProfile?.about ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    super.dispose();
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

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          'about': _aboutController.text,
        });
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    required bool editable,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.5,
            letterSpacing: 0.0,
            color: Color(0xFF606060),
          ),
        ),
        const SizedBox(height: 4),
        if (editable)
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            validator: validator ??
                (isRequired
                    ? (value) => value!.isEmpty ? '$label is required' : null
                    : null),
          )
        else
          Text(
            controller.text,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.5,
              letterSpacing: 0.0,
              color: Color(0xFF202020),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProvider>(context).userProfile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            height: 1.5,
            letterSpacing: 0,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
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
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 43,
                            backgroundImage: userProfile.profileImage != null &&
                                    userProfile.profileImage!.isNotEmpty
                                ? NetworkImage(userProfile.profileImage!)
                                : const AssetImage('assets/profile_image.jpg') as ImageProvider,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${userProfile.firstName ?? ''} ${userProfile.lastName ?? ''}'.trim(),
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              height: 1.5,
                              letterSpacing: 0,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F7FA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Verify Your Account',
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          height: 1.5,
                                          letterSpacing: 0,
                                          color: Color(0xFF34978A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Complete verification to unlock all features',
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          height: 1.5,
                                          letterSpacing: 0.0,
                                          color: Color(0xFF707072),
                                        ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/driver_verify_account');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF34978A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    fixedSize: const Size(99, 35),
                                    padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                                  ),
                                  child: const Text(
                                    'Verify Now',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      height: 1.5,
                                      letterSpacing: 0.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Personal Information Section
                    const Text(
                      'Personal Information',
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
                    _buildField(
                      'First Name',
                      _firstNameController,
                      editable: _isEditing,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First Name is required';
                        }
                        if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                          return 'Only letters are allowed';
                        }
                        if (value.length < 2) {
                          return 'Minimum 2 characters required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildField(
                      'Last Name',
                      _lastNameController,
                      editable: _isEditing,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last Name is required';
                        }
                        if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                          return 'Only letters are allowed';
                        }
                        if (value.length < 2) {
                          return 'Minimum 2 characters required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildField('Email', _emailController, editable: false),
                    const SizedBox(height: 8),
                    _buildField(
                      'Phone',
                      _phoneController,
                      editable: _isEditing,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone is required';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Enter a valid 10-digit phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildField(
                      'Location',
                      _locationController,
                      editable: _isEditing,
                      isRequired: true,
                    ),

                    const SizedBox(height: 16),

                    // About Section
                    const Text(
                      'About',
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
                    if (_isEditing)
                      TextFormField(
                        controller: _aboutController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Tell us about yourself',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      )
                    else
                      Text(
                        _aboutController.text,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.5,
                          letterSpacing: 0.0,
                          color: Color(0xFF606060),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Payment Section
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

                    // Settings Section
                    const Text(
                      'Settings',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Push Notifications',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  height: 1.5,
                                  letterSpacing: 0.0,
                                  color: Color(0xFF202020),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Get notified about new messages',
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
                        Switch(
                          value: userProfile.settings?['pushNotifications'] ?? false,
                          onChanged: _isEditing
                              ? (value) {
                                  setState(() {
                                    userProfile.settings?['pushNotifications'] = value;
                                  });
                                  final uid = FirebaseAuth.instance.currentUser?.uid;
                                  if (uid != null) {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .update({'settings.pushNotifications': value});
                                  }
                                }
                              : null,
                          activeColor: const Color(0xFF26A69A),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Newsletter',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  height: 1.5,
                                  letterSpacing: 0.0,
                                  color: Color(0xFF202020),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Receive weekly updates',
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
                        Switch(
                          value: userProfile.settings?['newsletter'] ?? false,
                          onChanged: _isEditing
                              ? (value) {
                                  setState(() {
                                    userProfile.settings?['newsletter'] = value;
                                  });
                                  final uid = FirebaseAuth.instance.currentUser?.uid;
                                  if (uid != null) {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .update({'settings.newsletter': value});
                                  }
                                }
                              : null,
                          activeColor: const Color(0xFF26A69A),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Two-Factor Authentication',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  height: 1.5,
                                  letterSpacing: 0.0,
                                  color: Color(0xFF202020),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Enhanced account security',
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
                        Switch(
                          value: userProfile.settings?['twoFactorAuth'] ?? false,
                          onChanged: _isEditing
                              ? (value) {
                                  setState(() {
                                    userProfile.settings?['twoFactorAuth'] = value;
                                  });
                                  final uid = FirebaseAuth.instance.currentUser?.uid;
                                  if (uid != null) {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .update({'settings.twoFactorAuth': value});
                                  }
                                }
                              : null,
                          activeColor: const Color(0xFF26A69A),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_isEditing) {
                            _saveProfile();
                          } else {
                            setState(() {
                              _isEditing = true;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34978A),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          fixedSize: const Size(286, 48),
                        ),
                        child: Text(
                          _isEditing ? 'Save Profile' : 'Edit Profile',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
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
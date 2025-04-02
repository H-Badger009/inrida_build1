import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inrida/screens/document_details_screen.dart';

class DriverVerifyAccountScreen extends StatefulWidget {
  const DriverVerifyAccountScreen({super.key});

  @override
  _DriverVerifyAccountScreenState createState() => _DriverVerifyAccountScreenState();
}

class _DriverVerifyAccountScreenState extends State<DriverVerifyAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _gender = '';
  String _referralCode = '';
  String _driverLicenseNumber = '';
  XFile? _profilePicture;
  XFile? _driverLicense;
  DateTime? _driverLicenseExpiry;

  Future<String?> _uploadImage(XFile image, String folder) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          'users/${user.uid}/$folder/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await storageRef.putFile(File(image.path));
        return await storageRef.getDownloadURL();
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return null;
  }

  Future<void> _pickImage(String field) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (field == 'profile') {
          _profilePicture = image;
        } else if (field == 'license') {
          _driverLicense = image;
          _navigateToDocumentDetails('license');
        }
      });
    }
  }

  void _navigateToDocumentDetails(String documentType) async {
    final DateTime? expiryDate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentDetailsScreen(documentType: documentType),
      ),
    );
    if (expiryDate != null) {
      setState(() {
        if (documentType == 'license') {
          _driverLicenseExpiry = expiryDate;
        }
      });
    }
  }

  Future<void> _verifyAccount() async {
    if (_formKey.currentState!.validate() && _validateDocuments()) {
      final profilePictureUrl =
          _profilePicture != null ? await _uploadImage(_profilePicture!, 'profile') : '';
      final driverLicenseUrl =
          _driverLicense != null ? await _uploadImage(_driverLicense!, 'license') : '';

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'firstName': _firstName,
          'lastName': _lastName,
          'gender': _gender,
          'referralCode': _referralCode,
          'driverLicenseNumber': _driverLicenseNumber,
          'profilePictureUrl': profilePictureUrl,
          'driverLicenseUrl': driverLicenseUrl,
          'driverLicenseExpiry': _driverLicenseExpiry,
          'isVerified': true,
        });
      }
      Navigator.pop(context);
    }
  }

  bool _validateDocuments() {
    if (_profilePicture == null || _driverLicense == null || _driverLicenseExpiry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents and provide expiry dates'),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verify Account',
          style: TextStyle(
            color: Color(0xFF202020),
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            height: 1.4,
            letterSpacing: -0.02,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.02,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'To ensure safety and compliance, please complete your account verification.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.4,
                  letterSpacing: -0.02,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'First name *',
                _firstName,
                (value) => setState(() => _firstName = value!),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Last name *',
                _lastName,
                (value) => setState(() => _lastName = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdownField('Gender', _gender, [
                'Male',
                'Female',
                'Other',
              ], (value) => setState(() => _gender = value!)),
              const SizedBox(height: 8),
              const Text(
                'If you select your gender as Female, we may send you communications specific to women drivers.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.4,
                  letterSpacing: -0.02,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Referral code (optional)',
                _referralCode,
                (value) => setState(() => _referralCode = value!),
              ),
              const SizedBox(height: 8),
              const Text(
                'If you were invited by someone, enter their referral code.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.4,
                  letterSpacing: -0.02,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Driver Information',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.02,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your national ID & license details would be kept private.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.4,
                  letterSpacing: -0.02,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Driver license number *',
                _driverLicenseNumber,
                (value) => setState(() => _driverLicenseNumber = value!),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add the ID number on your Driver license.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.4,
                  letterSpacing: -0.02,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              _buildUploadField(
                'Driver’s profile picture *',
                _profilePicture,
                () => _pickImage('profile'),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Upload a clear portrait photo (not a full body photo) of yourself that shows the full face, front view, with eyes open on a white background. No Cap or glasses. Visit ',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.4,
                          letterSpacing: -0.02,
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(
                        text: 'Sample Portrait Photo',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.4,
                          letterSpacing: -0.02,
                          color: Color(0xFF78BE20),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: '.',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.4,
                          letterSpacing: -0.02,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildUploadField(
                'Driver’s license *',
                _driverLicense,
                () => _pickImage('license'),
                const Text(
                  'Upload a clear driver license showing the license number, your name and date of birth.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.4,
                    letterSpacing: -0.02,
                    color: Colors.grey,
                  ),
                ),
                _driverLicenseExpiry,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _verifyAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                    fixedSize: const Size(350, 56),
                  ),
                  child: const Text(
                    'Verify Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label.split(' *')[0],
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.4,
                letterSpacing: -0.02,
                color: Color(0xFF000000),
              ),
            ),
            if (label.contains('*'))
              const Text(
                ' *',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.02,
                  color: Color(0xFFFF565C),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          validator: (value) => value!.isEmpty && label.contains('*') ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            height: 1.4,
            letterSpacing: -0.02,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          hint: Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.4,
              letterSpacing: -0.02,
            ),
          ),
          onChanged: onChanged,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadField(
    String label,
    XFile? file,
    VoidCallback onTap,
    Widget helperWidget, [
    DateTime? expiryDate,
  ]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label.split(' *')[0],
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.4,
                letterSpacing: -0.02,
              ),
            ),
            if (label.contains('*'))
              const Text(
                ' *',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.02,
                  color: Color(0xFFFF565C),
                ),
              ),
          ],
        ),
        Padding(padding: const EdgeInsets.only(top: 8.0), child: helperWidget),
        const SizedBox(height: 15),
        file == null
            ? GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 150,
                  height: 124,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(80),
                        ),
                        child: Image.asset('assets/upload_file.png'),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Upload file',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.4,
                          letterSpacing: -0.01,
                          color: const Color(0xFF606060),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.4,
                            letterSpacing: -0.01,
                            color: Color(0xFF202020),
                          ),
                        ),
                        if (label.toLowerCase().contains('license')) ...[
                          if (expiryDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Expires: ${expiryDate.day.toString().padLeft(2, '0')}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year}',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                height: 1.4,
                                letterSpacing: -0.01,
                                color: Color(0xFF202020),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => _navigateToDocumentDetails('license'),
                              child: Text(
                                'Add expiry date',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 15.46,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Uploaded',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 1.4,
                                letterSpacing: -0.02,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Color(0xFF202020),
                      size: 20,
                    ),
                    onPressed: () => setState(() {
                      if (label.toLowerCase().contains('profile')) {
                        _profilePicture = null;
                      } else if (label.toLowerCase().contains('license')) {
                        _driverLicense = null;
                        _driverLicenseExpiry = null;
                      }
                    }),
                  ),
                ],
              ),
      ],
    );
  }
}
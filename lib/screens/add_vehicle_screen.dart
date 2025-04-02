import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart'; // Added for geocoding
import 'package:cloud_firestore/cloud_firestore.dart'; // For GeoPoint
import 'package:inrida/providers/vehicle_provider.dart';
import 'package:inrida/models/vehicle.dart';
import 'package:inrida/screens/document_details_screen.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  String _year = '';
  String _manufacturer = '';
  String _model = '';
  String _licensePlate = '';
  String _color = '';
  String _address = ''; // New field for full address
  XFile? _exteriorPhoto;
  XFile? _interiorPhoto;
  XFile? _ownershipCertificate;
  XFile? _roadworthinessCertificate;
  XFile? _licenseCertificate;
  XFile? _hackneyPermit;
  DateTime? _roadworthinessExpiry;
  DateTime? _licenseExpiry;
  DateTime? _hackneyExpiry;

  // Map of manufacturers and their respective models
  final Map<String, List<String>> _manufacturersAndModels = {
    'Toyota': ['Camry', 'Corolla', 'RAV4', 'Prius', 'Highlander'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'Pilot', 'Fit'],
    'Ford': ['F-150', 'Mustang', 'Explorer', 'Escape', 'Focus'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLC', 'GLE'],
    'BMW': ['3 Series', '5 Series', 'X3', 'X5', '7 Series'],
    'Volkswagen': ['Golf', 'Passat', 'Tiguan', 'Jetta', 'Atlas'],
  };

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
        switch (field) {
          case 'exterior':
            _exteriorPhoto = image;
            break;
          case 'interior':
            _interiorPhoto = image;
            break;
          case 'ownership':
            _ownershipCertificate = image;
            break;
          case 'roadworthiness':
            _roadworthinessCertificate = image;
            _navigateToDocumentDetails('roadworthiness');
            break;
          case 'license':
            _licenseCertificate = image;
            _navigateToDocumentDetails('license');
            break;
          case 'hackney':
            _hackneyPermit = image;
            _navigateToDocumentDetails('hackney');
            break;
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
        switch (documentType) {
          case 'roadworthiness':
            _roadworthinessExpiry = expiryDate;
            break;
          case 'license':
            _licenseExpiry = expiryDate;
            break;
          case 'hackney':
            _hackneyExpiry = expiryDate;
            break;
        }
      });
    }
  }

  Future<void> _addVehicle() async {
    if (_formKey.currentState!.validate() && _validateDocuments()) {
      // Geocode the address to get coordinates
      GeoPoint? coordinates;
      try {
        List<Location> locations = await locationFromAddress(_address);
        if (locations.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Unable to find location for the provided address')),
          );
          return;
        }
        coordinates = GeoPoint(locations.first.latitude, locations.first.longitude);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error geocoding address: $e')),
        );
        return;
      }

      // Upload images and get URLs
      final exteriorPhotoUrl =
          _exteriorPhoto != null ? await _uploadImage(_exteriorPhoto!, 'exterior') : '';
      final interiorPhotoUrl =
          _interiorPhoto != null ? await _uploadImage(_interiorPhoto!, 'interior') : '';
      final ownershipCertificateUrl = _ownershipCertificate != null
          ? await _uploadImage(_ownershipCertificate!, 'ownership')
          : '';
      final roadworthinessCertificateUrl = _roadworthinessCertificate != null
          ? await _uploadImage(_roadworthinessCertificate!, 'roadworthiness')
          : '';
      final licenseCertificateUrl =
          _licenseCertificate != null ? await _uploadImage(_licenseCertificate!, 'license') : '';
      final hackneyPermitUrl =
          _hackneyPermit != null ? await _uploadImage(_hackneyPermit!, 'hackney') : '';

      final vehicle = Vehicle(
        id: '', // Will be set by Firestore
        name: '$_manufacturer $_model',
        manufacture: _manufacturer,
        model: _model,
        color: _color,
        licensePlate: _licensePlate,
        exteriorPhotoUrl: exteriorPhotoUrl ?? '',
        interiorPhotoUrl: interiorPhotoUrl ?? '',
        ownershipCertificateUrl: ownershipCertificateUrl ?? '',
        roadworthinessCertificateUrl: roadworthinessCertificateUrl ?? '',
        licenseCertificateUrl: licenseCertificateUrl ?? '',
        hackneyPermitUrl: hackneyPermitUrl ?? '',
        year: int.parse(_year),
        mileage: 0,
        location: _address, // Use user-input address
        listedDate: DateTime.now(),
        status: 'Pending',
        roadworthinessExpiry: _roadworthinessExpiry,
        licenseExpiry: _licenseExpiry,
        hackneyExpiry: _hackneyExpiry,
        coordinates: coordinates, // Store geocoded coordinates
      );
      await Provider.of<VehicleProvider>(context, listen: false).addVehicle(vehicle);
      Navigator.pop(context);
    }
  }

  bool _validateDocuments() {
    if (_exteriorPhoto == null ||
        _interiorPhoto == null ||
        _ownershipCertificate == null ||
        _roadworthinessCertificate == null ||
        _licenseCertificate == null ||
        _hackneyPermit == null ||
        _roadworthinessExpiry == null ||
        _licenseExpiry == null ||
        _hackneyExpiry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all documents and provide expiry dates')),
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
          'Add Vehicle',
          style: TextStyle(
            color: Colors.black,
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
                'Vehicle Information',
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
                'We\'re legally required to ask you for some documents to add your vehicle. Documents scans and quality photos are accepted.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.4,
                  letterSpacing: -0.02,
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Vehicle year *',
                _year,
                List.generate(50, (index) => (DateTime.now().year - index).toString()),
                (value) => setState(() => _year = value!),
              ),
              const SizedBox(height: 16),
              _buildManufacturerAndModelSection(),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'If you don\'t find your vehicle model from the list, then let us know at ',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.4,
                        letterSpacing: -0.02,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'help@inrida.com',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.4,
                        letterSpacing: -0.02,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationColor: Color(0xFF78BE20),
                        color: Color(0xFF78BE20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'License plate *',
                _licensePlate,
                (value) => setState(() => _licensePlate = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Vehicle color *',
                _color,
                ['Black', 'White', 'Blue', 'Red'],
                (value) => setState(() => _color = value!),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Vehicle location (full address) *',
                _address,
                (value) => setState(() => _address = value!),
              ), // New address field
              const SizedBox(height: 16),
              _buildUploadField(
                'Exterior photo of your car *',
                _exteriorPhoto,
                () => _pickImage('exterior'),
                'Upload a clear exterior photo that captures the plate number.',
              ),
              const SizedBox(height: 16),
              _buildUploadField(
                'Interior photo of your car *',
                _interiorPhoto,
                () => _pickImage('interior'),
                'Provide a clear interior photo of your car.',
              ),
              const SizedBox(height: 16),
              _buildUploadField(
                'Proof of car ownership certificate *',
                _ownershipCertificate,
                () => _pickImage('ownership'),
                'Picture of ownership certificate',
              ),
              const SizedBox(height: 16),
              _buildUploadField(
                'Certificate of roadworthiness *',
                _roadworthinessCertificate,
                () => _pickImage('roadworthiness'),
                'Picture of roadworthiness certificate',
                _roadworthinessExpiry,
              ),
              const SizedBox(height: 16),
              _buildUploadField(
                'Vehicle license certificate *',
                _licenseCertificate,
                () => _pickImage('license'),
                'Upload the vehicle license document of the car',
                _licenseExpiry,
              ),
              const SizedBox(height: 16),
              _buildUploadField(
                'Hackney Permit *',
                _hackneyPermit,
                () => _pickImage('hackney'),
                'Picture of Hackney Permit.',
                _hackneyExpiry,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _addVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
                    fixedSize: const Size(350, 56),
                  ),
                  child: const Text('Add Vehicle', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
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
            const SizedBox(width: 4),
            if (label.contains('*'))
              const Text(
                '*',
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
        DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          hint: Text(
            label.split(' *')[0],
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
          validator: (value) => value == null && label.contains('*') ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    Function(String?) onChanged,
  ) {
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
            const SizedBox(width: 4),
            if (label.contains('*'))
              const Text(
                '*',
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
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          validator: (value) => value!.isEmpty && label.contains('*') ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildManufacturerAndModelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Vehicle manufacturer and model',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.4,
                letterSpacing: -0.02,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
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
        DropdownButtonFormField<String>(
          value: _manufacturer.isEmpty ? null : _manufacturer,
          hint: const Text(
            'Manufacturer',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.4,
              letterSpacing: -0.02,
            ),
          ),
          onChanged: (value) => setState(() {
            _manufacturer = value!;
            _model = '';
          }),
          items: _manufacturersAndModels.keys.map((String value) {
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
          validator: (value) => value == null ? 'This field is required' : null,
        ),
        const SizedBox(height: 16),
        if (_manufacturer.isNotEmpty)
          DropdownButtonFormField<String>(
            value: _model.isEmpty ? null : _model,
            hint: const Text('Model'),
            onChanged: (value) => setState(() => _model = value!),
            items: (_manufacturersAndModels[_manufacturer] ?? []).map((String value) {
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
            validator: (value) => value == null && _manufacturer.isNotEmpty ? 'This field is required' : null,
          ),
      ],
    );
  }

  Widget _buildUploadField(
    String label,
    XFile? file,
    VoidCallback onTap,
    String helperText, [
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
            const SizedBox(width: 4),
            if (label.contains('*'))
              const Text(
                '*',
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
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.9,
                ),
                child: Text(
                  helperText,
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
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
                      const SizedBox(height: 8),
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
                    icon: const Icon(Icons.delete, color: Color(0xFF202020), size: 20),
                    onPressed: () => setState(() {
                      if (label.toLowerCase().contains('roadworthiness')) {
                        _roadworthinessCertificate = null;
                        _roadworthinessExpiry = null;
                      }
                      if (label.toLowerCase().contains('license')) {
                        _licenseCertificate = null;
                        _licenseExpiry = null;
                      }
                      if (label.toLowerCase().contains('hackney')) {
                        _hackneyPermit = null;
                        _hackneyExpiry = null;
                      }
                      if (label.toLowerCase().contains('exterior')) _exteriorPhoto = null;
                      if (label.toLowerCase().contains('interior')) _interiorPhoto = null;
                      if (label.toLowerCase().contains('ownership')) _ownershipCertificate = null;
                    }),
                  ),
                ],
              ),
      ],
    );
  }
}
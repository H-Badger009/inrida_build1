import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String name;
  final String licensePlate; // Added field
  final String exteriorPhotoUrl;
  final String interiorPhotoUrl;
  final String ownershipCertificateUrl;
  final String roadworthinessCertificateUrl;
  final String licenseCertificateUrl;
  final String hackneyPermitUrl;
  final int year;
  final int mileage;
  final String location;
  final DateTime listedDate;
  final String status;
  final DateTime? roadworthinessExpiry; // Added field
  final DateTime? licenseExpiry; // Added field
  final DateTime? hackneyExpiry; // Added field

  Vehicle({
    required this.id,
    required this.name,
    required this.licensePlate,
    required this.exteriorPhotoUrl,
    required this.interiorPhotoUrl,
    required this.ownershipCertificateUrl,
    required this.roadworthinessCertificateUrl,
    required this.licenseCertificateUrl,
    required this.hackneyPermitUrl,
    required this.year,
    required this.mileage,
    required this.location,
    required this.listedDate,
    required this.status,
    this.roadworthinessExpiry,
    this.licenseExpiry,
    this.hackneyExpiry,
  });

  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      name: data['name'] ?? '',
      licensePlate: data['licensePlate'] ?? '', // New field
      exteriorPhotoUrl: data['exteriorPhotoUrl'] ?? '',
      interiorPhotoUrl: data['interiorPhotoUrl'] ?? '',
      ownershipCertificateUrl: data['ownershipCertificateUrl'] ?? '',
      roadworthinessCertificateUrl: data['roadworthinessCertificateUrl'] ?? '',
      licenseCertificateUrl: data['licenseCertificateUrl'] ?? '',
      hackneyPermitUrl: data['hackneyPermitUrl'] ?? '',
      year: data['year'] ?? 0,
      mileage: data['mileage'] ?? 0,
      location: data['location'] ?? '',
      listedDate: (data['listedDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'Pending',
      roadworthinessExpiry: data['roadworthinessExpiry'] != null
          ? (data['roadworthinessExpiry'] as Timestamp).toDate()
          : null, // Handle nullable field
      licenseExpiry: data['licenseExpiry'] != null
          ? (data['licenseExpiry'] as Timestamp).toDate()
          : null, // Handle nullable field
      hackneyExpiry: data['hackneyExpiry'] != null
          ? (data['hackneyExpiry'] as Timestamp).toDate()
          : null, // Handle nullable field
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'licensePlate': licensePlate, // New field
      'exteriorPhotoUrl': exteriorPhotoUrl,
      'interiorPhotoUrl': interiorPhotoUrl,
      'ownershipCertificateUrl': ownershipCertificateUrl,
      'roadworthinessCertificateUrl': roadworthinessCertificateUrl,
      'licenseCertificateUrl': licenseCertificateUrl,
      'hackneyPermitUrl': hackneyPermitUrl,
      'year': year,
      'mileage': mileage,
      'location': location,
      'listedDate': Timestamp.fromDate(listedDate),
      'status': status,
      'roadworthinessExpiry': roadworthinessExpiry != null
          ? Timestamp.fromDate(roadworthinessExpiry!)
          : null, // Store nullable field
      'licenseExpiry': licenseExpiry != null
          ? Timestamp.fromDate(licenseExpiry!)
          : null, // Store nullable field
      'hackneyExpiry': hackneyExpiry != null
          ? Timestamp.fromDate(hackneyExpiry!)
          : null, // Store nullable field
    };
  }
}
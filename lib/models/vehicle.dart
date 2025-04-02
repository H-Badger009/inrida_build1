import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String name;
  final String licensePlate;
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
  final DateTime? roadworthinessExpiry;
  final DateTime? licenseExpiry;
  final DateTime? hackneyExpiry;
  final GeoPoint? coordinates;
  final int favoriteCount;
  final List<String> favoritedBy;
  final String manufacture; // Added for filtering
  final String model; // Added for filtering
  final String color; // Added for filtering

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
    this.coordinates,
    this.favoriteCount = 0,
    this.favoritedBy = const [],
    required this.manufacture,
    required this.model,
    required this.color,
  });

  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      name: data['name'] ?? '',
      licensePlate: data['licensePlate'] ?? '',
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
          : null,
      licenseExpiry: data['licenseExpiry'] != null
          ? (data['licenseExpiry'] as Timestamp).toDate()
          : null,
      hackneyExpiry: data['hackneyExpiry'] != null
          ? (data['hackneyExpiry'] as Timestamp).toDate()
          : null,
      coordinates: data['coordinates'] != null ? data['coordinates'] as GeoPoint : null,
      favoriteCount: data['favoriteCount'] ?? 0,
      favoritedBy: List<String>.from(data['favoritedBy'] ?? []),
      manufacture: data['manufacture'] ?? '',
      model: data['model'] ?? '',
      color: data['color'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'licensePlate': licensePlate,
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
          : null,
      'licenseExpiry': licenseExpiry != null ? Timestamp.fromDate(licenseExpiry!) : null,
      'hackneyExpiry': hackneyExpiry != null ? Timestamp.fromDate(hackneyExpiry!) : null,
      'coordinates': coordinates,
      'favoriteCount': favoriteCount,
      'favoritedBy': favoritedBy,
      'manufacture': manufacture,
      'model': model,
      'color': color,
    };
  }
}
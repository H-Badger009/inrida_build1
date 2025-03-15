class Driver {
  final String firstName;
  final bool isOnline;
  final String status; // "On Trip" or time duration (e.g., "5 min")
  final double latitude;
  final double longitude;
  final String avatarUrl; // Placeholder for avatar image

  Driver({
    required this.firstName,
    required this.isOnline,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.avatarUrl,
  });
}
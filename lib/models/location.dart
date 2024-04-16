class Location {
  final String name;
  final String imagePath;
  final String landmark;
  final String details;
  final double latitude; // Define latitude property
  final double longitude; // Define longitude property

  Location({
    required this.name,
    required this.imagePath,
    required this.landmark,
    required this.details,
    required this.latitude,
    required this.longitude,
  });
}

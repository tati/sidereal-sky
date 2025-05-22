class EphemerisData {
  final DateTime timestamp;
  final double longitude;
  final double latitude;
  final double range;

  EphemerisData({
    required this.timestamp,
    required this.longitude,
    required this.latitude,
    required this.range,
  });

  @override
  String toString() {
    return 'Time: $timestamp, Lon: $longitude, Lat: $latitude, Range: $range';
  }
}

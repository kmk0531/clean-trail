class TouristSpot {
  final String name;
  final String category; // '관광지' or '음식점' or '카페'
  final String distance;
  final String imageUrl;
  final double latitude;
  final double longitude;

  const TouristSpot({
    required this.name,
    required this.category,
    required this.distance,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });
}

class PloggingCourse {
  final String id;
  final String title;
  final int durationMinutes;
  final String difficulty; // '상', '중', '하'
  final int rewardPoints;
  final double distanceKm;
  final String description;
  final List<TouristSpot> recommendedSpots;
  final List<Map<String, double>> pathCoordinates; // [{'lat': 37.x, 'lng': 128.x}, ...]
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;

  const PloggingCourse({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.difficulty,
    required this.rewardPoints,
    required this.distanceKm,
    required this.description,
    required this.recommendedSpots,
    required this.pathCoordinates,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
  });
}


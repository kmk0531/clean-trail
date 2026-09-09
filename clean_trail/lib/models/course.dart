class TouristSpot {
  final String name;
  final String category; // '관광지' or '음식점' or '카페'
  final String distance;
  final String imageUrl;
  final double latitude;
  final double longitude;

  /// 한국관광공사 TourAPI의 contentid. API로 가져온 데이터가 아니면 null.
  final String? contentId;

  const TouristSpot({
    required this.name,
    required this.category,
    required this.distance,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.contentId,
  });

  /// TourAPI locationBasedList2 / areaBasedList2 응답의 item 하나를 파싱.
  /// distanceMeters는 API의 dist 필드(정수 문자열, 미터 단위) 또는
  /// 좌표 기반 계산값을 넘겨받아 "0.3km" 같은 표시용 문자열로 변환한다.
  factory TouristSpot.fromTourApiJson(
    Map<String, dynamic> json, {
    String? distanceOverride,
  }) {
    final contentTypeId = json['contenttypeid']?.toString();
    final distMeters = double.tryParse(json['dist']?.toString() ?? '');

    return TouristSpot(
      name: (json['title'] as String?)?.trim() ?? '이름 미상 관광지',
      category: _categoryFromContentTypeId(contentTypeId),
      distance: distanceOverride ?? _formatDistance(distMeters),
      imageUrl: (json['firstimage'] as String?)?.isNotEmpty == true
          ? json['firstimage'] as String
          : (json['firstimage2'] as String?) ?? '',
      latitude: double.tryParse(json['mapy']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['mapx']?.toString() ?? '') ?? 0.0,
      contentId: json['contentid']?.toString(),
    );
  }

  static String _formatDistance(double? meters) {
    if (meters == null) return '';
    if (meters < 1000) return '${meters.round()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  // TourAPI contenttypeid: 12=관광지, 14=문화시설, 15=행사/축제,
  // 25=여행코스, 28=레포츠, 32=숙박, 38=쇼핑, 39=음식점
  static String _categoryFromContentTypeId(String? contentTypeId) {
    switch (contentTypeId) {
      case '39':
        return '음식점';
      case '32':
        return '숙박';
      case '38':
        return '쇼핑';
      case '28':
        return '레포츠';
      default:
        return '관광지';
    }
  }
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

  PloggingCourse copyWith({List<TouristSpot>? recommendedSpots}) {
    return PloggingCourse(
      id: id,
      title: title,
      durationMinutes: durationMinutes,
      difficulty: difficulty,
      rewardPoints: rewardPoints,
      distanceKm: distanceKm,
      description: description,
      recommendedSpots: recommendedSpots ?? this.recommendedSpots,
      pathCoordinates: pathCoordinates,
      startLatitude: startLatitude,
      startLongitude: startLongitude,
      endLatitude: endLatitude,
      endLongitude: endLongitude,
    );
  }
}


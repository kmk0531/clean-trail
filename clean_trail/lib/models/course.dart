import '../services/durunubi_api_service.dart';

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
      case '25':
        return '여행코스';
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

  /// 한국관광공사 두루누비 코스(DurunubiCourse) + 실제 GPX 경로 좌표를
  /// 조합해 [PloggingCourse]를 만든다.
  ///
  /// 두루누비는 리워드 포인트 개념이 없으므로, 코스 거리(km)에 비례해
  /// 앱 자체 규칙으로 계산한다 (기존 목업 코스들의 "약 5P/km" 수준에
  /// 맞춤 — 해안 산책로 2.4km→12P, 호수 둘레길 3.1km→15P 참고).
  /// GPX 파싱에 실패해 [gpxCoordinates]가 비어 있으면 시작/종료 좌표만이라도
  /// 유효하도록 첫/끝 좌표를 각각 (0, 0)으로 둔다 — 이 경우 호출부에서
  /// 지도에 표시하지 않고 목록 카드로만 노출하는 것을 권장한다.
  factory PloggingCourse.fromDurunubi(
    DurunubiCourse course, {
    required List<Map<String, double>> gpxCoordinates,
    List<TouristSpot> recommendedSpots = const [],
  }) {
    final hasPath = gpxCoordinates.isNotEmpty;
    final start = hasPath ? gpxCoordinates.first : const {'lat': 0.0, 'lng': 0.0};
    final end = hasPath ? gpxCoordinates.last : const {'lat': 0.0, 'lng': 0.0};

    return PloggingCourse(
      id: 'durunubi_${course.courseId}',
      title: course.name,
      durationMinutes: course.durationMinutes,
      difficulty: course.levelLabel,
      rewardPoints: (course.distanceKm * 5).round().clamp(5, 50),
      distanceKm: course.distanceKm,
      description: course.summary.isNotEmpty
          ? course.summary
          : '${course.sigun} 지역의 두루누비 인증 도보여행 코스입니다.',
      recommendedSpots: recommendedSpots,
      pathCoordinates: gpxCoordinates,
      startLatitude: start['lat']!,
      startLongitude: start['lng']!,
      endLatitude: end['lat']!,
      endLongitude: end['lng']!,
    );
  }
}


import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/course.dart';

/// 한국관광공사 TourAPI(국문 관광정보 서비스, KorService2) 연동 서비스.
///
/// 공공데이터포털(data.go.kr)에서 발급받은 서비스키가 필요하다.
/// 키는 소스코드에 직접 넣지 않고, 빌드/실행 시 아래처럼 주입한다:
///
///   flutter run --dart-define=TOUR_API_KEY=발급받은키
///   flutter build apk --release --dart-define=TOUR_API_KEY=발급받은키
///
/// 키가 주입되지 않은 상태([isConfigured]가 false)에서는 모든 조회 메서드가
/// 빈 리스트를 반환한다 — 앱은 하드코딩된 목업 데이터로 정상 동작을 유지한다.
class TourApiService {
  TourApiService._();
  static final TourApiService instance = TourApiService._();

  static const String _baseUrl = 'https://apis.data.go.kr/B551011/KorService2';

  // data.go.kr에서 발급받은 "일반 인증키(Decoding)"를 사용한다.
  static const String _serviceKey =
      String.fromEnvironment('TOUR_API_KEY', defaultValue: '');

  bool get isConfigured => _serviceKey.isNotEmpty;

  /// 위치 기반 주변 관광정보 조회 (locationBasedList2).
  ///
  /// [latitude], [longitude]는 기준 좌표, [radiusMeters]는 조회 반경(m, 최대 20000).
  /// [contentTypeId]를 지정하면 특정 유형만 조회한다 (예: '12' 관광지, '39' 음식점).
  Future<List<TouristSpot>> fetchNearbySpots({
    required double latitude,
    required double longitude,
    int radiusMeters = 2000,
    String? contentTypeId,
    int numOfRows = 20,
  }) async {
    if (!isConfigured) return [];

    final params = {
      'serviceKey': _serviceKey,
      'MobileOS': 'AND',
      'MobileApp': 'CleanTrail',
      '_type': 'json',
      'numOfRows': '$numOfRows',
      'pageNo': '1',
      'arrange': 'E', // E: 거리순 정렬
      'mapX': '$longitude',
      'mapY': '$latitude',
      'radius': '$radiusMeters',
      if (contentTypeId != null) 'contentTypeId': contentTypeId,
    };

    return _fetchSpots('locationBasedList2', params);
  }

  /// 지역 기반 관광정보 조회 (areaBasedList2).
  ///
  /// [areaCode]는 TourAPI 지역코드(예: 부산 '6', 강원 '32').
  Future<List<TouristSpot>> fetchSpotsByArea({
    required String areaCode,
    String? sigunguCode,
    String? contentTypeId,
    int numOfRows = 20,
  }) async {
    if (!isConfigured) return [];

    final params = {
      'serviceKey': _serviceKey,
      'MobileOS': 'AND',
      'MobileApp': 'CleanTrail',
      '_type': 'json',
      'numOfRows': '$numOfRows',
      'pageNo': '1',
      'arrange': 'C', // C: 수정일순 정렬 (인기순 O 필요시 'P')
      'areaCode': areaCode,
      if (sigunguCode != null) 'sigunguCode': sigunguCode,
      if (contentTypeId != null) 'contentTypeId': contentTypeId,
    };

    return _fetchSpots('areaBasedList2', params);
  }

  Future<List<TouristSpot>> _fetchSpots(
    String operation,
    Map<String, String> params,
  ) async {
    // serviceKey는 공공데이터포털에서 이미 URL 인코딩된 형태로 발급되는 경우가
    // 많아 Uri.replace의 자동 인코딩과 겹치면 이중 인코딩이 될 수 있다.
    // 그래서 serviceKey만 쿼리 문자열에 직접 붙이고 나머지만 인코딩한다.
    final otherParams = Map<String, String>.from(params)..remove('serviceKey');
    final query = otherParams.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    final url = Uri.parse(
      '$_baseUrl/$operation?serviceKey=${params['serviceKey']}&$query',
    );

    try {
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        debugPrint('TourAPI HTTP 오류: ${response.statusCode}');
        return [];
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final header = decoded['response']?['header'];
      if (header?['resultCode'] != '0000') {
        debugPrint('TourAPI 응답 오류: ${header?['resultMsg']}');
        return [];
      }

      final items = decoded['response']?['body']?['items']?['item'];
      if (items == null) return [];

      // 결과가 1건이면 item이 배열이 아니라 객체 하나로 오는 경우가 있다.
      final itemList = items is List ? items : [items];

      return itemList
          .whereType<Map<String, dynamic>>()
          .map((item) => TouristSpot.fromTourApiJson(item))
          .where((spot) => spot.latitude != 0.0 && spot.longitude != 0.0)
          .toList();
    } catch (e) {
      debugPrint('TourAPI 호출 실패 ($operation): $e');
      return [];
    }
  }
}

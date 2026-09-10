import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

/// 한국관광공사 두루누비(Durunubi) 정보 서비스 연동 서비스.
///
/// 걷기/자전거 코스와 실제 GPX 경로를 제공하는 API로, TourAPI(KorService2)와는
/// 별도의 서비스이므로 data.go.kr에서 "한국관광공사_두루누비 정보 서비스"를
/// 별도로 활용신청해야 한다 (서비스키 자체는 공공데이터포털 인증키로 동일).
///
/// 참고: 한국관광공사_TourAPI활용매뉴얼(두루누비)_v4.1
///
///   flutter run --dart-define=DURUNUBI_API_KEY=발급받은키
///   flutter build apk --release --dart-define=DURUNUBI_API_KEY=발급받은키
///
/// 키가 주입되지 않은 상태([isConfigured]가 false)에서는 모든 조회 메서드가
/// 빈 리스트를 반환한다 — 앱은 하드코딩된 목업 데이터로 정상 동작을 유지한다.
class DurunubiApiService {
  DurunubiApiService._();
  static final DurunubiApiService instance = DurunubiApiService._();

  static const String _baseUrl = 'https://apis.data.go.kr/B551011/Durunubi';

  static const String _serviceKey =
      String.fromEnvironment('DURUNUBI_API_KEY', defaultValue: '');

  bool get isConfigured => _serviceKey.isNotEmpty;

  /// 코스 목록 조회 (courseList).
  ///
  /// [crsKorNm]으로 코스명 검색, [crsLevel]로 난이도(1:하/2:중/3:상) 필터,
  /// [brdDiv]로 걷기/자전거(DNWW/DNBW) 필터가 가능하다. 기본은 걷기길(DNWW)만
  /// 조회한다 — 플로깅 앱 특성상 자전거길은 대상이 아니다.
  Future<List<DurunubiCourse>> fetchCourses({
    String? crsKorNm,
    int? crsLevel,
    String brdDiv = 'DNWW',
    int numOfRows = 20,
    int pageNo = 1,
  }) async {
    if (!isConfigured) return [];

    final params = {
      'serviceKey': _serviceKey,
      'MobileOS': 'AND',
      'MobileApp': 'CleanTrail',
      '_type': 'json',
      'numOfRows': '$numOfRows',
      'pageNo': '$pageNo',
      'brdDiv': brdDiv,
      if (crsKorNm != null) 'crsKorNm': crsKorNm,
      if (crsLevel != null) 'crsLevel': '$crsLevel',
    };

    return _fetchCourseList(params);
  }

  Future<List<DurunubiCourse>> _fetchCourseList(Map<String, String> params) async {
    // serviceKey는 이미 URL 인코딩된 형태로 발급되는 경우가 많아, 나머지
    // 파라미터만 인코딩하고 serviceKey는 그대로 붙인다 (이중 인코딩 방지).
    final otherParams = Map<String, String>.from(params)..remove('serviceKey');
    final query = otherParams.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    final url = Uri.parse(
      '$_baseUrl/courseList?serviceKey=${params['serviceKey']}&$query',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        debugPrint('두루누비 API HTTP 오류: ${response.statusCode}');
        return [];
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final header = decoded['response']?['header'];
      if (header?['resultCode'] != '0000') {
        debugPrint('두루누비 API 응답 오류: ${header?['resultMsg']}');
        return [];
      }

      final rawItems = decoded['response']?['body']?['items'];
      // 검색결과 0건이면 items가 빈 문자열("")로 오는 경우가 있다
      // (TourAPI 계열에서 공통으로 확인된 동작).
      if (rawItems == null || rawItems is! Map) return [];

      final items = rawItems['item'];
      if (items == null) return [];

      final itemList = items is List ? items : [items];

      return itemList
          .whereType<Map<String, dynamic>>()
          .map((item) => DurunubiCourse.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('두루누비 API 호출 실패 (courseList): $e');
      return [];
    }
  }

  /// [DurunubiCourse.gpxUrl]이 가리키는 GPX 파일을 내려받아 경로 좌표
  /// 리스트로 파싱한다. GPX가 없거나(빈 문자열) 다운로드/파싱에 실패하면
  /// 빈 리스트를 반환한다 — 호출부는 이 경우 기존 목업 경로를 유지하면 된다.
  Future<List<Map<String, double>>> fetchGpxCoordinates(String gpxUrl) async {
    if (gpxUrl.isEmpty) return [];

    try {
      final response =
          await http.get(Uri.parse(gpxUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        debugPrint('두루누비 GPX 다운로드 실패: HTTP ${response.statusCode}');
        return [];
      }

      final document = XmlDocument.parse(utf8.decode(response.bodyBytes));

      // GPX 표준: <trkpt lat=".." lon="..">가 경로점, <rtept>는 경유점.
      // 두루누비 응답은 보통 트랙(trk/trkseg/trkpt) 형식이지만, 일부 코스는
      // 루트(rte/rtept) 형식으로 내려올 수 있어 둘 다 지원한다.
      var points = document.findAllElements('trkpt');
      if (points.isEmpty) {
        points = document.findAllElements('rtept');
      }

      return points
          .map((pt) {
            final lat = double.tryParse(pt.getAttribute('lat') ?? '');
            final lng = double.tryParse(pt.getAttribute('lon') ?? '');
            if (lat == null || lng == null) return null;
            return {'lat': lat, 'lng': lng};
          })
          .whereType<Map<String, double>>()
          .toList();
    } catch (e) {
      debugPrint('두루누비 GPX 파싱 실패 ($gpxUrl): $e');
      return [];
    }
  }
}

/// 두루누비 courseList 오퍼레이션의 코스 한 건.
class DurunubiCourse {
  final String courseId; // crsIdx
  final String name; // crsKorNm
  final double distanceKm; // crsDstnc
  final int durationMinutes; // crsTotlRqrmHour (분 단위로 내려온다)
  final int level; // crsLevel: 1=하, 2=중, 3=상
  final String cycle; // crsCycle: 순환형/비순환형
  final String summary; // crsSummary
  final String sigun; // 행정구역
  final String gpxUrl; // gpxpath

  const DurunubiCourse({
    required this.courseId,
    required this.name,
    required this.distanceKm,
    required this.durationMinutes,
    required this.level,
    required this.cycle,
    required this.summary,
    required this.sigun,
    required this.gpxUrl,
  });

  /// 코스 난이도를 앱 전역에서 쓰는 '상'/'중'/'하' 표기로 변환.
  String get levelLabel {
    switch (level) {
      case 1:
        return '하';
      case 3:
        return '상';
      default:
        return '중';
    }
  }

  factory DurunubiCourse.fromJson(Map<String, dynamic> json) {
    return DurunubiCourse(
      courseId: json['crsIdx']?.toString() ?? '',
      name: (json['crsKorNm'] as String?)?.trim() ?? '이름 미상 코스',
      distanceKm: double.tryParse(json['crsDstnc']?.toString() ?? '') ?? 0.0,
      durationMinutes: int.tryParse(json['crsTotlRqrmHour']?.toString() ?? '') ?? 0,
      level: int.tryParse(json['crsLevel']?.toString() ?? '') ?? 2,
      cycle: (json['crsCycle'] as String?) ?? '',
      summary: (json['crsSummary'] as String?) ?? (json['crsContents'] as String?) ?? '',
      sigun: (json['sigun'] as String?) ?? '',
      gpxUrl: (json['gpxpath'] as String?) ?? '',
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/course.dart';
import '../models/coupon.dart';
import '../models/clean_log.dart';
import '../models/trash_item.dart';
import '../services/tour_api_service.dart';
import '../services/durunubi_api_service.dart';
import '../data/durunubi_course_mapping.dart';
import '../services/trash_classifier_service.dart';
import '../services/firestore_service.dart';

class AppState extends ChangeNotifier {
  // Navigation & Onboarding State
  bool _onboarded = false;
  bool get onboarded => _onboarded;

  bool _locationPermissionGranted = false;
  bool get locationPermissionGranted => _locationPermissionGranted;

  int _currentTab = 0; // 0: Home, 1: Ranking, 2: Clean Log, 3: Profile
  int get currentTab => _currentTab;

  // User Authentication State (New)
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _userEmail;
  String? get userEmail => _userEmail;

  String? _userName;
  String? get userName => _userName;

  String? _loginType; // 'email', 'google', 'naver'
  String get loginType => _loginType ?? 'none';

  // 가상 사용자 위치 관련 필드 (New)
  double _userLatitude = 35.1796; // 부산 기본값
  double get userLatitude => _userLatitude;

  double _userLongitude = 129.0756;
  double get userLongitude => _userLongitude;

  String _userLocationName = '부산광역시청 일대 (가상)';
  String get userLocationName => _userLocationName;

  // TourAPI 지역코드 (areaBasedList2용). 가상 위치 프리셋에만 매핑되어 있다.
  // areaBasedList2는 지역코드 기반 조회만 지원하고, locationBasedList2(좌표기반)는
  // 여행코스(contentTypeId=25) 데이터를 반환하지 않는 것이 확인되어 이 필드가 필요하다.
  String _userAreaCode = '6'; // 부산
  String get userAreaCode => _userAreaCode;

  // Courses list
  List<PloggingCourse> _courses = [];
  List<PloggingCourse> get courses => _courses;

  // 한국관광공사 TourAPI 연동 상태 (New)
  bool _isLoadingNearbySpots = false;
  bool get isLoadingNearbySpots => _isLoadingNearbySpots;

  // 주변 도보여행 코스 추천 (TourAPI contentTypeId=25, New)
  List<TouristSpot> _nearbyWalkingCourses = [];
  List<TouristSpot> get nearbyWalkingCourses => _nearbyWalkingCourses;

  bool _isLoadingWalkingCourses = false;
  bool get isLoadingWalkingCourses => _isLoadingWalkingCourses;

  // 한국관광공사 두루누비 코스 (실제 GPX 경로 포함, New)
  List<DurunubiCourse> _durunubiCourses = [];
  List<DurunubiCourse> get durunubiCourses => _durunubiCourses;

  bool _isLoadingDurunubiCourses = false;
  bool get isLoadingDurunubiCourses => _isLoadingDurunubiCourses;

  // 누적 수거량 기준 랭킹 (Firestore users 컬렉션 집계, New)
  List<RankingEntry> _ranking = [];
  List<RankingEntry> get ranking => _ranking;

  bool _isLoadingRanking = false;
  bool get isLoadingRanking => _isLoadingRanking;

  PloggingCourse? _selectedCourse;
  PloggingCourse? get selectedCourse => _selectedCourse;

  // Active Plogging State
  bool _isMissionActive = false;
  bool get isMissionActive => _isMissionActive;

  DateTime? _missionStartTime;
  DateTime? get missionStartTime => _missionStartTime;

  int _elapsedSeconds = 0;
  int get elapsedSeconds => _elapsedSeconds;

  Timer? _missionTimer;

  // Trash item photo log — 미션 중 촬영한 쓰레기 사진 및 분류 결과 목록 (New)
  final List<TrashItem> _trashItems = [];
  List<TrashItem> get trashItems => List.unmodifiable(_trashItems);

  bool _isCapturingTrashPhoto = false;
  bool get isCapturingTrashPhoto => _isCapturingTrashPhoto;

  final ImagePicker _imagePicker = ImagePicker();

  // AI Verdict details
  String _verificationState = 'idle'; // 'idle', 'processing', 'success', 'pending'
  String get verificationState => _verificationState;

  // Coupons & logs
  List<Coupon> _coupons = [];
  List<Coupon> get coupons => _coupons;

  List<PloggingLog> _logs = [];
  List<PloggingLog> get logs => _logs;

  // Stats
  int _totalPoints = 240;
  int get totalPoints => _totalPoints;

  double _totalWeightKg = 3.5;
  double get totalWeightKg => _totalWeightKg;

  int _totalMissionCount = 18;
  int get totalMissionCount => _totalMissionCount;

  AppState() {
    _initializeMockData();
    _loadSession(); // 기기 내 저장된 유저 세션 정보 로딩
    refreshNearbySpots(); // 초기 위치 기준 한국관광공사 관광정보 로딩 (키 미설정 시 무동작)
    refreshNearbyWalkingCourses(); // 초기 위치 기준 주변 도보여행 코스 추천 로딩 (키 미설정 시 무동작)
    refreshDurunubiCourses(); // 두루누비 걷기코스(실제 GPX 경로) 로딩 (키 미설정 시 무동작)
    fetchRanking(); // 누적 수거량 기준 랭킹 로딩
  }

  /// Firestore users 컬렉션에서 누적 수거량(totalWeightKg) 기준 상위 랭킹을
  /// 가져온다. 실제 가입자가 적을 때는 목록이 짧게(또는 나 혼자) 나올 수
  /// 있는데, 그건 정상 동작이다 — 이전의 5명 하드코딩 목업을 실제 집계로
  /// 대체하는 것이 목적이라 데이터 양은 이번 범위가 아니다.
  Future<void> fetchRanking() async {
    _isLoadingRanking = true;
    notifyListeners();

    try {
      _ranking = await FirestoreService.instance.fetchTopRankedUsers();
    } finally {
      _isLoadingRanking = false;
      notifyListeners();
    }
  }

  // Firebase Auth 세션 로딩 — 앱을 새로 켰을 때 이미 로그인된 사용자가
  // 있으면(Firebase Auth가 기기에 세션을 유지) 그 사용자로 바로 복귀한다.
  // 계정/세션의 단일 진실 공급원은 Firebase Auth이며, 프로필/통계/기록은
  // Firestore(users/{uid})에 있다 — SharedPreferences는 더 이상 세션에
  // 관여하지 않는다.
  Future<void> _loadSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _hydrateFromFirebaseUser(user);
  }

  /// FirebaseAuth의 User 객체로부터 앱 상태(로그인 정보 + Firestore 프로필)를
  /// 채운다. 로그인/회원가입/세션 복구가 모두 이 메서드로 수렴한다.
  Future<void> _hydrateFromFirebaseUser(User user) async {
    _isLoggedIn = true;
    // 익명 로그인(구글/네이버 데모 폴백)은 user.email이 항상 null이라, 호출부가
    // 미리 세팅해둔 _userEmail(데모용 표시 이메일)을 그대로 둔다. 이메일/구글
    // 정식 로그인은 user.email이 실제 값을 갖고 있으니 그걸 우선한다.
    _userEmail = user.email ?? _userEmail ?? '';
    _userName = user.displayName ?? _userEmail?.split('@').first ?? '사용자';
    _loginType = _loginType ?? 'email';
    _onboarded = true;
    notifyListeners();

    // Firestore에 프로필 문서가 없으면 새로 만들고(신규 유저), 있으면
    // 건드리지 않는다(재로그인 시 기존 누적 통계 보존).
    await FirestoreService.instance.ensureUserProfile(
      uid: user.uid,
      email: _userEmail ?? '',
      name: _userName ?? '',
      loginType: _loginType ?? 'email',
    );

    await _refreshStatsFromFirestore(user.uid);
    await _refreshLogsAndCouponsFromFirestore(user.uid);
  }

  /// Firestore의 users/{uid} 프로필 문서에서 누적 통계를 읽어와 반영한다.
  Future<void> _refreshStatsFromFirestore(String uid) async {
    final profile = await FirestoreService.instance.fetchUserProfile(uid);
    if (profile == null) return;

    _totalPoints = (profile['totalPoints'] as num?)?.toInt() ?? _totalPoints;
    _totalWeightKg = (profile['totalWeightKg'] as num?)?.toDouble() ?? _totalWeightKg;
    _totalMissionCount = (profile['totalMissionCount'] as num?)?.toInt() ?? _totalMissionCount;
    notifyListeners();
  }

  /// Firestore의 로그/쿠폰 서브컬렉션을 읽어와 로컬 목업 리스트를 대체한다.
  Future<void> _refreshLogsAndCouponsFromFirestore(String uid) async {
    final logs = await FirestoreService.instance.fetchLogs(uid);
    final coupons = await FirestoreService.instance.fetchCoupons(uid);

    if (logs.isNotEmpty) _logs = logs;
    if (coupons.isNotEmpty) _coupons = coupons;
    notifyListeners();
  }

  // 마지막으로 실패한 이메일 회원가입/로그인의 사유를 사용자에게 보여줄 수
  // 있는 한국어 문구로 담아둔다. UI가 signupWithEmail/loginWithEmail의 bool
  // 반환값만으로는 실패 사유(이메일 중복인지, Firebase Console에서 이메일/
  // 비밀번호 로그인 자체가 꺼져 있는지 등)를 구분할 수 없어서 별도로 둔다.
  String? _lastAuthErrorMessage;
  String? get lastAuthErrorMessage => _lastAuthErrorMessage;

  /// FirebaseAuthException의 코드를 화면에 보여줄 한국어 문구로 변환한다.
  String _describeAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return '이미 등록된 이메일 주소입니다.';
      case 'invalid-email':
        return '올바르지 않은 이메일 형식입니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 6자리 이상으로 설정해 주세요.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 일치하지 않습니다.';
      case 'operation-not-allowed':
        // 개발자 설정 문제라 사용자에게 그대로 노출하기보다 원인을 명시한다.
        return 'Firebase Console에서 이메일/비밀번호 로그인이 아직 활성화되지 않았습니다.';
      case 'requires-recent-login':
        // 회원 탈퇴 등 민감한 작업은 최근 로그인 상태여야 허용된다.
        return '보안을 위해 재로그인이 필요합니다. 로그아웃 후 다시 로그인한 뒤 시도해 주세요.';
      default:
        return '인증 처리 중 오류가 발생했습니다 (${e.code}).';
    }
  }

  // 이메일 회원가입 — Firebase Auth로 계정을 만든다. 비밀번호는 앱이 직접
  // 해싱/저장하지 않고 Firebase Auth가 안전하게 처리한다.
  Future<bool> signupWithEmail(String email, String password, String name) async {
    _lastAuthErrorMessage = null;
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      _userName = name;
      _loginType = 'email';

      final user = credential.user;
      if (user == null) return false;
      await _hydrateFromFirebaseUser(user);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('이메일 회원가입 실패: ${e.code}');
      _lastAuthErrorMessage = _describeAuthError(e);
      return false;
    }
  }

  // 이메일 로그인 — Firebase Auth로 인증한다.
  Future<bool> loginWithEmail(String email, String password) async {
    _lastAuthErrorMessage = null;
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return false;
      _loginType = 'email';
      await _hydrateFromFirebaseUser(user);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('이메일 로그인 실패: ${e.code}');
      _lastAuthErrorMessage = _describeAuthError(e);
      return false;
    }
  }

  // 구글 소셜 로그인 연동 (Firebase Auth)
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // 사용자가 취소함
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        _loginType = 'google';
        await _hydrateFromFirebaseUser(user);
        return true;
      }
    } catch (e) {
      debugPrint("Firebase Google 로그인 에러 (Fallback 모드 작동): $e");
      // Firebase 설정(google-services.json) 미적용 환경인 경우 데모용 익명
      // 계정으로 로그인해, 로그인 실패 없이도 서버(Firestore) 연동은 그대로
      // 검증할 수 있게 한다.
      try {
        final anonCredential = await FirebaseAuth.instance.signInAnonymously();
        final user = anonCredential.user;
        if (user == null) return false;
        await user.updateDisplayName('구글 사용자 (Demo)');
        _loginType = 'google';
        _userEmail = 'clean_google_demo@cleantrail.com';
        await _hydrateFromFirebaseUser(user);
        return true;
      } catch (fallbackError) {
        debugPrint('익명 로그인 폴백도 실패: $fallbackError');
        return false;
      }
    }
    return false;
  }

  /// 실제 SDK 연동이 없는 소셜 로그인(예: 네이버)의 데모용 처리.
  /// Firebase Auth 익명 로그인으로 실제 uid를 발급받아, 로그인 타입/표시
  /// 이름만 [type]/[name]으로 보이도록 하고 나머지 흐름(Firestore 프로필
  /// 생성 등)은 다른 로그인 방식과 동일하게 태운다.
  Future<bool> loginWithSocial(String type, String email, String name) async {
    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();
      final user = credential.user;
      if (user == null) return false;

      await user.updateDisplayName(name);
      _loginType = type;
      _userEmail = email;
      await _hydrateFromFirebaseUser(user);
      return true;
    } catch (e) {
      debugPrint('$type 데모 로그인 실패: $e');
      return false;
    }
  }

  // 로그아웃 (Firebase Auth 및 GoogleSignIn 해제 포함)
  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint("소셜 로그아웃 예외 무시: $e");
    }
    await FirebaseAuth.instance.signOut();

    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;
    _loginType = null;

    // 상태 복구
    _currentTab = 0;
    _onboarded = false;
    notifyListeners();
  }

  /// 회원 탈퇴 — Firestore에 저장된 유저 데이터(프로필/로그/쿠폰)를 모두
  /// 삭제하고, Firebase Auth 계정 자체도 삭제한다. 스토어 심사 요건상
  /// 로그인 기능이 있는 앱은 반드시 앱 내에서 탈퇴할 수 있는 경로를
  /// 제공해야 하므로 로그아웃과 별도로 둔다.
  ///
  /// Firebase Auth는 계정 삭제처럼 민감한 작업에 "최근 로그인" 상태를
  /// 요구할 수 있다 — 그 경우 [FirebaseAuthException]의 code가
  /// 'requires-recent-login'으로 오며, 이때는 실패로 반환하고
  /// [_lastAuthErrorMessage]에 재로그인 안내를 담는다.
  Future<bool> deleteAccount() async {
    _lastAuthErrorMessage = null;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      // Auth 계정보다 먼저 지운다 — 순서가 반대면 인증이 끊긴 뒤라
      // Firestore 보안 규칙(request.auth.uid == userId)을 통과하지 못한다.
      await FirestoreService.instance.deleteUserData(user.uid);

      try {
        await GoogleSignIn().signOut();
      } catch (e) {
        debugPrint("소셜 로그아웃 예외 무시: $e");
      }
      await user.delete();

      _isLoggedIn = false;
      _userEmail = null;
      _userName = null;
      _loginType = null;
      _totalPoints = 0;
      _totalWeightKg = 0.0;
      _totalMissionCount = 0;
      _logs = [];
      _coupons = [];
      _ranking = [];
      _currentTab = 0;
      _onboarded = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _lastAuthErrorMessage = _describeAuthError(e);
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('회원 탈퇴 실패: $e');
      _lastAuthErrorMessage = '탈퇴 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      notifyListeners();
      return false;
    }
  }

  // 가상 위치 실시간 변경 처리 (New)
  void setVirtualLocation(double lat, double lng, String name, {String? areaCode}) {
    _userLatitude = lat;
    _userLongitude = lng;
    _userLocationName = name;
    if (areaCode != null) _userAreaCode = areaCode;
    _locationPermissionGranted = true; // 가상 위치 스위칭 시 위치 수집 활성화 처리
    notifyListeners();

    // 위치가 바뀌면 한국관광공사 TourAPI로 주변 관광지 정보를 새로 불러온다.
    refreshNearbySpots();
    refreshNearbyWalkingCourses();
    refreshDurunubiCourses();
  }

  /// 현재 사용자 위치 기준으로 한국관광공사 TourAPI(위치기반 관광정보)를 호출하여
  /// 각 플로깅 코스의 추천 스팟(recommendedSpots)을 실제 관광 데이터로 갱신한다.
  ///
  /// 두루누비 코스(id가 'durunubi_'로 시작)는 대상에서 제외한다 —
  /// [refreshDurunubiCourses]가 각 코스의 실제 시작 좌표 기준으로 이미
  /// recommendedSpots를 채워두는데, 이 메서드는 사용자의 현재 위치(코스
  /// 시작 좌표와 다를 수 있음) 기준으로 스팟을 나눠 배분하는 방식이라
  /// 실행 순서에 따라 더 정확한 데이터를 부정확한 값으로 덮어쓸 수 있다.
  ///
  /// TOUR_API_KEY가 설정되지 않았거나 API 호출이 실패하면 아무 것도 하지 않고
  /// 기존 목업 추천 스팟을 그대로 유지한다 (앱 동작에 영향 없음).
  Future<void> refreshNearbySpots() async {
    if (!TourApiService.instance.isConfigured || _courses.isEmpty) return;
    if (_courses.every((c) => c.id.startsWith('durunubi_'))) return;

    _isLoadingNearbySpots = true;
    notifyListeners();

    try {
      final spots = await TourApiService.instance.fetchNearbySpots(
        latitude: _userLatitude,
        longitude: _userLongitude,
        radiusMeters: 3000,
      );

      if (spots.isNotEmpty) {
        // 코스별로 겹치지 않게 추천 스팟을 순서대로 나눠 배분한다.
        // (두루누비 코스는 위 가드에서 걸러지므로 여기 도달하는 _courses는
        // 항상 목업 코스다.)
        final perCourse = (spots.length / _courses.length).ceil().clamp(1, 4);
        _courses = List.generate(_courses.length, (i) {
          final start = i * perCourse;
          if (start >= spots.length) return _courses[i];
          final end = (start + perCourse).clamp(0, spots.length);
          return _courses[i].copyWith(recommendedSpots: spots.sublist(start, end));
        });
      }
    } finally {
      _isLoadingNearbySpots = false;
      notifyListeners();
    }
  }

  /// 현재 사용자 위치(지역코드) 기준으로 한국관광공사 TourAPI에서 "여행코스"
  /// (contentTypeId=25) 카테고리만 조회하여 주변 도보여행 코스 추천 목록을 갱신한다.
  ///
  /// TourAPI 확인 결과 locationBasedList2(좌표기반 반경검색)는 여행코스
  /// 데이터를 반환하지 않아, areaBasedList2(지역코드기반)를 사용한다 — 그래서
  /// 좌표가 아니라 [_userAreaCode](가상 위치 프리셋에 매핑된 지역코드)를 쓴다.
  ///
  /// TOUR_API_KEY가 설정되지 않았거나 API 호출이 실패하면 목록을 비워두고
  /// 조용히 종료한다 (홈 화면은 추천 섹션 자체를 숨긴다).
  Future<void> refreshNearbyWalkingCourses() async {
    if (!TourApiService.instance.isConfigured) return;

    _isLoadingWalkingCourses = true;
    notifyListeners();

    try {
      _nearbyWalkingCourses = await TourApiService.instance.fetchSpotsByArea(
        areaCode: _userAreaCode,
        contentTypeId: '25',
        numOfRows: 10,
      );
    } finally {
      _isLoadingWalkingCourses = false;
      notifyListeners();
    }
  }

  /// 한국관광공사 두루누비 서비스에서 현재 위치(가상 위치 프리셋)에 매핑된
  /// 실제 걷기코스를 가져와, GPX 경로까지 포함한 [PloggingCourse]로 변환해
  /// 플로깅 미션 코스 목록(_courses)에 반영한다.
  ///
  /// [durunubiCourseNamesByAreaCode]에 현재 지역코드로 매핑된 코스명이 있으면
  /// 그 코스명들로 courseList(crsKorNm)를 조회하고, 각 코스의 GPX까지
  /// 내려받아 목업 코스를 대체한다. 매핑이 비어 있으면(아직 조사 전)
  /// 참고용으로 [durunubiCourses]에 전체 목록 상위 N개만 채워두고, 플로깅
  /// 미션 코스는 기존 목업을 그대로 유지한다 — 그래서 매핑 조사가 끝나지
  /// 않은 지역에서도 앱은 항상 정상 동작한다.
  ///
  /// DURUNUBI_API_KEY가 설정되지 않았거나 호출이 실패하면 아무 것도 하지
  /// 않고 조용히 종료한다.
  Future<void> refreshDurunubiCourses() async {
    if (!DurunubiApiService.instance.isConfigured) return;

    _isLoadingDurunubiCourses = true;
    notifyListeners();

    try {
      final mappedNames = durunubiCourseNamesByAreaCode[_userAreaCode] ?? const [];

      if (mappedNames.isEmpty) {
        // 이 지역은 아직 매핑 조사가 안 됨 — 참고용 전체 목록만 채운다.
        _durunubiCourses = await DurunubiApiService.instance.fetchCourses(
          brdDiv: 'DNWW',
          numOfRows: 10,
        );
        return;
      }

      final matched = <DurunubiCourse>[];
      for (final name in mappedNames) {
        final results = await DurunubiApiService.instance.fetchCourses(
          crsKorNm: name,
          brdDiv: 'DNWW',
          numOfRows: 5,
        );
        // 코스명이 부분일치로 여러 건 돌아올 수 있어, 원문과 정확히 같은
        // 것만 채택한다 (매핑 테이블에는 항상 API 원문을 넣기로 했으므로).
        final exact = results.where((c) => c.name == name);
        matched.addAll(exact.isNotEmpty ? exact : results.take(1));
      }
      _durunubiCourses = matched;

      if (matched.isNotEmpty) {
        final plottedCourses = <PloggingCourse>[];
        for (final course in matched) {
          final gpx = await DurunubiApiService.instance.fetchGpxCoordinates(course.gpxUrl);
          if (gpx.isEmpty) continue; // GPX 없으면 지도/미션에 쓸 수 없어 건너뜀

          // 코스 전 구간에 걸쳐 TourAPI 관광지/음식점을 채워 넣는다.
          // refreshNearbySpots()가 목업 _courses를 대상으로 이미 같은 일을
          // 하지만, 그 호출과 이 메서드는 AppState() 생성자에서 거의 동시에
          // 비동기로 시작돼 실행 순서를 보장할 수 없다 — 이 메서드가 나중에
          // 끝나 _courses를 통째로 교체하면 recommendedSpots가 빈 채로
          // 남을 수 있어, 여기서 직접 채운다.
          //
          // 시작 좌표 하나만 기준으로 조회하면 10km 넘는 코스에서도 출발지
          // 근처 스팟만 몰리므로, GPX 경로를 4등분한 지점(시작/1·3/2·3/끝)
          // 각각에서 조회해 코스 전반에 고르게 분포시킨다. 지점당 반경은
          // 좁혀서(1.5km) 서로 겹치는 스팟을 줄이고, 지점 수를 늘리는 대신
          // 4곳으로 제한해 개발계정 일일 트래픽(1,000건)을 아낀다.
          final sampleIndices = {
            0,
            (gpx.length * 1 / 3).floor(),
            (gpx.length * 2 / 3).floor(),
            gpx.length - 1,
          };
          final spotsAlongRoute = <TouristSpot>[];
          final seenContentIds = <String>{};
          for (final i in sampleIndices) {
            final point = gpx[i.clamp(0, gpx.length - 1)];
            final found = await TourApiService.instance.fetchNearbySpots(
              latitude: point['lat']!,
              longitude: point['lng']!,
              radiusMeters: 1500,
              numOfRows: 6,
            );
            for (final spot in found) {
              // contentId가 없는(개별 구분 불가) 항목은 중복 검사 없이 추가.
              final key = spot.contentId;
              if (key != null && !seenContentIds.add(key)) continue;
              spotsAlongRoute.add(spot);
            }
          }

          plottedCourses.add(PloggingCourse.fromDurunubi(
            course,
            gpxCoordinates: gpx,
            recommendedSpots: spotsAlongRoute,
          ));
        }
        if (plottedCourses.isNotEmpty) {
          _courses = plottedCourses;
        }
      }
    } finally {
      _isLoadingDurunubiCourses = false;
      notifyListeners();
    }
  }

  void _initializeMockData() {
    // 1. Initialize Mock Plogging Courses
    _courses = [
      const PloggingCourse(
        id: 'course_1',
        title: '해안 산책로 코스',
        durationMinutes: 40,
        difficulty: '중',
        rewardPoints: 12,
        distanceKm: 2.4,
        description: '시원한 바다 바람을 맞으며 걷는 산책로 코스입니다. 해안가의 유실 쓰레기가 자주 발생하는 지역으로 정화가 필요합니다.',
        startLatitude: 38.2118,
        startLongitude: 128.5995,
        endLatitude: 38.2162,
        endLongitude: 128.6022,
        pathCoordinates: [
          {'lat': 38.2118, 'lng': 128.5995},
          {'lat': 38.2125, 'lng': 128.6002},
          {'lat': 38.2135, 'lng': 128.6006},
          {'lat': 38.2145, 'lng': 128.6010},
          {'lat': 38.2155, 'lng': 128.6018},
          {'lat': 38.2162, 'lng': 128.6022},
        ],
        recommendedSpots: [
          TouristSpot(
            name: '해안 전망대 등대',
            category: '관광지',
            distance: '0.3km',
            imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=200&fit=crop',
            latitude: 38.2145,
            longitude: 128.6010,
          ),
          TouristSpot(
            name: '동해 횟집',
            category: '음식점',
            distance: '0.5km',
            imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=200&fit=crop',
            latitude: 38.2130,
            longitude: 128.6005,
          ),
          TouristSpot(
            name: '카페 오션뷰',
            category: '카페',
            distance: '0.6km',
            imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=200&fit=crop',
            latitude: 38.2152,
            longitude: 128.6015,
          ),
        ],
      ),
      const PloggingCourse(
        id: 'course_2',
        title: '전통시장 골목 코스',
        durationMinutes: 25,
        difficulty: '하',
        rewardPoints: 8,
        distanceKm: 1.2,
        description: '다양한 먹거리와 볼거리가 있는 전통시장 골목길 코스입니다. 유동인구가 많아 길거리 일회용 컵 등이 많습니다.',
        startLatitude: 38.2038,
        startLongitude: 128.5910,
        endLatitude: 38.2052,
        endLongitude: 128.5890,
        pathCoordinates: [
          {'lat': 38.2038, 'lng': 128.5910},
          {'lat': 38.2042, 'lng': 128.5905},
          {'lat': 38.2046, 'lng': 128.5898},
          {'lat': 38.2052, 'lng': 128.5890},
        ],
        recommendedSpots: [
          TouristSpot(
            name: '원조 씨앗호떡',
            category: '음식점',
            distance: '0.1km',
            imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=200&fit=crop',
            latitude: 38.2042,
            longitude: 128.5904,
          ),
          TouristSpot(
            name: '백년 우물 역사터',
            category: '관광지',
            distance: '0.2km',
            imageUrl: 'https://images.unsplash.com/photo-1449034446853-66c86144b0ad?w=200&fit=crop',
            latitude: 38.2046,
            longitude: 128.5896,
          ),
          TouristSpot(
            name: '시장 전통 다방',
            category: '카페',
            distance: '0.3km',
            imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=200&fit=crop',
            latitude: 38.2050,
            longitude: 128.5892,
          ),
        ],
      ),
      const PloggingCourse(
        id: 'course_3',
        title: '호수 둘레길 코스',
        durationMinutes: 50,
        difficulty: '중',
        rewardPoints: 15,
        distanceKm: 3.1,
        description: '평탄하게 조성된 아름다운 호수길 코스입니다. 피크닉 구역 근처의 쓰레기를 중점 수거해주세요.',
        startLatitude: 37.7960,
        startLongitude: 128.9130,
        endLatitude: 37.7962,
        endLongitude: 128.9128,
        pathCoordinates: [
          {'lat': 37.7960, 'lng': 128.9130},
          {'lat': 37.7990, 'lng': 128.9150},
          {'lat': 37.8020, 'lng': 128.9120},
          {'lat': 37.8010, 'lng': 128.9070},
          {'lat': 37.7970, 'lng': 128.9060},
          {'lat': 37.7960, 'lng': 128.9130},
        ],
        recommendedSpots: [
          TouristSpot(
            name: '호수 조각 공원',
            category: '관광지',
            distance: '0.4km',
            imageUrl: 'https://images.unsplash.com/photo-1519331379826-f10be5486c6f?w=200&fit=crop',
            latitude: 37.7990,
            longitude: 128.9140,
          ),
          TouristSpot(
            name: '레이크 하우스 레스토랑',
            category: '음식점',
            distance: '0.7km',
            imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=200&fit=crop',
            latitude: 37.7970,
            longitude: 128.9080,
          ),
        ],
      ),
    ];

    // 2. Initialize Mock Coupons
    _coupons = [
      Coupon(
        id: 'coupon_mock_1',
        shopName: '[예시] 해안 산책로 인근 카페',
        discountDetails: '(가맹점 협의 전 데모) 아메리카노 30% 할인쿠폰',
        expiryDate: '2026.07.31',
        isUsed: false,
      ),
      Coupon(
        id: 'coupon_mock_2',
        shopName: '[예시] 전통시장 골목 식당',
        discountDetails: '(가맹점 협의 전 데모) 식사 금액 10% 즉시 할인',
        expiryDate: '2026.08.15',
        isUsed: true,
      ),
    ];

    // 3. Initialize Mock Plogging Logs
    _logs = [
      const PloggingLog(
        id: 'log_1',
        courseTitle: '해안 산책로 코스',
        date: '2026.07.08',
        collectedWeightKg: 1.2,
        pointsEarned: 12,
      ),
      const PloggingLog(
        id: 'log_2',
        courseTitle: '전통시장 골목 코스',
        date: '2026.07.02',
        collectedWeightKg: 0.8,
        pointsEarned: 8,
      ),
      const PloggingLog(
        id: 'log_3',
        courseTitle: '호수 둘레길 코스',
        date: '2026.06.28',
        collectedWeightKg: 1.5,
        pointsEarned: 15,
      ),
    ];
  }

  // Action methods
  void completeOnboarding() {
    _onboarded = true;
    notifyListeners();
  }

  void grantLocationPermission() {
    _locationPermissionGranted = true;
    notifyListeners();
  }

  void changeTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  void selectCourse(PloggingCourse? course) {
    _selectedCourse = course;
    notifyListeners();
  }

  void startMission() {
    if (_selectedCourse == null) return;
    _isMissionActive = true;
    _missionStartTime = DateTime.now();
    _elapsedSeconds = 0;
    _trashItems.clear();
    _isCapturingTrashPhoto = false;
    _verificationState = 'idle';

    _missionTimer?.cancel();
    _missionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });

    notifyListeners();
  }

  /// 실제 기기 카메라를 열어 쓰레기 사진을 촬영하고, 촬영 즉시 로그 목록에 추가한다.
  /// 추가된 항목은 잠시 '분류 중' 상태였다가 AI(현재는 시뮬레이션) 분류 결과로 채워진다.
  /// 사용자가 촬영을 취소하면 아무 항목도 추가되지 않는다.
  Future<void> captureTrashItem() async {
    if (_isCapturingTrashPhoto) return;
    _isCapturingTrashPhoto = true;
    notifyListeners();

    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 85,
      );

      if (picked != null) {
        final item = TrashItem(
          id: 'trash_${DateTime.now().millisecondsSinceEpoch}',
          photo: File(picked.path),
        );
        _trashItems.add(item);
        notifyListeners();
        _classifyTrashItem(item);
      }
    } catch (e) {
      debugPrint('카메라 촬영 실패: $e');
    } finally {
      _isCapturingTrashPhoto = false;
      notifyListeners();
    }
  }

  /// 촬영된 쓰레기 사진의 종류를 온디바이스 TFLite 모델로 분류한다.
  /// (TrashNet 기반 MobileNetV2, lib/services/trash_classifier_service.dart)
  Future<void> _classifyTrashItem(TrashItem item) async {
    final category = await TrashClassifierService.instance.classify(item.photo);
    if (!_trashItems.contains(item)) return; // 그 사이 삭제됐으면 무시

    // 모델 로딩/추론 실패 시에도 사용자 흐름이 막히지 않도록 일반쓰레기로 폴백
    item.category = category ?? TrashCategory.general;
    notifyListeners();
  }

  /// 잘못 찍은 사진을 목록에서 제거한다.
  void removeTrashItem(String itemId) {
    _trashItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void submitVerification() {
    if (_trashItems.isEmpty) return;
    _verificationState = 'processing';
    _missionTimer?.cancel();
    _missionTimer = null;
    notifyListeners();

    // Simulates AI processing for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _verificationState = 'success';
      notifyListeners();
    });
  }

  void receiveReward() {
    if (_selectedCourse == null) return;
    
    // Add points
    _totalPoints += _selectedCourse!.rewardPoints;
    _totalMissionCount += 1;
    // Add a random weight collected between 0.5kg and 2.0kg
    double weightAdded = 0.5 + (DateTime.now().millisecond % 15) / 10.0;
    weightAdded = double.parse(weightAdded.toStringAsFixed(1));
    _totalWeightKg += weightAdded;

    // Create a new coupon
    String newCouponId = 'coupon_${DateTime.now().millisecondsSinceEpoch}';
    // TODO(가맹점 협의): 실제 지자체/가맹점 계약이 체결되면 아래 이름과
    // 혜택 내용을 실제 상호명으로 교체한다. 협의 전에는 "[예시]" 표기와
    // "(가맹점 협의 전 데모)" 문구를 반드시 유지해 실존 가게로 오인되거나
    // 과장광고로 비치지 않도록 한다.
    String shopName = _selectedCourse!.id == 'course_1'
        ? '[예시] 해안 산책로 인근 카페'
        : _selectedCourse!.id == 'course_2'
            ? '[예시] 전통시장 골목 식당'
            : '[예시] 호수공원 인근 카페';

    String discountDetails = _selectedCourse!.id == 'course_1'
        ? '(가맹점 협의 전 데모) 아메리카노 30% 즉시 할인'
        : _selectedCourse!.id == 'course_2'
            ? '(가맹점 협의 전 데모) 대표 메뉴 1인분 무료 쿠폰'
            : '(가맹점 협의 전 데모) 돗자리 & 음료 2잔 세트 20% 할인';

    final newCoupon = Coupon(
      id: newCouponId,
      shopName: shopName,
      discountDetails: discountDetails,
      expiryDate: '2026.08.31',
      isUsed: false,
    );
    _coupons.insert(0, newCoupon);

    // 촬영된 쓰레기 항목들을 카테고리별로 집계
    final Map<TrashCategory, int> trashSummary = {};
    for (final item in _trashItems) {
      final category = item.category;
      if (category == null) continue; // 분류가 아직 안 끝난 항목은 집계 제외
      trashSummary[category] = (trashSummary[category] ?? 0) + 1;
    }

    // Create a new log
    final newLog = PloggingLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      courseTitle: _selectedCourse!.title,
      date: '2026.07.17',
      collectedWeightKg: weightAdded,
      pointsEarned: _selectedCourse!.rewardPoints,
      trashSummary: trashSummary,
    );
    _logs.insert(0, newLog);

    // Clear active mission state
    _isMissionActive = false;
    _selectedCourse = null;
    _trashItems.clear();
    _verificationState = 'idle';

    // Navigate to Clean Log tab (index 2) to let user see their coupon
    _currentTab = 2;
    // 로컬 상태를 먼저 갱신해 화면이 즉시 반응하게 하고(낙관적 업데이트),
    // Firestore 동기화는 백그라운드로 진행한다 — receiveReward()를 호출하는
    // UI 콜백들이 모두 await 없는 동기 호출이라, 여기서 기다리게 만들면
    // 화면이 응답 없이 멈춘 것처럼 보인다.
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreService.instance
          .incrementUserStats(
            uid: user.uid,
            pointsDelta: newLog.pointsEarned,
            weightDeltaKg: weightAdded,
          )
          .then((_) => fetchRanking()); // 통계 반영 후 랭킹도 최신순으로 갱신
      FirestoreService.instance.addLog(uid: user.uid, log: newLog);
      FirestoreService.instance.addCoupon(uid: user.uid, coupon: newCoupon);
    }
  }

  /// 쿠폰을 사용 처리한다. 로컬 상태를 먼저 갱신해 화면이 즉시 반응하고,
  /// Firestore 서버 검증 결과에 따라 필요하면 되돌린다 — 이미 사용된
  /// 쿠폰이거나 존재하지 않는 쿠폰이면 로컬에서도 원래 상태로 복구한다.
  /// 매장 QR 스캐너(StoreScannerScreen)에서의 검증도 이 메서드를 거친다.
  Future<CouponRedeemResult> redeemCoupon(String couponId) async {
    Coupon? target;
    for (var coupon in _coupons) {
      if (coupon.id == couponId) {
        target = coupon;
        break;
      }
    }
    if (target == null) return CouponRedeemResult.notFound;

    final wasUsed = target.isUsed;
    target.isUsed = true;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return CouponRedeemResult.success; // 로그인 안 된 데모 상태는 로컬만 반영

    final result = await FirestoreService.instance.redeemCoupon(
      uid: user.uid,
      couponId: couponId,
    );

    if (result != CouponRedeemResult.success) {
      // 서버가 거절했으면 로컬 상태를 원래대로 되돌린다.
      target.isUsed = wasUsed;
      notifyListeners();
    }
    return result;
  }

  void resetMission() {
    _missionTimer?.cancel();
    _missionTimer = null;
    _isMissionActive = false;
    _selectedCourse = null;
    _trashItems.clear();
    _verificationState = 'idle';
    notifyListeners();
  }

  @override
  void dispose() {
    _missionTimer?.cancel();
    super.dispose();
  }
}

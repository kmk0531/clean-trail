import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import '../models/coupon.dart';
import '../models/clean_log.dart';

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

  // Courses list
  List<PloggingCourse> _courses = [];
  List<PloggingCourse> get courses => _courses;

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

  // Photo verification details
  String? _startPhotoPath;
  String? get startPhotoPath => _startPhotoPath;
  bool _isStartPhotoUploading = false;
  bool get isStartPhotoUploading => _isStartPhotoUploading;
  double _startPhotoUploadProgress = 0.0;
  double get startPhotoUploadProgress => _startPhotoUploadProgress;

  String? _endPhotoPath;
  String? get endPhotoPath => _endPhotoPath;
  bool _isEndPhotoUploading = false;
  bool get isEndPhotoUploading => _isEndPhotoUploading;
  double _endPhotoUploadProgress = 0.0;
  double get endPhotoUploadProgress => _endPhotoUploadProgress;

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
  }

  // 기기 내 저장된 유저 세션 정보 로딩 (New)
  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userEmail = prefs.getString('userEmail');
    _userName = prefs.getString('userName');
    _loginType = prefs.getString('loginType');
    
    // 만약 로그인 정보가 로드되면 바로 온보딩 단계를 넘어가도록 구성
    if (_isLoggedIn) {
      _onboarded = true;
    }
    notifyListeners();
  }

  // 이메일 회원가입 (New)
  Future<bool> signupWithEmail(String email, String password, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('local_users') ?? [];

    // 중복 이메일 체크
    for (var u in users) {
      final parts = u.split(':');
      if (parts[0] == email) {
        return false;
      }
    }

    // 사용자 추가 (email:password:name 포맷으로 가짜 DB 기록)
    users.add('$email:$password:$name');
    await prefs.setStringList('local_users', users);

    // 가입 성공 시 자동 로그인 연계
    return await loginWithEmail(email, password);
  }

  // 이메일 로그인 (New)
  Future<bool> loginWithEmail(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('local_users') ?? [];

    for (var u in users) {
      final parts = u.split(':');
      if (parts.length >= 3 && parts[0] == email && parts[1] == password) {
        _isLoggedIn = true;
        _userEmail = email;
        _userName = parts[2];
        _loginType = 'email';

        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', _userEmail!);
        await prefs.setString('userName', _userName!);
        await prefs.setString('loginType', 'email');

        _onboarded = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // 소셜 로그인 모의 처리 (New)
  Future<void> loginWithSocial(String type, String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = true;
    _userEmail = email;
    _userName = name;
    _loginType = type;

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', _userEmail!);
    await prefs.setString('userName', _userName!);
    await prefs.setString('loginType', type);

    _onboarded = true;
    notifyListeners();
  }

  // 로그아웃 (New)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;
    _loginType = null;

    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    await prefs.remove('loginType');

    // 상태 복구
    _currentTab = 0;
    _onboarded = false;
    notifyListeners();
  }

  // 가상 위치 실시간 변경 처리 (New)
  void setVirtualLocation(double lat, double lng, String name) {
    _userLatitude = lat;
    _userLongitude = lng;
    _userLocationName = name;
    _locationPermissionGranted = true; // 가상 위치 스위칭 시 위치 수집 활성화 처리
    notifyListeners();
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
        shopName: '카페 브리즈 (해안 산책로 인근)',
        discountDetails: '아메리카노 30% 할인쿠폰',
        expiryDate: '2026.07.31',
        isUsed: false,
      ),
      Coupon(
        id: 'coupon_mock_2',
        shopName: '전통한옥 떡갈비',
        discountDetails: '식사 금액 10% 즉시 할인',
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
    _startPhotoPath = null;
    _endPhotoPath = null;
    _isStartPhotoUploading = false;
    _startPhotoUploadProgress = 0.0;
    _isEndPhotoUploading = false;
    _endPhotoUploadProgress = 0.0;
    _verificationState = 'idle';

    _missionTimer?.cancel();
    _missionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });

    notifyListeners();
  }

  void mockCaptureStartPhoto() {
    _isStartPhotoUploading = true;
    _startPhotoUploadProgress = 0.0;
    notifyListeners();

    // Mock progress ticker
    double progress = 0.0;
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      progress += 0.2;
      if (progress >= 1.0) {
        _startPhotoUploadProgress = 1.0;
        _isStartPhotoUploading = false;
        _startPhotoPath = 'mock_start_photo_path.jpg';
        timer.cancel();
        notifyListeners();
      } else {
        _startPhotoUploadProgress = progress;
        notifyListeners();
      }
    });
  }

  void mockCaptureEndPhoto() {
    _isEndPhotoUploading = true;
    _endPhotoUploadProgress = 0.0;
    notifyListeners();

    // Mock progress ticker
    double progress = 0.0;
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      progress += 0.2;
      if (progress >= 1.0) {
        _endPhotoUploadProgress = 1.0;
        _isEndPhotoUploading = false;
        _endPhotoPath = 'mock_end_photo_path.jpg';
        timer.cancel();
        notifyListeners();
      } else {
        _endPhotoUploadProgress = progress;
        notifyListeners();
      }
    });
  }

  void submitVerification() {
    if (_startPhotoPath == null || _endPhotoPath == null) return;
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
    _totalWeightKg += double.parse(weightAdded.toStringAsFixed(1));

    // Create a new coupon
    String newCouponId = 'coupon_${DateTime.now().millisecondsSinceEpoch}';
    String shopName = _selectedCourse!.id == 'course_1' 
        ? '해안가 카페 브리즈' 
        : _selectedCourse!.id == 'course_2'
            ? '시장골목 고기만두집'
            : '호수공원 피크닉 카페';
            
    String discountDetails = _selectedCourse!.id == 'course_1'
        ? '아메리카노 30% 즉시 할인'
        : _selectedCourse!.id == 'course_2'
            ? '수제 만두 1인분 무료 쿠폰'
            : '돗자리 & 커피 2잔 세트 20% 할인';

    _coupons.insert(0, Coupon(
      id: newCouponId,
      shopName: shopName,
      discountDetails: discountDetails,
      expiryDate: '2026.08.31',
      isUsed: false,
    ));

    // Create a new log
    _logs.insert(0, PloggingLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      courseTitle: _selectedCourse!.title,
      date: '2026.07.17',
      collectedWeightKg: weightAdded,
      pointsEarned: _selectedCourse!.rewardPoints,
    ));

    // Clear active mission state
    _isMissionActive = false;
    _selectedCourse = null;
    _startPhotoPath = null;
    _endPhotoPath = null;
    _verificationState = 'idle';

    // Navigate to Clean Log tab (index 2) to let user see their coupon
    _currentTab = 2;
    notifyListeners();
  }

  void redeemCoupon(String couponId) {
    for (var coupon in _coupons) {
      if (coupon.id == couponId) {
        coupon.isUsed = true;
        break;
      }
    }
    notifyListeners();
  }

  void resetMission() {
    _missionTimer?.cancel();
    _missionTimer = null;
    _isMissionActive = false;
    _selectedCourse = null;
    _startPhotoPath = null;
    _endPhotoPath = null;
    _verificationState = 'idle';
    notifyListeners();
  }

  @override
  void dispose() {
    _missionTimer?.cancel();
    super.dispose();
  }
}

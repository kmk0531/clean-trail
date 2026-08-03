import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'state/app_state.dart';
import 'models/coupon.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mission_detail_screen.dart';
import 'screens/mission_verification_screen.dart';
import 'screens/ai_result_screen.dart';
import 'screens/coupon_qr_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/my_clean_log_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/store_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 네이버 지도 SDK 초기화 (최신 API 규격 적용)
  await FlutterNaverMap().init(
    clientId: 'e8hcbik5v7', // 네이티브 설정과 매칭되는 Client ID
    onAuthFailed: (ex) {
      debugPrint("네이버 지도 인증 실패: $ex");
    },
  );

  runApp(const CleanTrailApp());
}

class CleanTrailApp extends StatelessWidget {
  const CleanTrailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleanTrail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F7D4F),
          primary: const Color(0xFF2F7D4F),
          secondary: const Color(0xFF3F9D68),
          background: const Color(0xFFF9FBF8),
        ),
        useMaterial3: true,
        fontFamily: '-apple-system',
      ),
      home: const MainRouter(),
    );
  }
}

class MainRouter extends StatefulWidget {
  const MainRouter({super.key});

  @override
  State<MainRouter> createState() => _MainRouterState();
}

class _MainRouterState extends State<MainRouter> {
  final AppState _appState = AppState();

  // Local navigation overlay state
  Coupon? _activeCouponForQr;
  bool _isStoreScannerOpen = false;

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder is native in Flutter 3.x and automatically updates when _appState calls notifyListeners()
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        // 0. 로그인 및 인증 플로우 (New)
        if (!_appState.isLoggedIn) {
          return LoginScreen(appState: _appState);
        }

        // 1. Onboarding & Permissions Flow (Screen 01)
        if (!_appState.onboarded) {
          return OnboardingScreen(appState: _appState);
        }

        // 2. Active Plogging Verification (Screen 04)
        if (_appState.isMissionActive &&
            _appState.verificationState == 'idle') {
          return MissionVerificationScreen(
            appState: _appState,
            onCancel: () {
              _appState.resetMission();
            },
            onSubmit: () {
              _appState.submitVerification();
            },
          );
        }

        // 3. AI Verdict Processing (Screen 05)
        if (_appState.verificationState != 'idle') {
          return AiResultScreen(
            appState: _appState,
            onRewardReceived: () {
              _appState.receiveReward();
            },
            onBackToHome: () {
              _appState.resetMission();
            },
          );
        }

        // 4. Coupon QR presentation (Screen 06)
        if (_activeCouponForQr != null) {
          return CouponQrScreen(
            coupon: _activeCouponForQr!,
            onBack: () {
              setState(() {
                _activeCouponForQr = null;
              });
            },
            onRedeem: (couponId) {
              _appState.redeemCoupon(couponId);
              // Refresh active coupon state view
              setState(() {
                _activeCouponForQr = _appState.coupons.firstWhere(
                  (c) => c.id == couponId,
                );
              });
            },
          );
        }

        // 5. Store QR Verification scanner (Screen 10)
        if (_isStoreScannerOpen) {
          return StoreScannerScreen(
            appState: _appState,
            onBack: () {
              setState(() {
                _isStoreScannerOpen = false;
              });
            },
          );
        }

        // 6. Selected Course Details screen (Screen 03)
        if (_appState.selectedCourse != null) {
          return MissionDetailScreen(
            course: _appState.selectedCourse!,
            onBack: () {
              _appState.selectCourse(null);
            },
            onStartMission: () {
              _appState.startMission();
            },
          );
        }

        // 7. General Shell (Home, Ranking, Clean Log, Profile) with Bottom Navigation Bar
        return Scaffold(
          backgroundColor: const Color(0xFFF9FBF8),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF9FBF8),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F4EA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: Color(0xFF2F7D4F),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'CleanTrail',
                  style: TextStyle(
                    fontFamily: '-apple-system',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Color(0xFF2F7D4F),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              // Point balance header widget
              Container(
                margin: const EdgeInsets.only(right: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC2E2CC)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Color(0xFF2F7D4F), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${_appState.totalPoints} P',
                      style: const TextStyle(
                        fontFamily: '-apple-system',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F7D4F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: IndexedStack(
              index: _appState.currentTab,
              children: [
                // Screen 02
                HomeScreen(
                  appState: _appState,
                  onCourseSelected: (course) {
                    _appState.selectCourse(course);
                  },
                ),
                // Screen 07
                const RankingScreen(),
                // Screen 08
                MyCleanLogScreen(
                  appState: _appState,
                  onCouponSelected: (coupon) {
                    setState(() {
                      _activeCouponForQr = coupon;
                    });
                  },
                ),
                // Screen 09
                ProfileScreen(
                  appState: _appState,
                  onOpenStoreScanner: () {
                    setState(() {
                      _isStoreScannerOpen = true;
                    });
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 0.5),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _appState.currentTab,
              onTap: (index) {
                _appState.changeTab(index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF2F7D4F),
              unselectedItemColor: Colors.grey[500],
              selectedLabelStyle: const TextStyle(
                fontFamily: '-apple-system',
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: '-apple-system',
                fontSize: 11,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: '홈',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard_outlined),
                  activeIcon: Icon(Icons.leaderboard),
                  label: '랭킹',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restore_from_trash_outlined),
                  activeIcon: Icon(Icons.restore_from_trash),
                  label: '클린로그',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: '프로필',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

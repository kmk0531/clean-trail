# 🌿 CleanTrail (클린트레일)

> **"관광객을 위한 친환경 플로깅(Plogging) 및 지역 상생 리워드 플랫폼"**  
> **『2026 관광데이터 활용 공모전』 출품작**

CleanTrail은 관광객이 여행지에서 플로깅(조깅하며 쓰레기를 줍는 운동)을 즐기며 환경 보호에 참여하고, AI 기반 사진 인증을 통해 획득한 보상(탄소중립 포인트 및 모바일 관광 쿠폰)을 지역 제휴 가맹점에서 활용할 수 있도록 돕는 스마트 관광 앱 서비스입니다. 이를 통해 친환경 여행 문화 확산과 지역 경제 활성화(상생 모델)를 동시에 도모합니다.

---

## 📌 주요 기능 (Key Features)

1. **위치 및 온보딩 권한 설정 (Onboarding)**
   - 앱 최초 실행 시 위치 권한(`ACCESS_FINE_LOCATION` 등) 및 카메라 권한 획득 프로세스를 친절히 안내합니다.
2. **지도 기반 플로깅 코스 추천 (Home Map)**
   - `flutter_naver_map` API를 연동하여 사용자의 현재 위치를 파악하고 인근 관광지 내 권장 플로깅 코스를 마커와 선으로 시각화합니다.
3. **실시간 플로깅 추적 및 GPS 경로 기록 (Mission Tracking)**
   - 플로깅 시작 시 타이머를 작동하여 소요 시간 및 이동 거리를 실시간으로 계측합니다.
4. **AI 기반 이중 사진 인증 (AI Verification)**
   - 플로깅 시작 전 상태와 종료 후 쓰레기 수거 사진을 촬영/업로드하면, AI 판단(시뮬레이션)을 통해 쓰레기 수거 여부를 판별하여 부정 수급을 방지합니다.
5. **모바일 관광 쿠폰 및 리워드 (Rewards & Coupons)**
   - 미션 성공 시 제공되는 탄소중립 포인트로 지역 특산품 판매점, 제휴 음식점, 카페 등에서 즉시 사용 가능한 바코드/QR 형태의 모바일 쿠폰을 발급받을 수 있습니다.
6. **가맹점용 QR 스캐너 (Merchant QR Scanner)**
   - 지역 가맹점주가 사용자의 쿠폰 QR을 직접 스캔하여 사용 처리(Redeem) 및 쓰레기 수거백 회수 확인을 원활하게 진행할 수 있는 가맹점 스캐너 모드를 내장하고 있습니다.
7. **마이 클린 로그 및 통계 (Plogging Logs & Stats)**
   - 사용자가 그동안 수행한 플로깅 기록, 누적 수거량(Kg), 매칭 포인트, 실시간 GPS 궤적 로그 데이터를 시각적으로 제공합니다.
8. **실시간 랭킹 시스템 (Ranking Leaderboard)**
   - 사용자 간 누적 획득 포인트를 순위표로 시각화하여 지속적인 참여를 유도하는 게이미케이션 요소를 가미하였습니다.

---

## 🛠 기술 스택 (Tech Stack)

* **프레임워크:** Flutter (Dart SDK: `^3.12.2`)
* **상태 관리 & 비즈니스 로직:** `ChangeNotifier` & `ListenableBuilder` (`lib/state/app_state.dart`)
* **핵심 외부 라이브러리:**
  * [flutter_naver_map (^1.4.4)](https://pub.dev/packages/flutter_naver_map) - 네이버 지도 SDK 연동 및 사용자 위치 렌더링
  * [shared_preferences (^2.2.0)](https://pub.dev/packages/shared_preferences) - 로컬 로그인 세션 저장 및 가상 가입 데이터 캐싱
  * [permission_handler (^11.3.1)](https://pub.dev/packages/permission_handler) - 모바일 카메라 및 위치 센서 권한 제어
  * [url_launcher (^6.2.5)](https://pub.dev/packages/url_launcher) - 외부 브라우저 링크 실행 지원

---

## 📂 프로젝트 구조 (Project Structure)

```text
clean_trail/
├── android/               # Android 네이티브 설정 및 매니페스트
├── ios/                   # iOS 네이티브 설정 및 Info.plist
├── lib/
│   ├── main.dart          # 앱 진입점 및 메인 라우터(MainRouter)
│   ├── models/            # 데이터 모델 구조 정의
│   │   ├── clean_log.dart # 플로깅 히스토리 로그 모델
│   │   ├── coupon.dart    # 로컬 가맹점 쿠폰 모델
│   │   └── course.dart    # 추천 플로깅 코스 정보 모델
│   ├── state/
│   │   └── app_state.dart # 핵심 비즈니스 로직 및 모킹 데이터 통합 관리
│   ├── screens/           # 각 시나리오별 화면 UI 컴포넌트
│   │   ├── onboarding_screen.dart           # 온보딩 및 권한 취득
│   │   ├── login_screen.dart / signup_screen.dart # 로그인/회원가입
│   │   ├── home_screen.dart                 # 메인 홈 지도 화면
│   │   ├── mission_detail_screen.dart       # 코스 상세 정보 및 시작
│   │   ├── mission_verification_screen.dart # 실시간 플로깅 트래킹 및 카메라 촬영
│   │   ├── ai_result_screen.dart            # AI 검증 진행 & 리워드 알림
│   │   ├── coupon_qr_screen.dart            # 쿠폰 교환 및 바코드 화면
│   │   ├── store_scanner_screen.dart        # 가맹점 인증용 QR 스캐너 화면
│   │   ├── my_clean_log_screen.dart         # 나의 활동 기록 통계 화면
│   │   ├── ranking_screen.dart              # 전체 참가자 랭킹 화면
│   │   └── profile_screen.dart              # 내 정보 및 설정 변경
│   └── widgets/           # 재사용 가능 공통 UI 컴포넌트
└── pubspec.yaml           # 패키지 의존성 정의 파일
```

---

## ⚙️ 개발 환경 설정 (Environment Configuration)

본 프로젝트는 네이버 지도 및 하드웨어 연동을 포함하고 있어 아래 설정을 미리 점검해야 합니다.

### 1. 네이버 지도 SDK 설정 (Client ID)
지도 연동을 활성화하기 위해 아래 파일들에 네이버 클라우드 플랫폼의 Client ID가 입력되어 있습니다:
* **Android**: `clean_trail/android/app/src/main/AndroidManifest.xml`
  ```xml
  <meta-data
      android:name="com.naver.maps.map.CLIENT_ID"
      android:value="e8hcbik5v7" />
  ```
* **iOS**: `clean_trail/ios/Runner/Info.plist`
  ```xml
  <key>NMFClientId</key>
  <string>e8hcbik5v7</string>
  ```
* **Dart**: `clean_trail/lib/main.dart`
  ```dart
  await FlutterNaverMap().init(
    clientId: 'e8hcbik5v7',
    onAuthFailed: (ex) { ... }
  );
  ```
  *(개인 클라이언트로 변경 시 위 3개 영역을 모두 새 Client ID로 업데이트하시기 바랍니다.)*

### 2. 권한 획득 정의
* **Android**: 위치 권한 (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`) 및 인터넷 권한설정이 완료되어 있습니다.
* **iOS**: 사용자의 실시간 플로깅 GPS 로그 작성을 위해 `NSLocationWhenInUseUsageDescription` 및 `NSLocationAlwaysAndWhenInUseUsageDescription` 목적 명시가 추가되어 있습니다.

---

## 🚀 실행 방법 (How to Run)

### 사전 필수 요구사항
* Flutter SDK (`v3.12.0` 이상 설치 필수)
* Android Studio (Android 에뮬레이터 또는 실기기) 및 Xcode (macOS/iOS 테스팅 시)

### 단계별 명령어 실행

1. **프로젝트 루트 디렉토리 이동**
   ```powershell
   cd clean_trail
   ```

2. **패키지 및 의존성 다운로드**
   ```powershell
   flutter pub get
   ```

3. **로컬 에뮬레이터 또는 연결된 디바이스 검사**
   ```powershell
   flutter devices
   ```

4. **어플리케이션 디버그 실행**
   ```powershell
   flutter run
   ```
   *(특정 기기에서 실행 시: `flutter run -d <DEVICE_ID>`)*

### 앱 빌드 (배포용 파일 생성)
* **Android APK 파일 빌드**:
  ```powershell
  flutter build apk --release
  ```
* **iOS Archive 및 IPA 빌드**:
  ```powershell
  flutter build ipa --release
  ```
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/ios_button.dart';

class OnboardingScreen extends StatelessWidget {
  final AppState appState;

  const OnboardingScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF8), // Soft iOS light background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Column(
                children: [
                  const SizedBox(height: 40),
                  // Eco Icon Badge
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF3F9D68), width: 3),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Color(0xFF2F7D4F),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'CleanTrail',
                    style: TextStyle(
                      fontFamily: '-apple-system',
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2F7D4F),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '걷고, 줍고, 리워드 받기',
                    style: TextStyle(
                      fontFamily: '-apple-system',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6E7E73),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),

              // Illustration / Message Area
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF3EE),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFD2E4DA), width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dynamic graphic (Clean path representation)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: index == 1 ? const Color(0xFF2F7D4F) : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF2F7D4F),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                index == 0
                                    ? Icons.directions_walk
                                    : index == 1
                                        ? Icons.delete_outline
                                        : Icons.confirmation_number_outlined,
                                color: index == 1 ? Colors.white : const Color(0xFF2F7D4F),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          '관광지를 걸으며 쓰레기를 줍고\n지역 상점 쿠폰을 받으세요',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                            color: Color(0xFF233529),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '지역 상점 할인으로 상생을,\n플로깅 활동으로 깨끗한 여행길을 만듭니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 13,
                            height: 1.4,
                            color: Color(0xFF6A7F71),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Button & Consent Area
              Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF8F9F94),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '근처 플로깅 코스를 찾기 위해 위치 권한이 필요합니다.',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 12,
                            color: Color(0xFF8F9F94),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: IosButton(
                      onPressed: () => _showLocationPermissionDialog(context),
                      child: const Text(
                        '시작하기',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: const Color(0xFFF2F2F7), // Cupertino alert standard gray
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF2F7D4F),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '"CleanTrail"에서 사용자의 위치정보를 사용하도록 허용하시겠습니까?',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '근처에 있는 플로깅 코스 정보 수집 및 지도상에 본인의 위치를 띄우기 위해 권한이 활용됩니다.',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.grey),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          // User denied - complete onboarding but keep location disabled (mock flow lets them continue)
                          appState.completeOnboarding();
                        },
                        child: const Text(
                          '허용 안 함',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            color: Colors.blueAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1, color: Colors.grey),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          appState.grantLocationPermission();
                          appState.completeOnboarding();
                        },
                        child: const Text(
                          '허용',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

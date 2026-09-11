import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/ios_button.dart';

class AiResultScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onRewardReceived;
  final VoidCallback onBackToHome;

  const AiResultScreen({
    super.key,
    required this.appState,
    required this.onRewardReceived,
    required this.onBackToHome,
  });

  @override
  State<AiResultScreen> createState() => _AiResultScreenState();
}

class _AiResultScreenState extends State<AiResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState.verificationState;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),
              // Main content switches based on verification status
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: state == 'processing'
                        ? _buildProcessingState()
                        : state == 'success'
                        ? _buildSuccessState()
                        : _buildPendingState(),
                  ),
                ),
              ),

              // Bottom Button Area
              Column(
                children: [
                  if (state == 'success')
                    SizedBox(
                      width: double.infinity,
                      child: IosButton(
                        onPressed: widget.onRewardReceived,
                        child: const Text(
                          '리워드 받기',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (state == 'pending')
                    SizedBox(
                      width: double.infinity,
                      child: IosButton(
                        onPressed: widget.onBackToHome,
                        backgroundColor: Colors.grey[700],
                        child: const Text(
                          '홈으로 이동',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingState() {
    return Column(
      key: const ValueKey('processing'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Spinning Radar Screen
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * math.pi,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE6F4EA),
                  border: Border.all(color: const Color(0xFF3F9D68), width: 2),
                ),
                child: CustomPaint(painter: RadarPainter()),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
        const Text(
          'AI 판별 중…',
          style: TextStyle(
            fontFamily: '-apple-system',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F7D4F),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '촬영된 쓰레기 사진을 분석해\n종류를 분류하고 있습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: '-apple-system',
            fontSize: 14,
            height: 1.5,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    final course = widget.appState.selectedCourse;
    final points = course?.rewardPoints ?? 12;

    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success circle badge
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F4EA),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2F7D4F), width: 4),
          ),
          child: const Icon(Icons.check, color: Color(0xFF2F7D4F), size: 50),
        ),
        const SizedBox(height: 30),
        const Text(
          '인증 승인 완료!',
          style: TextStyle(
            fontFamily: '-apple-system',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF233529),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'AI 판정 결과 신뢰도가 양호하여 즉시 지급됩니다.',
          style: TextStyle(
            fontFamily: '-apple-system',
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30),

        // Reward Info Card
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2EBE5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                course?.title ?? '해안 산책로 코스',
                style: const TextStyle(
                  fontFamily: '-apple-system',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF233529),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE2EBE5)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCardBadge(Icons.stars, '$points P 적립', '포인트 리워드'),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFFE2EBE5),
                  ),
                  _buildCardBadge(
                    Icons.shopping_bag_outlined,
                    '쿠폰 발급 가능',
                    '제휴 혜택',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardBadge(IconData icon, String value, String desc) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2F7D4F), size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: '-apple-system',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F7D4F),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          desc,
          style: const TextStyle(
            fontFamily: '-apple-system',
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingState() {
    return Column(
      key: const ValueKey('pending'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2E6),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD68E3C), width: 4),
          ),
          child: const Icon(
            Icons.hourglass_empty,
            color: Color(0xFFD68E3C),
            size: 40,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          '검수 대기 중',
          style: TextStyle(
            fontFamily: '-apple-system',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF233529),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '위치 보정 범위 격차 또는 사진 화질 문제로 인해\n현장 관리자의 추가 판정이 필요합니다.\n\n결과는 영업일 기준 1일 이내로 알림 전송됩니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: '-apple-system',
            fontSize: 14,
            height: 1.5,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF2F7D4F).withValues(alpha: 0.0),
          const Color(0xFF2F7D4F).withValues(alpha: 0.5),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    // Draw scanning arc sweep
    canvas.drawCircle(center, maxRadius, sweepPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF2F7D4F).withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw target crosshairs
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      linePaint,
    );

    // Draw concentric circles
    canvas.drawCircle(center, maxRadius * 0.6, linePaint);
    canvas.drawCircle(center, maxRadius * 0.3, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

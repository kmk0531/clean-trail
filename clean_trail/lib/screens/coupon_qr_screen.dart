import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/coupon.dart';
import '../widgets/ios_button.dart';

class CouponQrScreen extends StatefulWidget {
  final Coupon coupon;
  final VoidCallback onBack;
  final Function(String) onRedeem;

  const CouponQrScreen({
    super.key,
    required this.coupon,
    required this.onBack,
    required this.onRedeem,
  });

  @override
  State<CouponQrScreen> createState() => _CouponQrScreenState();
}

class _CouponQrScreenState extends State<CouponQrScreen> {
  int _secondsRemaining = 15 * 60; // 15 minutes countdown
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBF8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2F7D4F)),
          onPressed: widget.onBack,
        ),
        title: const Text(
          '리워드 쿠폰',
          style: TextStyle(
            fontFamily: '-apple-system',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Color(0xFF233529),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Icon(
                  Icons.celebration,
                  color: Color(0xFFD68E3C),
                  size: 40,
                ),
                const SizedBox(height: 12),
                const Text(
                  '축하합니다! 쿠폰이 발급되었습니다',
                  style: TextStyle(
                    fontFamily: '-apple-system',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF233529),
                  ),
                ),
                const Text(
                  '현장 카운터에서 사장님께 아래 QR을 보여주세요.',
                  style: TextStyle(
                    fontFamily: '-apple-system',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // Coupon Card Container (with perforated details)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE2EBE5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Shop Details Header
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text(
                              widget.coupon.shopName,
                              style: const TextStyle(
                                fontFamily: '-apple-system',
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.coupon.discountDetails,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: '-apple-system',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2F7D4F),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '유효기간: ${widget.coupon.expiryDate}',
                              style: TextStyle(
                                fontFamily: '-apple-system',
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Perforated line design
                      Row(
                        children: List.generate(
                          16,
                          (i) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                      ),

                      // QR Area
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 24.0),
                        child: Column(
                          children: [
                            if (widget.coupon.isUsed)
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle_outline, color: Colors.grey, size: 64),
                                      const SizedBox(height: 10),
                                      Text(
                                        '사용 처리 완료',
                                        style: TextStyle(
                                          fontFamily: '-apple-system',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else ...[
                              // QR Container
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey[200]!, width: 2),
                                ),
                                child: CustomPaint(
                                  size: const Size(160, 160),
                                  painter: QrPainter(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Security countdown
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.timer_outlined, color: Colors.redAccent[400], size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    '만료까지 ${_formatTime(_secondsRemaining)}',
                                    style: TextStyle(
                                      fontFamily: 'ui-monospace',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent[400],
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Action buttons
                if (!widget.coupon.isUsed) ...[
                  // Simulated QR Scanner shortcut button for demo validation
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: Color(0xFF2F7D4F), width: 1.5),
                      ),
                      onPressed: () {
                        // Quick demo validation trigger
                        widget.onRedeem(widget.coupon.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('매장 사용 승인 완료 처리되었습니다!')),
                        );
                      },
                      icon: const Icon(Icons.phonelink_ring_outlined, color: Color(0xFF2F7D4F)),
                      label: const Text(
                        '매장 결제 검증 시뮬레이터 실행',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F7D4F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                SizedBox(
                  width: double.infinity,
                  child: IosButton(
                    onPressed: () {
                      // Mock map navigation to shop
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${widget.coupon.shopName} 위치 지도를 로드합니다.')),
                      );
                    },
                    backgroundColor: const Color(0xFF6A7E71),
                    child: const Text(
                      '지도에서 제휴 상점 보기',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Draw standard QR finder patterns (3 corners)
    final double patternSize = size.width * 0.28;

    void drawFinderPattern(double left, double top) {
      // Outer rect
      canvas.drawRect(Rect.fromLTWH(left, top, patternSize, patternSize), paint);
      // Inner clear space
      canvas.drawRect(
        Rect.fromLTWH(
          left + patternSize * 0.16,
          top + patternSize * 0.16,
          patternSize * 0.68,
          patternSize * 0.68,
        ),
        Paint()..color = Colors.white,
      );
      // Center solid block
      canvas.drawRect(
        Rect.fromLTWH(
          left + patternSize * 0.32,
          top + patternSize * 0.32,
          patternSize * 0.36,
          patternSize * 0.36,
        ),
        paint,
      );
    }

    drawFinderPattern(0, 0); // Top-left
    drawFinderPattern(size.width - patternSize, 0); // Top-right
    drawFinderPattern(0, size.height - patternSize); // Bottom-left

    // Draw randomized QR modules (pixels)
    final double moduleSize = size.width / 21;
    final rand = math.Random(10); // Fixed seed to draw consistent pattern

    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        // Skip finder pattern zones
        if ((r < 7 && c < 7) || (r < 7 && c >= 14) || (r >= 14 && c < 7)) {
          continue;
        }

        // Random fill module
        if (rand.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(c * moduleSize, r * moduleSize, moduleSize, moduleSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

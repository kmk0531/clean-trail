import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/coupon.dart';

class StoreScannerScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onBack;

  const StoreScannerScreen({
    super.key,
    required this.appState,
    required this.onBack,
  });

  @override
  State<StoreScannerScreen> createState() => _StoreScannerScreenState();
}

class _StoreScannerScreenState extends State<StoreScannerScreen> with SingleTickerProviderStateMixin {
  Coupon? _scannedCoupon;
  bool _isValidating = false;
  late AnimationController _scannerLineController;

  @override
  void initState() {
    super.initState();
    _scannerLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerLineController.dispose();
    super.dispose();
  }

  void _simulateScan(Coupon coupon) {
    if (_isValidating) return;
    setState(() {
      _isValidating = true;
      _scannedCoupon = null;
    });

    // Simulates scan evaluation duration
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isValidating = false;
        _scannedCoupon = coupon;
      });
      // Mark coupon as used in app state database
      widget.appState.redeemCoupon(coupon.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get all unused coupons to populate scanner target simulator
    final unusedCoupons = widget.appState.coupons.where((c) => !c.isUsed).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1E2621), // Dark mode merchant screen
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2621),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: const Text(
          '쿠폰 QR 검증 · 사장님용',
          style: TextStyle(
            fontFamily: '-apple-system',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Store Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.storefront, color: Color(0xFF3F9D68), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.appState.selectedCourse?.id == 'course_1' 
                                ? '카페 브리즈 (제휴가맹점)' 
                                : '○○ 가맹점 사장님 화면',
                            style: const TextStyle(
                              fontFamily: '-apple-system',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Viewfinder Container
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // Camera preview mock grid background
                            Positioned.fill(
                              child: Container(
                                color: Colors.black38,
                                child: Icon(Icons.qr_code_2, size: 140, color: Colors.white.withValues(alpha: 0.1)),
                              ),
                            ),

                            // Corner guides
                            _buildCornerGuide(top: 10, left: 10, isTop: true, isLeft: true),
                            _buildCornerGuide(top: 10, right: 10, isTop: true, isLeft: false),
                            _buildCornerGuide(bottom: 10, left: 10, isTop: false, isLeft: true),
                            _buildCornerGuide(bottom: 10, right: 10, isTop: false, isLeft: false),

                            // Animated scanner horizontal line
                            AnimatedBuilder(
                              animation: _scannerLineController,
                              builder: (context, child) {
                                return Positioned(
                                  top: 10 + (240 * _scannerLineController.value),
                                  left: 10,
                                  right: 10,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3F9D68),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF3F9D68).withValues(alpha: 0.8),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Scanner indicator labels
                            if (_isValidating)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black87,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(color: Color(0xFF3F9D68)),
                                      SizedBox(height: 16),
                                      Text(
                                        'QR 코드 디코딩 중...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: '-apple-system',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'QR 코드를 사각형 가이드 안에 맞추면\n자동으로 스캔이 진행됩니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // SCAN RESULTS OR STATUS
                      _buildScanResultWidget(),

                      const SizedBox(height: 30),

                      // Simulator interactive controller: lists active coupons to click
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '시뮬레이터 테스트 컨트롤 (스캔할 대상 선택)',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 13,
                            color: Color(0xFF3F9D68),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (unusedCoupons.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              '스캔 가능한 미사용 쿠폰이 없습니다.\n(플로깅 미션을 완료하여 발급받으세요)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: '-apple-system',
                                fontSize: 13,
                                color: Colors.white38,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: unusedCoupons.length,
                          itemBuilder: (context, idx) {
                            final coupon = unusedCoupons[idx];
                            return Card(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: const Icon(Icons.confirmation_number, color: Colors.white70),
                                title: Text(
                                  coupon.discountDetails,
                                  style: const TextStyle(
                                    fontFamily: '-apple-system',
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  coupon.shopName,
                                  style: const TextStyle(
                                    fontFamily: '-apple-system',
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3F9D68),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '스캔 적용',
                                    style: TextStyle(
                                      fontFamily: '-apple-system',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onTap: () => _simulateScan(coupon),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanResultWidget() {
    if (_scannedCoupon == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: Text(
            '스캔된 쿠폰 결과 대기 중...',
            style: TextStyle(
              fontFamily: '-apple-system',
              fontSize: 14,
              color: Colors.white38,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2E3D34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3F9D68), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF3F9D68), size: 20),
              SizedBox(width: 8),
              Text(
                '유효한 쿠폰 확인됨',
                style: TextStyle(
                  fontFamily: '-apple-system',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF3F9D68),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _scannedCoupon!.shopName,
            style: const TextStyle(
              fontFamily: '-apple-system',
              fontSize: 13,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _scannedCoupon!.discountDetails,
            style: const TextStyle(
              fontFamily: '-apple-system',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '✓ 사용 처리 완료 (데이터베이스 동기화됨)',
                style: TextStyle(
                  fontFamily: '-apple-system',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F9D68),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCornerGuide({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

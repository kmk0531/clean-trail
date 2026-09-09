import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/coupon.dart';
import '../models/trash_item.dart';

class MyCleanLogScreen extends StatefulWidget {
  final AppState appState;
  final Function(Coupon) onCouponSelected;

  const MyCleanLogScreen({
    super.key,
    required this.appState,
    required this.onCouponSelected,
  });

  @override
  State<MyCleanLogScreen> createState() => _MyCleanLogScreenState();
}

class _MyCleanLogScreenState extends State<MyCleanLogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Header Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '마이 클린로그',
            style: TextStyle(
              fontFamily: '-apple-system',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF233529),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Personal Stats Dashboard Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2EBE5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatMetric(
                  icon: Icons.restore_from_trash,
                  value: '${widget.appState.totalMissionCount}회',
                  label: '총 수거 횟수',
                ),
                Container(width: 1, height: 40, color: const Color(0xFFE2EBE5)),
                _buildStatMetric(
                  icon: Icons.co2,
                  value: '${widget.appState.totalWeightKg}kg',
                  label: 'CO2 저감 기여',
                  iconColor: Colors.blue[600]!,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Toggle Tabs (Mission History / Coupon Box)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEBECEE),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(2),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(fontFamily: '-apple-system', fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontFamily: '-apple-system', fontSize: 13),
              tabs: const [
                Tab(text: '미션 히스토리'),
                Tab(text: '쿠폰함'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildHistoryTab(),
              _buildCouponsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatMetric({
    required IconData icon,
    required String value,
    required String label,
    Color iconColor = const Color(0xFF2F7D4F),
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: '-apple-system',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF233529),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: '-apple-system',
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    final logs = widget.appState.logs;
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: Colors.grey[300], size: 48),
            const SizedBox(height: 10),
            const Text(
              '기록된 미션 히스토리가 없습니다.',
              style: TextStyle(fontFamily: '-apple-system', color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      physics: const BouncingScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2EBE5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F4EA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Color(0xFF2F7D4F),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.courseTitle,
                          style: const TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF233529),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${log.date} · 수거 중량: ${log.collectedWeightKg}kg',
                          style: const TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+${log.pointsEarned} P',
                        style: const TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F7D4F),
                        ),
                      ),
                      const Text(
                        '적립완료',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  )
                ],
              ),
              if (log.trashSummary.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF0F3F1)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: log.trashSummary.entries
                      .map((entry) => _buildTrashBadge(entry.key, entry.value))
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrashBadge(TrashCategory category, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            '${category.label} $count',
            style: const TextStyle(
              fontFamily: '-apple-system',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A4A41),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsTab() {
    final coupons = widget.appState.coupons;
    if (coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined, color: Colors.grey[300], size: 48),
            const SizedBox(height: 10),
            const Text(
              '보유 중인 쿠폰이 없습니다.',
              style: TextStyle(fontFamily: '-apple-system', color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      physics: const BouncingScrollPhysics(),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: coupon.isUsed ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: coupon.isUsed ? Colors.grey[300]! : const Color(0xFFE2EBE5),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: coupon.isUsed ? null : () => widget.onCouponSelected(coupon),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Coupon Icon Badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: coupon.isUsed ? Colors.grey[200] : const Color(0xFFFFF7EC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.confirmation_number_outlined,
                        color: coupon.isUsed ? Colors.grey[500] : const Color(0xFFD68E3C),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Coupon Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupon.shopName,
                            style: TextStyle(
                              fontFamily: '-apple-system',
                              fontSize: 14,
                              color: coupon.isUsed ? Colors.grey : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            coupon.discountDetails,
                            style: TextStyle(
                              fontFamily: '-apple-system',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: coupon.isUsed ? Colors.grey : const Color(0xFF233529),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '유효기간: ${coupon.expiryDate}',
                            style: TextStyle(
                              fontFamily: '-apple-system',
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Stamp/Arrow
                    if (coupon.isUsed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '사용완료',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 20,
                      )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

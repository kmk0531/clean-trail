import 'package:flutter/material.dart';
import '../state/app_state.dart';

class RankingScreen extends StatefulWidget {
  final AppState appState;

  const RankingScreen({super.key, required this.appState});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> with SingleTickerProviderStateMixin {
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
        // Screen Header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '랭킹 & 챌린지',
            style: TextStyle(
              fontFamily: '-apple-system',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF233529),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Season Challenge Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2F7D4F), Color(0xFF479E69)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2F7D4F).withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '진행 중 시즌 챌린지',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'D-12',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '여름 축제 연동 해안가 정화 작전',
                  style: TextStyle(
                    fontFamily: '-apple-system',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '협동 목표: 500kg 수거 (현재 375kg)',
                  style: TextStyle(
                    fontFamily: '-apple-system',
                    fontSize: 12,
                    color: Color(0xFFD3EBE0),
                  ),
                ),
                const SizedBox(height: 14),
                // Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.75, // 375/500 = 75%
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF099),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Custom iOS styled TabBar
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
                Tab(text: '지역별 랭킹'),
                Tab(text: '기간별 랭킹'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRegionalList(),
              _buildPeriodList(),
            ],
          ),
        ),
      ],
    );
  }

  // "지역별"/"기간별" 두 탭 모두, 현재는 Firestore users 컬렉션을 누적
  // 수거량(totalWeightKg) 기준으로 집계한 같은 랭킹을 보여준다. 이전에는
  // 각 탭이 서로 다른 5명을 하드코딩해 보여줬지만, 실제 사용자 데이터에는
  // 아직 지역/기간 구분 필드가 없어 이번 범위에서는 동일 데이터를 재사용한다
  // (탭 구조 자체는 향후 지역/기간별 집계를 붙일 수 있도록 유지).
  Widget _buildRegionalList() => _buildRankListView();

  Widget _buildPeriodList() => _buildRankListView();

  Widget _buildRankListView() {
    if (widget.appState.isLoadingRanking && widget.appState.ranking.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2F7D4F)));
    }

    final entries = widget.appState.ranking;
    if (entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            '아직 랭킹에 표시할 사용자가 없습니다.\n플로깅 미션을 완료하고 첫 랭커가 되어보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '-apple-system',
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      physics: const BouncingScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final rank = index + 1;

        Widget rankLeading;
        if (rank == 1) {
          rankLeading = const Icon(Icons.emoji_events, color: Color(0xFFD6A03C), size: 24);
        } else if (rank == 2) {
          rankLeading = const Icon(Icons.emoji_events, color: Color(0xFFB0B3C6), size: 24);
        } else if (rank == 3) {
          rankLeading = const Icon(Icons.emoji_events, color: Color(0xFFC78C5E), size: 24);
        } else {
          rankLeading = SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: const TextStyle(
                fontFamily: '-apple-system',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final displayName = entry.name.isNotEmpty ? entry.name : '익명';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              rankLeading,
              const SizedBox(width: 14),

              // Avatar placeholder
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EBE5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    displayName.substring(0, 1),
                    style: const TextStyle(
                      fontFamily: '-apple-system',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F7D4F),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontFamily: '-apple-system',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF233529),
                  ),
                ),
              ),

              // Weight Score
              Text(
                '${entry.totalWeightKg.toStringAsFixed(1)}kg',
                style: const TextStyle(
                  fontFamily: '-apple-system',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F7D4F),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

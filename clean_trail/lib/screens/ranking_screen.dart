import 'package:flutter/material.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

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

  Widget _buildRegionalList() {
    final List<Map<String, dynamic>> ranks = [
      {'rank': 1, 'name': '초록발자국', 'score': '42.5kg', 'level': 'Lv.4'},
      {'rank': 2, 'name': '바다지기', 'score': '38.1kg', 'level': 'Lv.4'},
      {'rank': 3, 'name': '에코메이트', 'score': '34.0kg', 'level': 'Lv.3'},
      {'rank': 4, 'name': '청정강산', 'score': '29.5kg', 'level': 'Lv.3'},
      {'rank': 5, 'name': '클린웨이브', 'score': '25.2kg', 'level': 'Lv.2'},
    ];

    return _buildRankListView(ranks);
  }

  Widget _buildPeriodList() {
    final List<Map<String, dynamic>> ranks = [
      {'rank': 1, 'name': '클린캠퍼', 'score': '12.4kg', 'level': 'Lv.3'},
      {'rank': 2, 'name': '초록발자국', 'score': '11.8kg', 'level': 'Lv.4'},
      {'rank': 3, 'name': '자연사랑', 'score': '10.2kg', 'level': 'Lv.2'},
      {'rank': 4, 'name': '지구지킴이', 'score': '9.5kg', 'level': 'Lv.2'},
      {'rank': 5, 'name': '해피플로거', 'score': '8.1kg', 'level': 'Lv.1'},
    ];

    return _buildRankListView(ranks);
  }

  Widget _buildRankListView(List<Map<String, dynamic>> ranks) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      physics: const BouncingScrollPhysics(),
      itemCount: ranks.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final item = ranks[index];
        final int rank = item['rank'];

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
                    item['name'].substring(0, 1),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF233529),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F4EA),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['level'],
                            style: const TextStyle(
                              fontFamily: '-apple-system',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2F7D4F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Weight Score
              Text(
                item['score'],
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

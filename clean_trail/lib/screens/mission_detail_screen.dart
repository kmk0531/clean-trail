import 'package:flutter/material.dart';
import '../models/course.dart';
import '../widgets/ios_map_widget.dart';
import '../widgets/ios_button.dart';

class MissionDetailScreen extends StatelessWidget {
  final PloggingCourse course;
  final VoidCallback onBack;
  final VoidCallback onStartMission;

  const MissionDetailScreen({
    super.key,
    required this.course,
    required this.onBack,
    required this.onStartMission,
  });

  @override
  Widget build(BuildContext context) {
    Color difficultyColor;
    if (course.difficulty == '상') {
      difficultyColor = const Color(0xFFE04F3F);
    } else if (course.difficulty == '중') {
      difficultyColor = const Color(0xFFD68E3C);
    } else {
      difficultyColor = const Color(0xFF2F7D4F);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBF8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2F7D4F)),
          onPressed: onBack,
        ),
        title: const Text(
          '코스 상세',
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Polyline Map Preview
                      SizedBox(
                        height: 220,
                        child: IosMapWidget(
                          selectedCourse: course,
                          isMissionActive: false,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Course Title & Reward Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              course.title,
                              style: const TextStyle(
                                fontFamily: '-apple-system',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF233529),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F4EA),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFC2E2CC)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars, color: Color(0xFF2F7D4F), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '+${course.rewardPoints}P 적립',
                                  style: const TextStyle(
                                    fontFamily: '-apple-system',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2F7D4F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stats Grid (Difficulty, Distance, Time)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2EBE5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('난이도', course.difficulty, difficultyColor),
                            Container(width: 1, height: 30, color: const Color(0xFFE2EBE5)),
                            _buildStatItem('거리', '${course.distanceKm} km', const Color(0xFF233529)),
                            Container(width: 1, height: 30, color: const Color(0xFFE2EBE5)),
                            _buildStatItem('예상 시간', '${course.durationMinutes}분', const Color(0xFF233529)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      const Text(
                        '코스 안내',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF233529),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description,
                        style: const TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF5A6A5E),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // TourAPI Recommendations
                      const Row(
                        children: [
                          Icon(Icons.map, color: Color(0xFF2F7D4F), size: 18),
                          SizedBox(width: 6),
                          Text(
                            '주변 관광지·음식점 TourAPI 추천',
                            style: TextStyle(
                              fontFamily: '-apple-system',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF233529),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Recommendations Horizontal List
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: course.recommendedSpots.length,
                          itemBuilder: (context, index) {
                            final spot = course.recommendedSpots[index];
                            return _buildSpotItem(spot);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Bottom Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: IosButton(
                  onPressed: onStartMission,
                  child: const Text(
                    '미션 시작',
                    style: TextStyle(
                      fontFamily: '-apple-system',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: '-apple-system',
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontFamily: '-apple-system',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSpotItem(TouristSpot spot) {
    final Color categoryColor = spot.category == '관광지'
        ? const Color(0xFF2F7D4F)
        : spot.category == '음식점'
            ? const Color(0xFFD6683C)
            : const Color(0xFF3F829D);

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Container(
              color: Colors.grey[200],
              width: double.infinity,
              child: Image.network(
                spot.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    spot.category == '음식점'
                        ? Icons.restaurant
                        : spot.category == '카페'
                            ? Icons.local_cafe
                            : Icons.photo,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ),
          // Info details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spot.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: '-apple-system',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF233529),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        spot.category,
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    Text(
                      spot.distance,
                      style: const TextStyle(
                        fontFamily: '-apple-system',
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

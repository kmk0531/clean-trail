import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/course.dart';
import '../widgets/ios_map_widget.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  final Function(PloggingCourse) onCourseSelected;

  const HomeScreen({
    super.key,
    required this.appState,
    required this.onCourseSelected,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollPhysics _scrollPhysics = const BouncingScrollPhysics();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: _scrollPhysics,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Location Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2EBE5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF2F7D4F),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '현재 위치',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.appState.locationPermissionGranted ? '○○ 해수욕장 관광단지' : '위치 권한 미정 (기본 설정)',
                        style: const TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF233529),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Map Area Title
            const Text(
              '플로깅 미션 맵',
              style: TextStyle(
                fontFamily: '-apple-system',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF233529),
              ),
            ),
            const SizedBox(height: 12),

            // Interactive Map Widget (제스처 아레나 간섭 해소를 위한 Listener 래핑)
            Listener(
              onPointerDown: (_) {
                setState(() {
                  _scrollPhysics = const NeverScrollableScrollPhysics();
                });
              },
              onPointerUp: (_) {
                setState(() {
                  _scrollPhysics = const BouncingScrollPhysics();
                });
              },
              onPointerCancel: (_) {
                setState(() {
                  _scrollPhysics = const BouncingScrollPhysics();
                });
              },
              child: SizedBox(
                height: 280,
                child: IosMapWidget(
                  selectedCourse: widget.appState.selectedCourse,
                  onSelectCourse: (course) {
                    widget.onCourseSelected(course);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Course List Title
            const Text(
              '반경 내 플로깅 코스',
              style: TextStyle(
                fontFamily: '-apple-system',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF233529),
              ),
            ),
            const SizedBox(height: 12),

            // Course Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.appState.courses.length,
              itemBuilder: (context, index) {
                final course = widget.appState.courses[index];
                return _buildCourseCard(context, course);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, PloggingCourse course) {
    Color difficultyColor;
    if (course.difficulty == '상') {
      difficultyColor = const Color(0xFFE04F3F);
    } else if (course.difficulty == '중') {
      difficultyColor = const Color(0xFFD68E3C);
    } else {
      difficultyColor = const Color(0xFF2F7D4F);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => widget.onCourseSelected(course),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon representation
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4EA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_walk,
                    color: Color(0xFF2F7D4F),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // Title and Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF233529),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${course.durationMinutes}분',
                            style: const TextStyle(
                              fontFamily: '-apple-system',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${course.distanceKm}km',
                            style: const TextStyle(
                              fontFamily: '-apple-system',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '난이도: ${course.difficulty}',
                            style: TextStyle(
                              fontFamily: '-apple-system',
                              fontSize: 12,
                              color: difficultyColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Point Badge & Arrow
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFC2E2CC)),
                      ),
                      child: Text(
                        '+${course.rewardPoints}P',
                        style: const TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F7D4F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

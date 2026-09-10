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

  void _showLocationSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '가상 사용자 위치 변경',
            style: TextStyle(
              fontFamily: '-apple-system',
              fontWeight: FontWeight.bold,
              color: Color(0xFF233529),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '앱 내의 내 위치 및 지도의 중심 좌표를 선택한 도시로 임시 전환합니다.',
                style: TextStyle(
                  fontFamily: '-apple-system',
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildLocationOption(context, '부산 (기본값)', 35.1796, 129.0756, '부산광역시청 일대 (가상)', areaCode: '6'),
              _buildLocationOption(context, '속초 (코스 주변)', 38.1913, 128.6035, '속초 해수욕장 일대 (가상)', areaCode: '32'),
              _buildLocationOption(context, '강릉 (코스 주변)', 37.7981, 128.9133, '강릉 경포호수 일대 (가상)', areaCode: '32'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationOption(BuildContext context, String title, double lat, double lng, String name, {required String areaCode}) {
    final isSelected = widget.appState.userLatitude == lat && widget.appState.userLongitude == lng;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE6F4EA) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFFC2E2CC) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: '-apple-system',
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF2F7D4F) : const Color(0xFF233529),
          ),
        ),
        subtitle: Text(
          name, 
          style: TextStyle(
            fontFamily: '-apple-system', 
            fontSize: 10,
            color: isSelected ? const Color(0xFF5C6F61) : Colors.grey,
          ),
        ),
        trailing: isSelected 
            ? const Icon(Icons.check_circle, color: Color(0xFF2F7D4F), size: 20) 
            : const Icon(Icons.circle_outlined, color: Colors.grey, size: 20),
        onTap: () {
          widget.appState.setVirtualLocation(lat, lng, name, areaCode: areaCode);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('사용자 가상 위치가 $title(으)로 전환되었습니다.'),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color(0xFF2F7D4F),
            ),
          );
        },
      ),
    );
  }

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                            widget.appState.userLocationName,
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
                  // Location Switch Button (New)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: const Color(0xFFE6F4EA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.swap_horiz, size: 14, color: Color(0xFF2F7D4F)),
                    label: const Text(
                      '변경',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F7D4F),
                      ),
                    ),
                    onPressed: () => _showLocationSelectionDialog(context),
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
                  userLatitude: widget.appState.userLatitude,
                  userLongitude: widget.appState.userLongitude,
                  onSelectCourse: (course) {
                    widget.onCourseSelected(course);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 주변 도보여행 코스 추천 (한국관광공사 TourAPI, contentTypeId=25)
            // TOUR_API_KEY 미설정이거나 결과가 없으면 섹션 자체를 숨긴다.
            if (widget.appState.nearbyWalkingCourses.isNotEmpty) ...[
              _buildWalkingCoursesSection(context),
              const SizedBox(height: 24),
            ],

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

  Widget _buildWalkingCoursesSection(BuildContext context) {
    final walkingCourses = widget.appState.nearbyWalkingCourses;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.route, color: Color(0xFF2F7D4F), size: 18),
            const SizedBox(width: 6),
            const Text(
              '주변 도보여행 코스 추천',
              style: TextStyle(
                fontFamily: '-apple-system',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF233529),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5EE),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '한국관광공사',
                style: TextStyle(
                  fontFamily: '-apple-system',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C6F61),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: walkingCourses.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _buildWalkingCourseCard(context, walkingCourses[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWalkingCourseCard(BuildContext context, TouristSpot course) {
    return Container(
      width: 168,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 64,
            width: double.infinity,
            color: const Color(0xFFE6F4EA),
            child: course.imageUrl.isNotEmpty
                ? Image.network(
                    course.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const Icon(
                      Icons.directions_walk,
                      color: Color(0xFF2F7D4F),
                      size: 28,
                    ),
                  )
                : const Icon(
                    Icons.directions_walk,
                    color: Color(0xFF2F7D4F),
                    size: 28,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: '-apple-system',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF233529),
                  ),
                ),
                if (course.distance.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '내 위치에서 ${course.distance}',
                    style: const TextStyle(
                      fontFamily: '-apple-system',
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
            color: Colors.black.withValues(alpha: 0.02),
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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/course.dart';

class IosMapWidget extends StatefulWidget {
  final PloggingCourse? selectedCourse;
  final bool isMissionActive;
  final Function(PloggingCourse)? onSelectCourse;

  const IosMapWidget({
    super.key,
    this.selectedCourse,
    this.isMissionActive = false,
    this.onSelectCourse,
  });

  @override
  State<IosMapWidget> createState() => _IosMapWidgetState();
}

class _IosMapWidgetState extends State<IosMapWidget> {
  NaverMapController? _mapController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      await Permission.locationWhenInUse.request();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _launchNaverMap(String name, double lat, double lng) async {
    final urlString = 'nmap://place?lat=$lat&lng=$lng&name=${Uri.encodeComponent(name)}&appname=com.cleantrail.app';
    final fallbackUrlString = 'https://map.naver.com/v5/search/${Uri.encodeComponent(name)}';

    final appUri = Uri.parse(urlString);
    final webUri = Uri.parse(fallbackUrlString);

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }


  @override
  void didUpdateWidget(covariant IosMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isMapReady && _mapController != null) {
      if (oldWidget.selectedCourse?.id != widget.selectedCourse?.id ||
          oldWidget.isMissionActive != widget.isMissionActive) {
        _updateMapOverlaysAndCamera();
      }
    }
  }

  void _onMapReady(NaverMapController controller) {
    _mapController = controller;
    _isMapReady = true;

    // 내 위치 표시 설정 활성화 (getLocationOverlay는 동기 호출)
    final locationOverlay = controller.getLocationOverlay();
    locationOverlay.setIsVisible(true);

    _updateMapOverlaysAndCamera();
  }

  Future<void> _updateMapOverlaysAndCamera() async {
    if (_mapController == null) return;

    // 기존 오버레이들을 깨끗이 초기화
    await _mapController!.clearOverlays();

    final course = widget.selectedCourse;
    if (course == null) {
      // 선택된 코스가 없는 경우, 기본 지도 위치 (속초 시내 중심)로 카메라 이동
      _mapController!.updateCamera(
        NCameraUpdate.withParams(
          target: const NLatLng(38.2118, 128.5995),
          zoom: 13.0,
        ),
      );
      return;
    }

    // 1. 도보 경로 선 (NPolylineOverlay) 추가
    final coords = course.pathCoordinates.map((c) => NLatLng(c['lat']!, c['lng']!)).toList();
    if (coords.isNotEmpty) {
      final polyline = NPolylineOverlay(
        id: 'course_trail_${course.id}',
        coords: coords,
        color: const Color(0xFF2F7D4F), // Primary Green
        width: 6,
      );
      _mapController!.addOverlay(polyline);
    }

    // 2. 출발지 / 도착지 마커 추가
    final startMarker = NMarker(
      id: 'start_${course.id}',
      position: NLatLng(course.startLatitude, course.startLongitude),
      caption: const NOverlayCaption(
        text: '출발지',
        color: Color(0xFF2F7D4F),
        textSize: 11,
      ),
    );
    startMarker.setOnTapListener((NMarker marker) {
      _launchNaverMap('${course.title} 출발지', course.startLatitude, course.startLongitude);
    });

    final endMarker = NMarker(
      id: 'end_${course.id}',
      position: NLatLng(course.endLatitude, course.endLongitude),
      caption: const NOverlayCaption(
        text: '도착지',
        color: Colors.red,
        textSize: 11,
      ),
    );
    endMarker.setOnTapListener((NMarker marker) {
      _launchNaverMap('${course.title} 도착지', course.endLatitude, course.endLongitude);
    });

    _mapController!.addOverlayAll({startMarker, endMarker});

    // 3. 추천 스팟 마커 추가
    final spotMarkers = <NMarker>{};
    for (var spot in course.recommendedSpots) {
      final pinColor = spot.category == '관광지'
          ? const Color(0xFF2F7D4F)
          : spot.category == '음식점'
              ? const Color(0xFFD6683C)
              : const Color(0xFF3F829D);

      final marker = NMarker(
        id: 'spot_${spot.name}',
        position: NLatLng(spot.latitude, spot.longitude),
        caption: NOverlayCaption(
          text: '${spot.name} (${spot.distance})',
          textSize: 9,
          color: pinColor,
        ),
      );
      marker.setOnTapListener((NMarker marker) {
        _launchNaverMap(spot.name, spot.latitude, spot.longitude);
      });
      spotMarkers.add(marker);
    }
    if (spotMarkers.isNotEmpty) {
      _mapController!.addOverlayAll(spotMarkers);
    }

    // 4. 경로를 아우르는 영역으로 카메라 자동 핏팅 이동
    if (coords.isNotEmpty) {
      final bounds = NLatLngBounds.from(coords);
      _mapController!.updateCamera(
        NCameraUpdate.fitBounds(bounds, padding: const EdgeInsets.all(60)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5ECE4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC8D6C5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. 실제 네이버 지도 위젯 로드
          Positioned.fill(
            child: NaverMap(
              options: const NaverMapViewOptions(
                locationButtonEnable: false, // 커스텀 버튼 활용을 위해 비활성화
                indoorEnable: true,
                logoClickEnable: false,
              ),
              onMapReady: _onMapReady,
            ),
          ),

          // 2. 나침반 장식 인디케이터
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  )
                ],
              ),
              child: const Icon(
                Icons.explore,
                color: Color(0xFF2F7D4F),
                size: 20,
              ),
            ),
          ),

          // 3. 줌 및 내 위치 컨트롤 패널
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                _buildMapControl(Icons.add, () {
                  _mapController?.updateCamera(NCameraUpdate.zoomBy(1));
                }),
                const SizedBox(height: 8),
                _buildMapControl(Icons.remove, () {
                  _mapController?.updateCamera(NCameraUpdate.zoomBy(-1));
                }),
                const SizedBox(height: 8),
                _buildMapControl(Icons.my_location, () {
                  _mapController?.setLocationTrackingMode(NLocationTrackingMode.follow);
                }, isPrimary: true),
              ],
            ),
          ),

          // 4. GPS 수신 상태 배너
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2F7D4F).withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gps_fixed,
                    color: Colors.white,
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'GPS 수신 양호',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: '-apple-system',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF2F7D4F) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          color: isPrimary ? Colors.white : const Color(0xFF666666),
          size: 18,
        ),
        onPressed: onTap,
      ),
    );
  }
}


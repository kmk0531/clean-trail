import 'dart:io';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/ios_button.dart';

class MissionVerificationScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const MissionVerificationScreen({
    super.key,
    required this.appState,
    required this.onCancel,
    required this.onSubmit,
  });

  String _formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final String hoursStr = hours.toString().padLeft(2, '0');
    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    final course = appState.selectedCourse;
    if (course == null) {
      return const Scaffold(body: Center(child: Text('진행 중인 미션이 없습니다.')));
    }

    final bool isSubmitEnabled = appState.startPhoto != null && appState.endPhoto != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBF8),
        elevation: 0,
        leading: TextButton(
          onPressed: () {
            // Confirm cancel mission dialog
            _showCancelConfirmation(context);
          },
          child: const Text(
            '포기',
            style: TextStyle(
              fontFamily: '-apple-system',
              color: Colors.redAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          course.title,
          style: const TextStyle(
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
                    children: [
                      const SizedBox(height: 16),
                      // Plogging Timer card
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F7D4F),
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
                          children: [
                            const Text(
                              '미션 진행 중',
                              style: TextStyle(
                                fontFamily: '-apple-system',
                                fontSize: 13,
                                color: Color(0xFFE6F4EA),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _formatDuration(appState.elapsedSeconds),
                              style: const TextStyle(
                                fontFamily: 'ui-monospace,SFMono-Regular,SF Pro Text',
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Auto location logging stamp
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Color(0xFFE6F4EA), size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    '현재 위치 자동 기록됨 (GPS·타임스탬프)',
                                    style: TextStyle(
                                      fontFamily: '-apple-system',
                                      fontSize: 11,
                                      color: Color(0xFFE6F4EA),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '미션 인증 전/후 촬영',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF233529),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '코스의 시작 지점과 쓰레기 수거 봉투가 함께 담긴 사진을 업로드해주세요.',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Photo Slots
                      _buildPhotoSlot(
                        context,
                        title: '① 시작 지점 사진',
                        photo: appState.startPhoto,
                        isUploading: appState.isStartPhotoUploading,
                        progress: appState.startPhotoUploadProgress,
                        onCapture: () => appState.captureStartPhoto(),
                      ),

                      const SizedBox(height: 20),

                      _buildPhotoSlot(
                        context,
                        title: '② 수거 완료 봉투 사진',
                        photo: appState.endPhoto,
                        isUploading: appState.isEndPhotoUploading,
                        progress: appState.endPhotoUploadProgress,
                        onCapture: () => appState.captureEndPhoto(),
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
                  onPressed: isSubmitEnabled ? onSubmit : null,
                  child: const Text(
                    '인증 제출',
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

  Widget _buildPhotoSlot(
    BuildContext context, {
    required String title,
    required File? photo,
    required bool isUploading,
    required double progress,
    required VoidCallback onCapture,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: '-apple-system',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF233529),
                ),
              ),
              if (photo != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4EA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check, color: Color(0xFF2F7D4F), size: 12),
                      SizedBox(width: 4),
                      Text(
                        '촬영 완료',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F7D4F),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Upload card area
          GestureDetector(
            onTap: (photo == null && !isUploading) ? onCapture : null,
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFD8E3DB),
                  style: photo == null ? BorderStyle.none : BorderStyle.solid,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (photo == null && !isUploading)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.grey[400], size: 36),
                        const SizedBox(height: 8),
                        Text(
                          '터치하여 촬영하기',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                  if (isUploading)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3,
                            color: const Color(0xFF2F7D4F),
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '업로드 중... ${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 12,
                            color: Color(0xFF2F7D4F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                  if (photo != null && !isUploading)
                    // 실제로 촬영된 사진을 그대로 표시
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(photo, fit: BoxFit.cover),
                            // Overlay stamp info
                            Positioned(
                              bottom: 8,
                              left: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'GPS STAMPED',
                                      style: TextStyle(
                                        fontFamily: 'ui-monospace',
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${appState.userLatitude.toStringAsFixed(4)}, ${appState.userLongitude.toStringAsFixed(4)}',
                                      style: TextStyle(
                                        fontFamily: 'ui-monospace',
                                        fontSize: 9,
                                        color: Colors.greenAccent[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: const Color(0xFFF2F2F7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                child: Column(
                  children: [
                    Text(
                      '미션을 포기하시겠습니까?',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '현재까지 기록된 미션 진행 시간 및 사진 정보가 초기화됩니다.',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.grey),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text(
                          '계속 진행',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            color: Colors.blueAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1, color: Colors.grey),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext); // pop dialog
                          onCancel(); // cancel mission
                        },
                        child: const Text(
                          '미션 포기',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../models/trash_item.dart';
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

    final items = appState.trashItems;
    final bool isSubmitEnabled = items.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBF8),
        elevation: 0,
        leading: TextButton(
          onPressed: () {
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
                                    '미션 진행 시간 기록 중',
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '수거한 쓰레기 기록',
                            style: TextStyle(
                              fontFamily: '-apple-system',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF233529),
                            ),
                          ),
                          if (items.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F4EA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${items.length}개 수거',
                                style: const TextStyle(
                                  fontFamily: '-apple-system',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F7D4F),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '쓰레기를 주울 때마다 사진을 찍어주세요. AI가 종류를 자동으로 분류합니다.',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 촬영 버튼
                      _buildCaptureButton(context),

                      if (items.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        ...items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildTrashLogCard(item),
                          ),
                        ),
                      ],

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
                  child: Text(
                    isSubmitEnabled ? '인증 제출 (${items.length}개)' : '인증 제출',
                    style: const TextStyle(
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

  Widget _buildCaptureButton(BuildContext context) {
    final isCapturing = appState.isCapturingTrashPhoto;
    return GestureDetector(
      onTap: isCapturing ? null : () => appState.captureTrashItem(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD8E3DB)),
        ),
        child: isCapturing
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFF2F7D4F),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '카메라 여는 중…',
                    style: TextStyle(
                      fontFamily: '-apple-system',
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F7D4F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '쓰레기 촬영하기',
                    style: TextStyle(
                      fontFamily: '-apple-system',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF233529),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTrashLogCard(TrashItem item) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE5)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              item.photo,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${appState.userLatitude.toStringAsFixed(4)}, ${appState.userLongitude.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontFamily: 'ui-monospace',
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                if (item.isClassifying)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF2F7D4F),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '종류 분류 중…',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.category!.emoji, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Text(
                          item.category!.label,
                          style: const TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F7D4F),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => appState.removeTrashItem(item.id),
            icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
            splashRadius: 20,
          ),
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

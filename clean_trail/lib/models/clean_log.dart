import 'trash_item.dart';

class PloggingLog {
  final String id;
  final String courseTitle;
  final String date;
  final double collectedWeightKg;
  final int pointsEarned;

  /// 이번 미션에서 수거한 쓰레기의 카테고리별 개수.
  /// 예: {TrashCategory.plastic: 3, TrashCategory.can: 2}
  final Map<TrashCategory, int> trashSummary;

  const PloggingLog({
    required this.id,
    required this.courseTitle,
    required this.date,
    required this.collectedWeightKg,
    required this.pointsEarned,
    this.trashSummary = const {},
  });

  int get totalTrashCount =>
      trashSummary.values.fold(0, (sum, count) => sum + count);
}

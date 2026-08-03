class PloggingLog {
  final String id;
  final String courseTitle;
  final String date;
  final double collectedWeightKg;
  final int pointsEarned;

  const PloggingLog({
    required this.id,
    required this.courseTitle,
    required this.date,
    required this.collectedWeightKg,
    required this.pointsEarned,
  });
}

import 'dart:io';

/// 쓰레기 종류 분류 카테고리.
/// AI 분류 API 연동 전까지는 시뮬레이션 값으로 채워진다.
enum TrashCategory {
  plastic('플라스틱', '♳'),
  can('캔', '🥫'),
  paper('종이', '📄'),
  glass('유리', '🍾'),
  general('일반쓰레기', '🗑️');

  final String label;
  final String emoji;
  const TrashCategory(this.label, this.emoji);
}

/// 플로깅 미션 중 촬영한 쓰레기 한 건의 기록.
/// 촬영 직후에는 [category]가 null이며(분류 중), 분류가 끝나면 채워진다.
class TrashItem {
  final String id;
  final File photo;
  TrashCategory? category;

  TrashItem({
    required this.id,
    required this.photo,
    this.category,
  });

  bool get isClassifying => category == null;
}

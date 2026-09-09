import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/trash_item.dart';

/// 온디바이스 쓰레기 종류 분류 서비스.
///
/// TrashNet 데이터셋(MIT License)으로 MobileNetV2 전이학습한 모델을 사용한다.
/// 출처: https://huggingface.co/ahmzakif/TrashNet-Classification
///
/// 모델 스펙:
/// - 입력: 224x224 RGB, float32, 0~1 정규화 (픽셀값 / 255.0)
/// - 출력: 6개 클래스 softmax 확률
/// - 클래스 순서(알파벳순, 실제 추론으로 검증 완료):
///   [cardboard, glass, metal, paper, plastic, trash]
class TrashClassifierService {
  TrashClassifierService._();
  static final TrashClassifierService instance = TrashClassifierService._();

  static const String _modelAsset = 'assets/models/trash_classifier.tflite';
  static const int _inputSize = 224;

  // TrashNet 원본 6종 라벨(알파벳순) -> 앱의 TrashCategory 매핑.
  // cardboard는 종이류로, metal은 캔류로, trash(분류 불가 쓰레기)는
  // 일반쓰레기로 합친다.
  static const List<TrashCategory> _labelToCategory = [
    TrashCategory.paper, // cardboard
    TrashCategory.glass, // glass
    TrashCategory.can, // metal
    TrashCategory.paper, // paper
    TrashCategory.plastic, // plastic
    TrashCategory.general, // trash
  ];

  Interpreter? _interpreter;
  bool _isLoading = false;

  bool get isReady => _interpreter != null;

  Future<void> _ensureLoaded() async {
    if (_interpreter != null || _isLoading) {
      // 동시 호출 시 로딩이 끝날 때까지 대기
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }
    _isLoading = true;
    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
    } catch (e) {
      debugPrint('쓰레기 분류 모델 로딩 실패: $e');
      _interpreter = null;
    } finally {
      _isLoading = false;
    }
  }

  /// 사진 파일을 분류하여 카테고리를 반환한다.
  /// 모델 로딩/추론에 실패하면 null을 반환한다 (호출부에서 폴백 처리).
  Future<TrashCategory?> classify(File photo) async {
    await _ensureLoaded();
    final interpreter = _interpreter;
    if (interpreter == null) return null;

    try {
      final input = await _preprocess(photo);
      final output = List.filled(1 * 6, 0.0).reshape([1, 6]);

      interpreter.run(input, output);

      final scores = (output[0] as List).cast<double>();
      int bestIndex = 0;
      double bestScore = scores[0];
      for (int i = 1; i < scores.length; i++) {
        if (scores[i] > bestScore) {
          bestScore = scores[i];
          bestIndex = i;
        }
      }
      return _labelToCategory[bestIndex];
    } catch (e) {
      debugPrint('쓰레기 분류 추론 실패: $e');
      return null;
    }
  }

  /// 이미지를 읽어 224x224로 리사이즈하고 0~1 float32로 정규화한
  /// [1, 224, 224, 3] 형태의 입력 텐서를 만든다.
  Future<List<List<List<List<double>>>>> _preprocess(File photo) async {
    final bytes = await photo.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('이미지 디코딩 실패');
    }

    final resized = img.copyResize(
      decoded,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );

    return List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(_inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        }),
      ),
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}

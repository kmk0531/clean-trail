import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/clean_log.dart';
import '../models/coupon.dart';
import '../models/trash_item.dart';

/// CleanTrail의 클라우드 백엔드(Firestore) 연동 서비스.
///
/// 이전까지 회원 정보/포인트/클린로그/쿠폰이 전부 기기 로컬(SharedPreferences,
/// AppState 메모리)에만 있어서, 앱을 삭제하면 계정이 통째로 사라지고 랭킹처럼
/// 여러 사용자 데이터가 필요한 기능이 애초에 동작할 수 없었다. 이 서비스는
/// Firebase Auth의 UID를 기준으로 아래 컬렉션 구조에 데이터를 저장한다:
///
///   users/{uid}                      - 프로필/누적 통계
///   users/{uid}/logs/{logId}         - 플로깅 기록 1건
///   users/{uid}/coupons/{couponId}   - 발급된 쿠폰 1건
///
/// 다른 서비스(TourApiService 등)와 같은 싱글톤 패턴을 따른다.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  /// 로그인 직후 유저 프로필 문서가 없으면 새로 만든다.
  /// 이미 있으면 아무것도 하지 않고 조용히 반환한다 (재로그인 시 기존 데이터 보존).
  Future<void> ensureUserProfile({
    required String uid,
    required String email,
    required String name,
    required String loginType,
  }) async {
    final docRef = _users.doc(uid);
    final snapshot = await docRef.get();
    if (snapshot.exists) return;

    await docRef.set({
      'email': email,
      'name': name,
      'loginType': loginType,
      'createdAt': FieldValue.serverTimestamp(),
      'totalPoints': 0,
      'totalWeightKg': 0.0,
      'totalMissionCount': 0,
    });
  }

  /// 유저 프로필(누적 통계 포함)을 가져온다. 문서가 없으면 null.
  Future<Map<String, dynamic>?> fetchUserProfile(String uid) async {
    try {
      final snapshot = await _users.doc(uid).get();
      return snapshot.data();
    } catch (e) {
      debugPrint('Firestore 유저 프로필 조회 실패: $e');
      return null;
    }
  }

  /// 미션 완료 시 누적 통계를 갱신한다 (증분 반영, 덮어쓰기 아님).
  Future<void> incrementUserStats({
    required String uid,
    required int pointsDelta,
    required double weightDeltaKg,
  }) async {
    await _users.doc(uid).update({
      'totalPoints': FieldValue.increment(pointsDelta),
      'totalWeightKg': FieldValue.increment(weightDeltaKg),
      'totalMissionCount': FieldValue.increment(1),
    });
  }

  /// 플로깅 로그 1건을 서브컬렉션에 추가한다.
  Future<void> addLog({
    required String uid,
    required PloggingLog log,
  }) async {
    await _users.doc(uid).collection('logs').doc(log.id).set({
      'courseTitle': log.courseTitle,
      'date': log.date,
      'collectedWeightKg': log.collectedWeightKg,
      'pointsEarned': log.pointsEarned,
      // Firestore는 enum 키를 직접 지원하지 않아 name 문자열로 변환해 저장한다.
      'trashSummary': log.trashSummary.map((k, v) => MapEntry(k.name, v)),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 유저의 플로깅 로그 목록을 최신순으로 가져온다.
  Future<List<PloggingLog>> fetchLogs(String uid, {int limit = 50}) async {
    try {
      final snapshot = await _users
          .doc(uid)
          .collection('logs')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final rawSummary = (data['trashSummary'] as Map<String, dynamic>?) ?? {};
        final trashSummary = <TrashCategory, int>{};
        for (final entry in rawSummary.entries) {
          final category = TrashCategory.values.where((c) => c.name == entry.key).firstOrNull;
          if (category != null) trashSummary[category] = (entry.value as num).toInt();
        }

        return PloggingLog(
          id: doc.id,
          courseTitle: data['courseTitle'] as String? ?? '',
          date: data['date'] as String? ?? '',
          collectedWeightKg: (data['collectedWeightKg'] as num?)?.toDouble() ?? 0.0,
          pointsEarned: (data['pointsEarned'] as num?)?.toInt() ?? 0,
          trashSummary: trashSummary,
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore 로그 조회 실패: $e');
      return [];
    }
  }

  /// 쿠폰 1건을 발급해 서브컬렉션에 추가한다.
  Future<void> addCoupon({
    required String uid,
    required Coupon coupon,
  }) async {
    await _users.doc(uid).collection('coupons').doc(coupon.id).set({
      'shopName': coupon.shopName,
      'discountDetails': coupon.discountDetails,
      'expiryDate': coupon.expiryDate,
      'isUsed': coupon.isUsed,
      'issuedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 유저의 쿠폰 목록을 발급 최신순으로 가져온다.
  Future<List<Coupon>> fetchCoupons(String uid) async {
    try {
      final snapshot = await _users
          .doc(uid)
          .collection('coupons')
          .orderBy('issuedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Coupon(
          id: doc.id,
          shopName: data['shopName'] as String? ?? '',
          discountDetails: data['discountDetails'] as String? ?? '',
          expiryDate: data['expiryDate'] as String? ?? '',
          isUsed: data['isUsed'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore 쿠폰 조회 실패: $e');
      return [];
    }
  }

  /// 쿠폰을 사용 처리한다. 매장 스캐너 화면에서의 검증도 이 메서드를 거친다.
  ///
  /// 반환값으로 실제 검증 결과를 구분한다:
  /// - [CouponRedeemResult.success]: 정상 사용 처리됨
  /// - [CouponRedeemResult.alreadyUsed]: 이미 사용된 쿠폰 (중복 스캔 방지)
  /// - [CouponRedeemResult.notFound]: 존재하지 않는 쿠폰(id 불일치 등)
  Future<CouponRedeemResult> redeemCoupon({
    required String uid,
    required String couponId,
  }) async {
    final docRef = _users.doc(uid).collection('coupons').doc(couponId);
    try {
      return await _db.runTransaction<CouponRedeemResult>((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return CouponRedeemResult.notFound;

        final isUsed = snapshot.data()?['isUsed'] as bool? ?? false;
        if (isUsed) return CouponRedeemResult.alreadyUsed;

        transaction.update(docRef, {
          'isUsed': true,
          'redeemedAt': FieldValue.serverTimestamp(),
        });
        return CouponRedeemResult.success;
      });
    } catch (e) {
      debugPrint('Firestore 쿠폰 사용 처리 실패: $e');
      return CouponRedeemResult.notFound;
    }
  }

  /// 회원 탈퇴 시 유저의 Firestore 데이터를 전부 삭제한다.
  /// 서브컬렉션(logs, coupons)은 상위 문서를 지운다고 자동으로 함께
  /// 삭제되지 않으므로, 문서를 하나씩 모아 배치로 지운 뒤 프로필 문서를
  /// 마지막에 삭제한다. Firebase Auth 계정 자체의 삭제는 호출하는 쪽
  /// (AppState.deleteAccount)에서 이어서 처리한다.
  Future<void> deleteUserData(String uid) async {
    final userDoc = _users.doc(uid);

    final logsSnapshot = await userDoc.collection('logs').get();
    final couponsSnapshot = await userDoc.collection('coupons').get();

    final batch = _db.batch();
    for (final doc in logsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    for (final doc in couponsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(userDoc);

    await batch.commit();
  }

  /// 누적 수거량(totalWeightKg) 기준 상위 랭킹을 가져온다.
  Future<List<RankingEntry>> fetchTopRankedUsers({int limit = 20}) async {
    try {
      final snapshot = await _users
          .orderBy('totalWeightKg', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return RankingEntry(
          uid: doc.id,
          name: data['name'] as String? ?? '익명',
          totalWeightKg: (data['totalWeightKg'] as num?)?.toDouble() ?? 0.0,
          totalPoints: (data['totalPoints'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore 랭킹 조회 실패: $e');
      return [];
    }
  }
}

enum CouponRedeemResult { success, alreadyUsed, notFound }

class RankingEntry {
  final String uid;
  final String name;
  final double totalWeightKg;
  final int totalPoints;

  const RankingEntry({
    required this.uid,
    required this.name,
    required this.totalWeightKg,
    required this.totalPoints,
  });
}

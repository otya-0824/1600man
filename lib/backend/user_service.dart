import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';

class UserService {
  // ユーザー識別は AuthService の安定uidに一本化する。
  // 初回登録(ProfileService)・プロフィール編集(このUserService)・食事記録が
  // すべて同じ users/{uid} を指すため、編集してもuidは変化せず、他のデータと結びつく。
  final AuthService _authService = AuthService();

  // Firestore の users コレクション
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // ========================================
  // プロフィールを Firebase に保存（安定uidのドキュメントを更新）
  // ========================================
  Future<String> saveProfile({
    required String gender,
    required String birthDate,
    required String goal,
    required double goalWeight,
    required double height,
    required double weight,
  }) async {
    final uid = await _authService.ensureUid();

    // merge:true で、初回登録(ProfileService)が書いた他フィールドや
    // 食事記録の集計などを消さずに、編集分だけ上書き更新する。
    await users.doc(uid).set({
      'birthDate': birthDate,
      'gender': gender,
      'goal': goal,
      'goalWeight': goalWeight,
      'height': height,
      'weight': weight,
    }, SetOptions(merge: true));

    return uid;
  }

  // ========================================
  // プロフィールを Firebase から取得
  // userId を省略した場合は現在の安定uidのドキュメントを読む。
  // ========================================
  Future<Map<String, dynamic>?> getProfile([String? userId]) async {
    final id = userId ?? await _authService.ensureUid();
    final document = await users.doc(id).get();

    if (!document.exists) {
      return null;
    }

    return document.data() as Map<String, dynamic>;
  }
}

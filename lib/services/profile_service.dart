// プロフィールのFirestore保存・読み込みを担当するサービス
//
// 「開き直してもデータが残る」仕組み：
//   1. uid（誰か）… 匿名ログインでuidを確保。端末に保存されるので再起動しても同じuidが復元される
//      ※ 本格的なログインはひろむ担当。ここは接続までの土台として匿名ログインを使う
//   2. Firestore（保存先）… users/{uid} にプロフィールを書き込む/読み込む

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';
import 'auth_service.dart';

class ProfileService {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // users/{uid} ドキュメントの参照
  Future<DocumentReference<Map<String, dynamic>>> _userDoc() async {
    final uid = await _authService.ensureUid();
    return _db.collection("users").doc(uid);
  }

  // プロフィールを保存する（登録ボタンで呼ぶ）
  Future<void> saveProfile(UserProfile profile) async {
    final doc = await _userDoc();
    // merge:true で、既存の他フィールド（食事記録の集計など）を消さずに更新
    await doc.set(profile.toMap(), SetOptions(merge: true));
  }

  // プロフィールを読み込む（起動時に呼ぶ。無ければ null）
  Future<UserProfile?> loadProfile() async {
    final doc = await _userDoc();
    final snapshot = await doc.get();
    final data = snapshot.data();
    if (data == null || !snapshot.exists) {
      return null;
    }
    return UserProfile.fromMap(data);
  }
}

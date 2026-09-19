// プロフィールの保存・読み込みを担当するサービス
//
// 「開き直してもデータが残る」仕組み：
//   1. uid（誰か）… AuthService が端末に永続化した安定uidを使う。
//      再起動・プロフィール編集でも同じuidなので、食事記録など他データと結びつく。
//   2. 保存先は2系統：
//      - ローカル(SharedPreferences)… まずここへ即時保存。Web/オフラインでも
//        確実に読めるため、目標カロリー計算(減量/増量など)がすぐ反映される。
//      - Firestore(users/{uid})… 端末間同期用の控え。失敗してもローカルは保持する。
//   読み込みはローカルを最優先し、無ければFirestoreから復元してキャッシュする。

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import 'auth_service.dart';

class ProfileService {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ローカルにプロフィールを保存するキー
  static const String _cacheKey = 'user_profile_cache';

  // users/{uid} ドキュメントの参照
  Future<DocumentReference<Map<String, dynamic>>> _userDoc() async {
    final uid = await _authService.ensureUid();
    return _db.collection("users").doc(uid);
  }

  // プロフィールを保存する（登録ボタンで呼ぶ）
  Future<void> saveProfile(UserProfile profile) async {
    final json = profile.toJson();

    // 1) まずローカルへ即時保存（Web/オフラインでも確実に残る）。
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(json));

    // 2) Firestoreにも保存（端末間同期用）。
    //    merge:true で、既存の他フィールド（食事記録の集計など）を消さずに更新。
    //    通信に失敗してもローカルは保持済みなので、ここでは握りつぶす。
    try {
      final doc = await _userDoc();
      await doc.set(json, SetOptions(merge: true));
    } catch (e) {
      // ネットワーク未整備・権限エラー等でもローカル保存で機能するため
      // 握りつぶすが、原因調査のためログには残す(セキュリティルール失効など)。
      debugPrint('[ProfileService] Firestore save failed: $e');
    }
  }

  // プロフィールを読み込む（起動時に呼ぶ。無ければ null）
  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // 1) ローカルキャッシュを最優先（高速・確実）。
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        return UserProfile.fromJson(
            jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {
        // 壊れたキャッシュは無視してFirestoreへフォールバック。
      }
    }

    // 2) 無ければFirestoreから復元（別端末で登録した場合など）し、次回用にキャッシュ。
    try {
      final doc = await _userDoc();
      final snapshot = await doc.get();
      final data = snapshot.data();
      if (data == null || !snapshot.exists) {
        return null;
      }
      final profile = UserProfile.fromJson(data);
      await prefs.setString(_cacheKey, jsonEncode(profile.toJson()));
      return profile;
    } catch (_) {
      return null;
    }
  }
}

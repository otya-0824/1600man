// ユーザー特定（uid）を担当する共通サービス
//
// 「開き直しても残る」ためには「これは前と同じ人だ」と分かる必要がある。
// そのためのuidをここで確保する。
//
// 方針: Firebase の匿名認証(Anonymous Auth)でサインインし、その uid を使う。
//   - ユーザーはログイン操作をしない（裏で自動サインイン）が、Firebaseから見ると
//     正規に認証された uid になるため、Firestore ルールを「本人のみ許可」に
//     厳格化できる（他会員のデータが見えない/触れない）。
//   - 一度サインインすると同じ端末では同じ匿名uidが復元されるため、
//     プロフィールを編集してもuidは変わらず、食事記録など他データと結びつく。
//   - 将来メール/Googleログインを追加する場合は、この匿名アカウントを
//     linkWithCredential で昇格させればデータをそのまま引き継げる。
//
//   ※ 匿名認証が失敗した環境(未有効化・オフライン等)でも画面が固まらないよう、
//     端末内生成の予備uid(SharedPreferences)にフォールバックする。

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 匿名認証が使えない場合に使う、端末内生成uidの保存キー（フォールバック用）。
  static const String _fallbackUidKey = 'app_user_uid';

  // 現在のuidを返す。
  // まず匿名認証でサインイン済みかを確認し、未サインインなら匿名サインインする。
  Future<String> ensureUid() async {
    // 既にサインイン済み（2回目以降）なら、その uid を使う。
    final current = _auth.currentUser;
    if (current != null) {
      return current.uid;
    }

    try {
      // 初回：匿名サインイン（ユーザー操作なし）。得られた uid を使う。
      final cred = await _auth.signInAnonymously();
      return cred.user!.uid;
    } catch (_) {
      // 匿名認証が未有効化・オフライン等で失敗した場合は、
      // 従来どおり端末内生成uidにフォールバックして機能は止めない。
      return _ensureFallbackUid();
    }
  }

  // フォールバック：端末内で生成・永続化するuid（認証なし）。
  Future<String> _ensureFallbackUid() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_fallbackUidKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final uid = _generateUid();
    await prefs.setString(_fallbackUidKey, uid);
    return uid;
  }

  // 端末内で衝突しにくいuidを生成する（時刻＋乱数のhex）
  String _generateUid() {
    final rng = Random.secure();
    final now = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final randomPart = List<int>.generate(8, (_) => rng.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return 'u_${now}_$randomPart';
  }

  // ログアウト（設定/ログアウトから呼ぶ想定）。匿名アカウントからサインアウトする。
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // サインアウト失敗は致命的でないため無視する。
    }
  }
}

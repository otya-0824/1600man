// ユーザー特定（uid）を担当する共通サービス
//
// 「開き直しても残る」ためには「これは前と同じ人だ」と分かる必要がある。
// そのためのuidをここで確保する。
//
// 方針: 初回に一度だけ端末内でuidを生成して SharedPreferences に永続化する。
//   以降は同じuidを読み出して使い回すため、プロフィールを編集してもuidは変化せず、
//   食事記録など同じuid配下に保存された他のデータもそのまま結びついたままになる。
//   ※ Firebase認証（匿名/本格ログイン）には依存しない土台。
//     ひろむの本格ログインが入ったら、この ensureUid() の中身を差し替えれば全機能がそのまま繋がる。

import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // 端末に保存するuidのキー
  static const String _uidKey = 'app_user_uid';

  // 現在のuidを返す（未確保なら生成して端末に保存する＝初回登録時に一度だけ作られる）
  Future<String> ensureUid() async {
    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getString(_uidKey);
    if (existing != null && existing.isNotEmpty) {
      // 既に確保済み（＝2回目以降・プロフィール編集時など）はそのまま使い回す
      return existing;
    }

    // 初回のみ新しいuidを生成して永続化する
    final uid = _generateUid();
    await prefs.setString(_uidKey, uid);
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
}

// ユーザー特定（uid）を担当する共通サービス
//
// 「開き直しても残る」ためには「これは前と同じ人だ」と分かる必要がある。
// そのためのuidをここで確保する。
// ※ 本格的なログインはひろむ担当。ログインが入るまでの土台として匿名ログインを使う。
//   ひろむのログインができたら、この ensureUid() の中身を差し替えれば全機能がそのまま繋がる。

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 現在のuidを返す（未ログインなら匿名ログインして確保する）
  Future<String> ensureUid() async {
    final current = _auth.currentUser;
    if (current != null) {
      return current.uid;
    }
    final credential = await _auth.signInAnonymously();
    return credential.user!.uid;
  }
}

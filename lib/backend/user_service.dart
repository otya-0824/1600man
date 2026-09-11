import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  // ログイン機能が無いため、単一ユーザーの固定ドキュメントIDで保存/読込する。
  // これにより「毎回 add で増える／再起動で読み戻せない」問題を防ぐ。
  static const String currentUserId = 'current';

  // Firestore の users コレクション
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // ========================================
  // プロフィールを Firebase に保存（固定ドキュメントを上書き）
  // ========================================
  Future<String> saveProfile({
    required String gender,
    required String birthDate,
    required String goal,
    required double goalWeight,
    required double height,
    required double weight,
  }) async {
    await users.doc(currentUserId).set({
      'birthDate': birthDate,
      'gender': gender,
      'goal': goal,
      'goalWeight': goalWeight,
      'height': height,
      'weight': weight,
    });

    return currentUserId;
  }

  // ========================================
  // プロフィールを Firebase から取得
  // ========================================
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final document = await users.doc(userId).get();

    if (!document.exists) {
      return null;
    }

    return document.data() as Map<String, dynamic>;
  }
}

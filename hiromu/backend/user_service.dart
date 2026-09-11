import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  // Firestoreのusersコレクション
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // ========================================
  // プロフィールをFirebaseに保存
  // ========================================
  Future<String> saveProfile({
    required String gender,
    required String birthDate,
    required String goal,
    required double goalWeight,
    required double height,
    required double weight,
  }) async {
    final document = await users.add({
      'birthDate': birthDate,
      'gender': gender,
      'goal': goal,
      'goalWeight': goalWeight,
      'height': height,
      'weight': weight,
    });

    return document.id;
  }

  // ========================================
  // プロフィールをFirebaseから取得
  // ========================================
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final document = await users.doc(userId).get();

    if (!document.exists) {
      return null;
    }

    return document.data() as Map<String, dynamic>;
  }
}
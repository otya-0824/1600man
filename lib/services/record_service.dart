// 食事記録のFirestore保存・取得を担当するサービス
//
// 保存先： users/{uid}/records/{日付}/meals/{自動ID}
//   - 日付は "2026-08-30" 形式のドキュメントで1日分をまとめる
//   - その日の食事を meals サブコレクションに1件ずつ追加していく
//
// ホーム画面には watchDailySummary() で「その日の合計」をリアルタイムに流す。

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meal.dart';
import 'auth_service.dart';

class RecordService {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 日付を "2026-08-30" 形式の文字列にする（記録ドキュメントのID用）
  String dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, "0");
    final m = date.month.toString().padLeft(2, "0");
    final d = date.day.toString().padLeft(2, "0");
    return "$y-$m-$d";
  }

  // 指定日の meals サブコレクション参照
  Future<CollectionReference<Map<String, dynamic>>> _mealsRef(
    DateTime date,
  ) async {
    final uid = await _authService.ensureUid();
    return _db
        .collection("users")
        .doc(uid)
        .collection("records")
        .doc(dateKey(date))
        .collection("meals");
  }

  // 食事を1件追加する（せなの計算結果を渡して保存）
  Future<void> addMeal(Meal meal) async {
    final meals = await _mealsRef(meal.time);
    await meals.add(meal.toMap());
  }

  // 食事を削除する
  Future<void> deleteMeal(DateTime date, String mealId) async {
    final meals = await _mealsRef(date);
    await meals.doc(mealId).delete();
  }

  // 指定日の食事一覧を一度だけ取得する
  Future<List<Meal>> fetchMeals(DateTime date) async {
    final meals = await _mealsRef(date);
    final snapshot = await meals.orderBy("time").get();
    return snapshot.docs
        .map((doc) => Meal.fromMap(doc.id, doc.data()))
        .toList();
  }

  // 指定日の食事一覧をリアルタイムに流す（追加/削除が即反映される）
  Stream<List<Meal>> watchMeals(DateTime date) async* {
    final meals = await _mealsRef(date);
    yield* meals.orderBy("time").snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Meal.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // 指定日の合計（カロリー・PFC）をリアルタイムに流す（ホーム画面用）
  Stream<DailySummary> watchDailySummary(DateTime date) {
    return watchMeals(date).map((meals) => DailySummary.fromMeals(meals));
  }
}

// ============================================================
// NutritionFacade
// ============================================================
// panpanの「栄養計算エンジン」と、okabeの「UI / Firestore」をつなぐ橋渡し役。
//
// READMEの流れ:
//   ① プロフィール → ② CalorieTargetService で目標(NutritionTarget)
//   ③ 食品名+量(g) → ④ MealCalculationService で栄養計算(MealEntry)
// を、UI側から使いやすい形にまとめている。
// ============================================================

import '../data/food_repository.dart';
import '../models/food_item.dart';
import '../models/meal.dart';
import '../models/meal_entry.dart';
import '../models/nutrition_target.dart';
import '../models/user_profile.dart';
import '../search/food_search_service.dart';
import 'calorie_target_service.dart';
import 'meal_calculation_service.dart';
import 'profile_service.dart';

class NutritionFacade {
  final ProfileService _profileService = ProfileService();
  final CalorieTargetService _targetService = CalorieTargetService();
  final FoodSearchService _searchService = FoodSearchService();

  // 食品DB(約2500件)は起動後に一度だけ読み込んで使い回す。
  List<FoodItem>? _foods;
  MealCalculationService? _calcService;

  // ------------------------------------------------------------
  // ①② 保存済みプロフィール → 目標栄養素
  // ------------------------------------------------------------
  /// Firestoreに保存済みのプロフィールから目標(NutritionTarget)を計算する。
  /// プロフィール未登録の場合は null を返す。
  Future<NutritionTarget?> loadTarget() async {
    final profile = await _profileService.loadProfile();
    if (profile == null) return null;
    return _targetService.calculate(profile);
  }

  /// 手元のプロフィールから直接目標を計算する。
  NutritionTarget targetFor(UserProfile profile) =>
      _targetService.calculate(profile);

  // ------------------------------------------------------------
  // ③④ 食品名+量(g) → 栄養計算 → Firestore保存用の Meal
  // ------------------------------------------------------------
  Future<MealCalculationService> _calc() async {
    if (_calcService != null) return _calcService!;
    _foods ??= await FoodRepository().loadFoodDatabase();
    return _calcService = MealCalculationService(_foods!);
  }

  /// 食品DB(約2500件)をキーワードで検索し、候補の FoodItem を返す。
  /// 記録画面の「栄養DB」タブで、食品を選ぶために使う。
  Future<List<FoodItem>> searchFoods(String query, {int limit = 30}) async {
    await _calc(); // 食品DBの読み込みを保証する
    final results = _searchService.search(_foods!, query);
    return results.length > limit ? results.sublist(0, limit) : results;
  }

  /// 食品名+量(g)から栄養計算した MealEntry を返す(該当無しは null)。
  /// 全栄養素を保持した panpan の計算結果をそのまま扱いたい場合に使う。
  Future<MealEntry?> calcEntry({
    required String foodName,
    required double amountGrams,
  }) async {
    final calc = await _calc();
    return calc.calculate(foodName: foodName, amountGrams: amountGrams);
  }

  /// 食品名と量(g)から栄養を計算し、Firestore保存用の Meal に変換する。
  /// 該当する食品が見つからない場合は null を返す。
  Future<Meal?> buildMeal({
    required String foodName,
    required double amountGrams,
    DateTime? time,
  }) async {
    final calc = await _calc();
    final entry = calc.calculate(foodName: foodName, amountGrams: amountGrams);
    if (entry == null) return null;
    return _toMeal(entry, time ?? DateTime.now());
  }

  // panpanの計算結果(MealEntry)を、okabeのFirestoreモデル(Meal)に橋渡しする。
  Meal _toMeal(MealEntry e, DateTime time) {
    return Meal(
      name: e.name,
      calorie: e.kcal,
      protein: e.protein,
      fat: e.fat,
      carbo: e.carbohydrate,
      time: time,
    );
  }
}

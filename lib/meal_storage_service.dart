import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'meal_model.dart';
import 'models/meal.dart';

class MealStorageService {
  static const String _storageKeyPrefix = 'daily_meal_';
  static const String _myMenuKey = 'my_menu_list';

  // 食事区分（記録は日付×区分ごとに保存している）
  static const List<String> mealTypes = ["朝食", "昼食", "夕食", "間食"];

  // 日付を "2026-08-05" 形式（ゼロ埋め）に統一する。保存キーの共通土台。
  static String dateStr(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  // --- 日常の食事記録 ---
  static Future<void> saveDailyMeal(DailyMeal meal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_storageKeyPrefix${meal.date}', meal.toJson());
  }

  static Future<DailyMeal?> getDailyMeal(String date) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('$_storageKeyPrefix$date');
    if (jsonString == null) return null;
    return DailyMeal.fromJson(jsonString);
  }

  // 指定日の合計（4区分を合算）を返す。ホーム・グラフ・カレンダーの集計元。
  static Future<DailySummary> getDailySummary(DateTime date) async {
    final ds = dateStr(date);
    double c = 0, p = 0, f = 0, carb = 0, vit = 0, min = 0;
    for (final type in mealTypes) {
      final meal = await getDailyMeal("${ds}_$type");
      if (meal == null) continue;
      for (final food in meal.foods) {
        c += food.calorie;
        p += food.protein;
        f += food.fat;
        carb += food.carbs;
        vit += food.vitamin;
        min += food.mineral;
      }
    }
    return DailySummary(
      totalCalorie: c,
      totalProtein: p,
      totalFat: f,
      totalCarbo: carb,
      totalVitamin: vit,
      totalMineral: min,
    );
  }

  // 指定日の微量栄養素(項目別)の合計を返す。キーは 'vitaminA' 等。
  // 栄養バランスのスコア算出(NutritionFeedbackService.compare)に渡す実測値。
  static Future<Map<String, double>> getDailyMicros(DateTime date) async {
    final ds = dateStr(date);
    final totals = <String, double>{};
    for (final type in mealTypes) {
      final meal = await getDailyMeal("${ds}_$type");
      if (meal == null) continue;
      for (final food in meal.foods) {
        food.micros.forEach((k, v) {
          totals[k] = (totals[k] ?? 0) + v;
        });
      }
    }
    return totals;
  }

  // 期間内(start〜endの各日)の合計をまとめて返す（キーは "2026-08-05" 形式）。
  static Future<Map<String, DailySummary>> getSummariesInRange(
    DateTime start,
    DateTime end,
  ) async {
    final result = <String, DailySummary>{};
    var day = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!day.isAfter(last)) {
      result[dateStr(day)] = await getDailySummary(day);
      day = day.add(const Duration(days: 1));
    }
    return result;
  }

  // --- ★追加：Myメニューの保存と読み出し ---
  static Future<void> saveMyMenuList(List<MyMenu> menuList) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> mapList = menuList.map((m) => m.toMap()).toList();
    await prefs.setString(_myMenuKey, json.encode(mapList));
  }

  static Future<List<MyMenu>> getMyMenuList() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_myMenuKey);
    if (jsonString == null) return [];

    List<dynamic> decodedList = json.decode(jsonString);
    return decodedList.map((item) => MyMenu.fromMap(item as Map<String, dynamic>)).toList();
  }
}
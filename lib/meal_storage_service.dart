import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'meal_model.dart';

class MealStorageService {
  static const String _storageKeyPrefix = 'daily_meal_';
  static const String _myMenuKey = 'my_menu_list';

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
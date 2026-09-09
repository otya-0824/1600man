import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/food_item.dart';

// ============================================================
// FoodRepository
// ============================================================
// assets/food_database.json から食品データを読み込む処理を担当する。
// 「データをどこから・どうやって取得するか」をこのクラスに閉じ込め、
// 画面側(UI)はデータの出どころを意識しなくてよいようにしている。
// ============================================================
class FoodRepository {
  Future<List<FoodItem>> loadFoodDatabase() async {
    final jsonString =
        await rootBundle.loadString('assets/food_database.json');

    final List<dynamic> decoded = jsonDecode(jsonString);

    final foods = decoded
        .whereType<Map>()
        .map(
          (food) => FoodItem.fromJson(Map<String, dynamic>.from(food)),
        )
        .toList();

    debugPrint('食品数: ${foods.length}');

    return foods;
  }
}

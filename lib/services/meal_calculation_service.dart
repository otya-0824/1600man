import '../models/food_item.dart';
import '../models/meal_entry.dart';
import '../search/food_search_service.dart';

// ============================================================
// MealCalculationService
// ============================================================
// フロント側から届く「食品名 + 量(g)」を受け取り、
// 栄養計算済みの MealEntry に変換するための入り口となるサービス。
//
// 想定する役割分担:
//   - フロント側：食品名(文字列)と量(g)だけを渡す
//   - バック側(このアプリ)：食品データベースと照合し、
//     100gあたりの栄養価を実際の量に換算する
//
// 名前の一致は次の順序で試みる。
//   1. 完全一致(データベースの正式名と文字列が全く同じ)
//   2. 見つからなければ、検索画面と同じ仕組み(FoodSearchService)で
//      あいまい一致(同義語・ひらがな/カタカナ変換を含む)した
//      最初の候補を採用する
//
// 【セキュリティ上の安全性について】
// フロントから届く食品名は、単純な文字列の一致比較にしか
// 使っていない(Firestoreのクエリを動的に組み立てたり、
// SQLのような形で実行したりすることは一切していない)。
// そのため、悪意のある文字列が届いても、一致する食品が
// 見つからない(null が返る)だけで、安全に処理を終えられる。
// ============================================================
class MealCalculationService {
  final List<FoodItem> foods;
  final FoodSearchService _searchService = FoodSearchService();

  MealCalculationService(this.foods);

  /// 食品名と量(g)から、栄養計算済みの MealEntry を作る。
  /// 該当する食品が1件も見つからない場合は null を返す
  /// (フロント側でエラー表示するなどの判断に使う)。
  MealEntry? calculate({
    required String foodName,
    required double amountGrams,
  }) {
    final food = _findExact(foodName) ?? _findClosest(foodName);

    if (food == null) {
      return null;
    }

    return MealEntry.fromFoodItem(food, amountGrams);
  }

  /// 複数件をまとめて計算する。
  /// 見つからなかった食品名は [notFound] に集められる
  /// (呼び出し側で警告表示などに使える)。
  List<MealEntry> calculateAll({
    required List<({String foodName, double amountGrams})> items,
    List<String>? notFound,
  }) {
    final results = <MealEntry>[];

    for (final item in items) {
      final entry = calculate(
        foodName: item.foodName,
        amountGrams: item.amountGrams,
      );

      if (entry != null) {
        results.add(entry);
      } else {
        notFound?.add(item.foodName);
      }
    }

    return results;
  }

  // ------------------------------------------------------------
  // データベースの正式名と完全に一致する食品を探す
  // ------------------------------------------------------------
  FoodItem? _findExact(String name) {
    for (final food in foods) {
      if (food.name == name) {
        return food;
      }
    }
    return null;
  }

  // ------------------------------------------------------------
  // 完全一致が無い場合、検索と同じロジックで最も近い候補を1件返す
  // ------------------------------------------------------------
  FoodItem? _findClosest(String name) {
    final results = _searchService.search(foods, name);
    return results.isNotEmpty ? results.first : null;
  }
}

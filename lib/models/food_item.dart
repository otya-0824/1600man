import '../utils/number_utils.dart';

// ============================================================
// FoodItem
// ============================================================
// 食品データベース(assets/food_database.json)の1件分を表す
// モデルクラス。値はすべて「100gあたり」の栄養価。
//
// エネルギー・PFCに加え、一般的な栄養管理アプリで扱われる
// ミネラル・ビタミンを一通り保持する。
// (ヨウ素・セレン・クロム・モリブデン・ビオチンは、食品データの
//  約半数が「未測定」であり一般的な栄養管理アプリでもあまり
//  表示されないため、今回は対象外としている)
// ============================================================
class FoodItem {
  final String name;

  // ------------------------------------------------------------
  // エネルギー・三大栄養素
  // ------------------------------------------------------------
  final double kcal;
  final double protein;
  final double fat;
  final double carbohydrate;

  // ------------------------------------------------------------
  // その他の基本項目
  // ------------------------------------------------------------
  final double fiber; // 食物繊維(g)
  final double salt; // 食塩相当量(g)
  final double cholesterol; // コレステロール(mg)

  // ------------------------------------------------------------
  // ミネラル
  // ------------------------------------------------------------
  final double potassium; // カリウム(mg)
  final double calcium; // カルシウム(mg)
  final double magnesium; // マグネシウム(mg)
  final double phosphorus; // リン(mg)
  final double iron; // 鉄(mg)
  final double zinc; // 亜鉛(mg)
  final double copper; // 銅(mg)

  // ------------------------------------------------------------
  // ビタミン
  // ------------------------------------------------------------
  final double vitaminA; // ビタミンA(μgRAE)
  final double vitaminD; // ビタミンD(μg)
  final double vitaminE; // ビタミンE(mg)
  final double vitaminK; // ビタミンK(μg)
  final double vitaminB1; // ビタミンB1(mg)
  final double vitaminB2; // ビタミンB2(mg)
  final double niacin; // ナイアシン(mgNE)
  final double vitaminB6; // ビタミンB6(mg)
  final double vitaminB12; // ビタミンB12(μg)
  final double folate; // 葉酸(μg)
  final double pantothenicAcid; // パントテン酸(mg)
  final double vitaminC; // ビタミンC(mg)
  final double biotin; // ビオチン(μg) ※食品データの約46%が未測定

  /// 元のJSONデータをそのまま保持しておく。
  /// 将来フィールドが追加された場合でも取りこぼさないようにするため。
  final Map<String, dynamic> raw;

  FoodItem({
    required this.name,
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbohydrate,
    required this.fiber,
    required this.salt,
    required this.cholesterol,
    required this.potassium,
    required this.calcium,
    required this.magnesium,
    required this.phosphorus,
    required this.iron,
    required this.zinc,
    required this.copper,
    required this.vitaminA,
    required this.vitaminD,
    required this.vitaminE,
    required this.vitaminK,
    required this.vitaminB1,
    required this.vitaminB2,
    required this.niacin,
    required this.vitaminB6,
    required this.vitaminB12,
    required this.folate,
    required this.pantothenicAcid,
    required this.vitaminC,
    required this.biotin,
    required this.raw,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name']?.toString() ?? '',
      kcal: toDouble(json['kcal']),
      protein: toDouble(json['protein']),
      fat: toDouble(json['fat']),
      carbohydrate: toDouble(json['carbohydrate']),
      fiber: toDouble(json['fiber']),
      salt: toDouble(json['salt']),
      cholesterol: toDouble(json['cholesterol']),
      potassium: toDouble(json['potassium']),
      calcium: toDouble(json['calcium']),
      magnesium: toDouble(json['magnesium']),
      phosphorus: toDouble(json['phosphorus']),
      iron: toDouble(json['iron']),
      zinc: toDouble(json['zinc']),
      copper: toDouble(json['copper']),
      vitaminA: toDouble(json['vitaminA']),
      vitaminD: toDouble(json['vitaminD']),
      vitaminE: toDouble(json['vitaminE']),
      vitaminK: toDouble(json['vitaminK']),
      vitaminB1: toDouble(json['vitaminB1']),
      vitaminB2: toDouble(json['vitaminB2']),
      niacin: toDouble(json['niacin']),
      vitaminB6: toDouble(json['vitaminB6']),
      vitaminB12: toDouble(json['vitaminB12']),
      folate: toDouble(json['folate']),
      pantothenicAcid: toDouble(json['pantothenicAcid']),
      vitaminC: toDouble(json['vitaminC']),
      biotin: toDouble(json['biotin']),
      raw: json,
    );
  }

  /// 読み仮名フィールド(kana / yomi / reading)があれば返す。
  /// 現在のデータには存在しないが、将来追加された場合に
  /// キーワード検索で利用できるようにしている。
  String get reading {
    return (raw['kana'] ?? raw['yomi'] ?? raw['reading'] ?? '').toString();
  }
}

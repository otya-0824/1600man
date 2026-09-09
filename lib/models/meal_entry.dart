import 'food_item.dart';

// ============================================================
// MealEntry
// ============================================================
// 「食事に追加された1品」を表すモデルクラス。
// FoodItem(100gあたりの値)を、実際に食べた量(g)に換算して保持する。
// ============================================================
class MealEntry {
  final String name;
  final double amount; // 食べた量(g)

  final double kcal;
  final double protein;
  final double fat;
  final double carbohydrate;

  final double fiber;
  final double salt;
  final double cholesterol;

  final double potassium;
  final double calcium;
  final double magnesium;
  final double phosphorus;
  final double iron;
  final double zinc;
  final double copper;

  final double vitaminA;
  final double vitaminD;
  final double vitaminE;
  final double vitaminK;
  final double vitaminB1;
  final double vitaminB2;
  final double niacin;
  final double vitaminB6;
  final double vitaminB12;
  final double folate;
  final double pantothenicAcid;
  final double vitaminC;
  final double biotin;

  MealEntry({
    required this.name,
    required this.amount,
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
  });

  /// 100gあたりのFoodItemを、食べた量(g)に換算してMealEntryを作る
  factory MealEntry.fromFoodItem(FoodItem food, double amount) {
    final ratio = amount / 100;

    return MealEntry(
      name: food.name,
      amount: amount,
      kcal: food.kcal * ratio,
      protein: food.protein * ratio,
      fat: food.fat * ratio,
      carbohydrate: food.carbohydrate * ratio,
      fiber: food.fiber * ratio,
      salt: food.salt * ratio,
      cholesterol: food.cholesterol * ratio,
      potassium: food.potassium * ratio,
      calcium: food.calcium * ratio,
      magnesium: food.magnesium * ratio,
      phosphorus: food.phosphorus * ratio,
      iron: food.iron * ratio,
      zinc: food.zinc * ratio,
      copper: food.copper * ratio,
      vitaminA: food.vitaminA * ratio,
      vitaminD: food.vitaminD * ratio,
      vitaminE: food.vitaminE * ratio,
      vitaminK: food.vitaminK * ratio,
      vitaminB1: food.vitaminB1 * ratio,
      vitaminB2: food.vitaminB2 * ratio,
      niacin: food.niacin * ratio,
      vitaminB6: food.vitaminB6 * ratio,
      vitaminB12: food.vitaminB12 * ratio,
      folate: food.folate * ratio,
      pantothenicAcid: food.pantothenicAcid * ratio,
      vitaminC: food.vitaminC * ratio,
      biotin: food.biotin * ratio,
    );
  }

  /// Firestoreに保存するためのMap形式に変換
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'kcal': kcal,
      'protein': protein,
      'fat': fat,
      'carbohydrate': carbohydrate,
      'fiber': fiber,
      'salt': salt,
      'cholesterol': cholesterol,
      'potassium': potassium,
      'calcium': calcium,
      'magnesium': magnesium,
      'phosphorus': phosphorus,
      'iron': iron,
      'zinc': zinc,
      'copper': copper,
      'vitaminA': vitaminA,
      'vitaminD': vitaminD,
      'vitaminE': vitaminE,
      'vitaminK': vitaminK,
      'vitaminB1': vitaminB1,
      'vitaminB2': vitaminB2,
      'niacin': niacin,
      'vitaminB6': vitaminB6,
      'vitaminB12': vitaminB12,
      'folate': folate,
      'pantothenicAcid': pantothenicAcid,
      'vitaminC': vitaminC,
      'biotin': biotin,
    };
  }
}


// ============================================================
// MealEntryListTotals
// ============================================================
// List<MealEntry> に対して、各栄養素の合計を計算する拡張メソッド。
// 「1食分の合計」にも「1日分の合計」にも同じ計算式を使い回せる。
// ============================================================
extension MealEntryListTotals on List<MealEntry> {
  double get totalKcal => fold(0.0, (sum, e) => sum + e.kcal);
  double get totalProtein => fold(0.0, (sum, e) => sum + e.protein);
  double get totalFat => fold(0.0, (sum, e) => sum + e.fat);
  double get totalCarbohydrate =>
      fold(0.0, (sum, e) => sum + e.carbohydrate);

  double get totalFiber => fold(0.0, (sum, e) => sum + e.fiber);
  double get totalSalt => fold(0.0, (sum, e) => sum + e.salt);
  double get totalCholesterol =>
      fold(0.0, (sum, e) => sum + e.cholesterol);

  double get totalPotassium => fold(0.0, (sum, e) => sum + e.potassium);
  double get totalCalcium => fold(0.0, (sum, e) => sum + e.calcium);
  double get totalMagnesium => fold(0.0, (sum, e) => sum + e.magnesium);
  double get totalPhosphorus =>
      fold(0.0, (sum, e) => sum + e.phosphorus);
  double get totalIron => fold(0.0, (sum, e) => sum + e.iron);
  double get totalZinc => fold(0.0, (sum, e) => sum + e.zinc);
  double get totalCopper => fold(0.0, (sum, e) => sum + e.copper);

  double get totalVitaminA => fold(0.0, (sum, e) => sum + e.vitaminA);
  double get totalVitaminD => fold(0.0, (sum, e) => sum + e.vitaminD);
  double get totalVitaminE => fold(0.0, (sum, e) => sum + e.vitaminE);
  double get totalVitaminK => fold(0.0, (sum, e) => sum + e.vitaminK);
  double get totalVitaminB1 => fold(0.0, (sum, e) => sum + e.vitaminB1);
  double get totalVitaminB2 => fold(0.0, (sum, e) => sum + e.vitaminB2);
  double get totalNiacin => fold(0.0, (sum, e) => sum + e.niacin);
  double get totalVitaminB6 => fold(0.0, (sum, e) => sum + e.vitaminB6);
  double get totalVitaminB12 =>
      fold(0.0, (sum, e) => sum + e.vitaminB12);
  double get totalFolate => fold(0.0, (sum, e) => sum + e.folate);
  double get totalPantothenicAcid =>
      fold(0.0, (sum, e) => sum + e.pantothenicAcid);
  double get totalVitaminC => fold(0.0, (sum, e) => sum + e.vitaminC);
  double get totalBiotin => fold(0.0, (sum, e) => sum + e.biotin);
}

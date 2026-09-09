// 食事1件のデータモデル
// せなの計算結果（カロリー・P/F/C）を受け取ってFirestoreに保存する箱

class Meal {
  final String? id; // FirestoreのドキュメントID（新規保存前はnull）
  final String name; // 食品名
  final double calorie; // kcal
  final double protein; // P (g)
  final double fat; // F (g)
  final double carbo; // C (g)
  final double vitamin; // ビタミン (mg)。手動入力で付与される
  final double mineral; // ミネラル (mg)。手動入力で付与される
  final String amount; // 表示用の量（"150g"/"1個" など）。記録一覧の再現に使う
  final DateTime time; // 食べた時刻
  final String? mealType; // 食事区分（"朝食"/"昼食"/"夕食"/"間食"）。記録画面から付与する

  const Meal({
    this.id,
    required this.name,
    required this.calorie,
    required this.protein,
    required this.fat,
    required this.carbo,
    this.vitamin = 0,
    this.mineral = 0,
    this.amount = "",
    required this.time,
    this.mealType,
  });

  // Firestoreに書き込む用（オブジェクト → Map）
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "calorie": calorie,
      "protein": protein,
      "fat": fat,
      "carbo": carbo,
      "vitamin": vitamin,
      "mineral": mineral,
      "amount": amount,
      "time": time.toIso8601String(),
      "mealType": mealType,
    };
  }

  // Firestoreから読み込む用（Map → オブジェクト）
  factory Meal.fromMap(String id, Map<String, dynamic> map) {
    return Meal(
      id: id,
      name: map["name"] as String? ?? "",
      calorie: (map["calorie"] as num?)?.toDouble() ?? 0,
      protein: (map["protein"] as num?)?.toDouble() ?? 0,
      fat: (map["fat"] as num?)?.toDouble() ?? 0,
      carbo: (map["carbo"] as num?)?.toDouble() ?? 0,
      vitamin: (map["vitamin"] as num?)?.toDouble() ?? 0,
      mineral: (map["mineral"] as num?)?.toDouble() ?? 0,
      amount: map["amount"] as String? ?? "",
      time: DateTime.tryParse(map["time"] as String? ?? "") ?? DateTime.now(),
      mealType: map["mealType"] as String?,
    );
  }
}

// その日の合計（ホーム画面の栄養サマリーに渡す）
class DailySummary {
  final double totalCalorie;
  final double totalProtein;
  final double totalFat;
  final double totalCarbo;
  final double totalVitamin;
  final double totalMineral;

  const DailySummary({
    this.totalCalorie = 0,
    this.totalProtein = 0,
    this.totalFat = 0,
    this.totalCarbo = 0,
    this.totalVitamin = 0,
    this.totalMineral = 0,
  });

  // 食事リストから合計を計算する
  factory DailySummary.fromMeals(List<Meal> meals) {
    double c = 0, p = 0, f = 0, carb = 0, vit = 0, min = 0;
    for (final m in meals) {
      c += m.calorie;
      p += m.protein;
      f += m.fat;
      carb += m.carbo;
      vit += m.vitamin;
      min += m.mineral;
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
}

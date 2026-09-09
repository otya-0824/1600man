// ============================================================
// NutritionTarget
// ============================================================
// UserProfileから算出した、1日あたりの目標値。
// エネルギー・PFCに加えて、一般的なミネラル・ビタミンの
// 推奨量(目安量・目標量)を含む。
//
// 出典：厚生労働省「日本人の食事摂取基準(2025年版)」
// (コレステロールのみ、明確な推奨量が定められていないため、
//  脂質異常症リスク低減の目安として広く使われる200mgを参考値
//  として使用している)
// ============================================================
class NutritionTarget {
  /// 基礎代謝量(kcal)
  final double bmr;

  /// 総消費カロリー(kcal) = 基礎代謝 × 活動係数
  final double tdee;

  // ------------------------------------------------------------
  // エネルギー・三大栄養素
  // ------------------------------------------------------------
  final double targetKcal;
  final double targetProtein; // g
  final double targetFat; // g
  final double targetCarbohydrate; // g

  // ------------------------------------------------------------
  // その他の基本項目
  // ------------------------------------------------------------
  final double targetFiber; // g(以上が目標)
  final double targetSalt; // g(未満が目標)
  final double targetCholesterol; // mg(参考値、未満が目安)

  // ------------------------------------------------------------
  // ミネラル
  // ------------------------------------------------------------
  final double targetPotassium; // mg(以上が目標)
  final double targetCalcium; // mg
  final double targetMagnesium; // mg
  final double targetPhosphorus; // mg
  final double targetIron; // mg
  final double targetZinc; // mg
  final double targetCopper; // mg

  // ------------------------------------------------------------
  // ビタミン
  // ------------------------------------------------------------
  final double targetVitaminA; // μgRAE
  final double targetVitaminD; // μg
  final double targetVitaminE; // mg
  final double targetVitaminK; // μg
  final double targetVitaminB1; // mg
  final double targetVitaminB2; // mg
  final double targetNiacin; // mgNE
  final double targetVitaminB6; // mg
  final double targetVitaminB12; // μg
  final double targetFolate; // μg
  final double targetPantothenicAcid; // mg
  final double targetVitaminC; // mg
  final double targetBiotin; // μg

  const NutritionTarget({
    required this.bmr,
    required this.tdee,
    required this.targetKcal,
    required this.targetProtein,
    required this.targetFat,
    required this.targetCarbohydrate,
    required this.targetFiber,
    required this.targetSalt,
    required this.targetCholesterol,
    required this.targetPotassium,
    required this.targetCalcium,
    required this.targetMagnesium,
    required this.targetPhosphorus,
    required this.targetIron,
    required this.targetZinc,
    required this.targetCopper,
    required this.targetVitaminA,
    required this.targetVitaminD,
    required this.targetVitaminE,
    required this.targetVitaminK,
    required this.targetVitaminB1,
    required this.targetVitaminB2,
    required this.targetNiacin,
    required this.targetVitaminB6,
    required this.targetVitaminB12,
    required this.targetFolate,
    required this.targetPantothenicAcid,
    required this.targetVitaminC,
    required this.targetBiotin,
  });

  /// フロント側(他画面・他アプリ)に渡すためのMap形式に変換する。
  /// キー名はそのままJSON/Firestoreのフィールド名として使える。
  Map<String, dynamic> toJson() {
    return {
      'bmr': bmr,
      'tdee': tdee,
      'targetKcal': targetKcal,
      'targetProtein': targetProtein,
      'targetFat': targetFat,
      'targetCarbohydrate': targetCarbohydrate,
      'targetFiber': targetFiber,
      'targetSalt': targetSalt,
      'targetCholesterol': targetCholesterol,
      'targetPotassium': targetPotassium,
      'targetCalcium': targetCalcium,
      'targetMagnesium': targetMagnesium,
      'targetPhosphorus': targetPhosphorus,
      'targetIron': targetIron,
      'targetZinc': targetZinc,
      'targetCopper': targetCopper,
      'targetVitaminA': targetVitaminA,
      'targetVitaminD': targetVitaminD,
      'targetVitaminE': targetVitaminE,
      'targetVitaminK': targetVitaminK,
      'targetVitaminB1': targetVitaminB1,
      'targetVitaminB2': targetVitaminB2,
      'targetNiacin': targetNiacin,
      'targetVitaminB6': targetVitaminB6,
      'targetVitaminB12': targetVitaminB12,
      'targetFolate': targetFolate,
      'targetPantothenicAcid': targetPantothenicAcid,
      'targetVitaminC': targetVitaminC,
      'targetBiotin': targetBiotin,
    };
  }
}

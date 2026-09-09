import '../models/nutrient_comparison.dart';
import '../models/nutrition_target.dart';

// ============================================================
// _NutrientSpec
// ============================================================
// 1つの栄養素を比較する際に必要な情報をまとめた内部データ。
// 項目数が多いため、比較ロジック自体は共通化し、
// 項目ごとの違い(ラベル・単位・目標値・実測値・許容範囲)だけを
// このクラスで表現している。
// ============================================================
class _NutrientSpec {
  final String label;
  final double target;
  final double actual;
  final String unit;
  final double tolerance;

  const _NutrientSpec({
    required this.label,
    required this.target,
    required this.actual,
    required this.unit,
    required this.tolerance,
  });
}


// ============================================================
// NutritionFeedbackService
// ============================================================
// 「目標値」と「実際にその日食べた量」を比較し、
// 「カロリーが多い/少ない」「たんぱく質が不足」のような
// フィードバックメッセージを生成するサービス。
//
// 対応栄養素：エネルギー・PFC・食物繊維・食塩・コレステロール・
// カリウム・カルシウム・マグネシウム・リン・鉄・亜鉛・銅・
// ビタミンA/D/E/K/B1/B2/ナイアシン/B6/B12・葉酸・
// パントテン酸・ビタミンC
//
// 判定はシンプルに「目標に対して何%か」で行っている。
// 許容範囲(tolerance)内であれば「適正」とみなし、
// 範囲外であれば「多い」または「少ない」と判定する。
// ============================================================
class NutritionFeedbackService {
  /// カロリーの許容範囲(目標の±10%以内なら適正とみなす)
  static const double _kcalTolerance = 0.10;

  /// PFCの許容範囲(目標の±15%以内なら適正とみなす)
  static const double _pfcTolerance = 0.15;

  /// ミネラル・ビタミンの許容範囲(目標の±20%以内なら適正とみなす)。
  /// 通常の食事で大幅に摂りすぎることは稀な項目が多いため、
  /// PFCよりもやや広めにしている。
  static const double _microTolerance = 0.20;

  /// 目標値と実際の摂取量を比較し、全項目の比較結果をリストで返す。
  List<NutrientComparison> compare({
    required NutritionTarget target,
    required double actualKcal,
    required double actualProtein,
    required double actualFat,
    required double actualCarbohydrate,
    required double actualFiber,
    required double actualSalt,
    required double actualCholesterol,
    required double actualPotassium,
    required double actualCalcium,
    required double actualMagnesium,
    required double actualPhosphorus,
    required double actualIron,
    required double actualZinc,
    required double actualCopper,
    required double actualVitaminA,
    required double actualVitaminD,
    required double actualVitaminE,
    required double actualVitaminK,
    required double actualVitaminB1,
    required double actualVitaminB2,
    required double actualNiacin,
    required double actualVitaminB6,
    required double actualVitaminB12,
    required double actualFolate,
    required double actualPantothenicAcid,
    required double actualVitaminC,
    required double actualBiotin,
  }) {
    // ここから、27項目それぞれについて「ラベル・目標値・実際の値・
    // 単位・許容範囲」をまとめた_NutrientSpecを1つずつ作り、
    // specsという名前のリストに入れていく。
    // 1行が長く見えるが、やっていることはどの行も同じ
    // (項目名・target・actual・unit・toleranceを詰めるだけ)。
    final specs = <_NutrientSpec>[
      _NutrientSpec(label: 'カロリー', target: target.targetKcal, actual: actualKcal, unit: 'kcal', tolerance: _kcalTolerance),
      _NutrientSpec(label: 'たんぱく質', target: target.targetProtein, actual: actualProtein, unit: 'g', tolerance: _pfcTolerance),
      _NutrientSpec(label: '脂質', target: target.targetFat, actual: actualFat, unit: 'g', tolerance: _pfcTolerance),
      _NutrientSpec(label: '炭水化物', target: target.targetCarbohydrate, actual: actualCarbohydrate, unit: 'g', tolerance: _pfcTolerance),
      _NutrientSpec(label: '食物繊維', target: target.targetFiber, actual: actualFiber, unit: 'g', tolerance: _microTolerance),
      _NutrientSpec(label: '食塩相当量', target: target.targetSalt, actual: actualSalt, unit: 'g', tolerance: _microTolerance),
      _NutrientSpec(label: 'コレステロール', target: target.targetCholesterol, actual: actualCholesterol, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: 'カリウム', target: target.targetPotassium, actual: actualPotassium, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: 'カルシウム', target: target.targetCalcium, actual: actualCalcium, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: 'マグネシウム', target: target.targetMagnesium, actual: actualMagnesium, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: 'リン', target: target.targetPhosphorus, actual: actualPhosphorus, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: '鉄', target: target.targetIron, actual: actualIron, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: '亜鉛', target: target.targetZinc, actual: actualZinc, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: '銅', target: target.targetCopper, actual: actualCopper, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: 'ビタミンA', target: target.targetVitaminA, actual: actualVitaminA, unit: 'μg', tolerance: _microTolerance),
      _NutrientSpec(label: 'ビタミンD', target: target.targetVitaminD, actual: actualVitaminD, unit: 'μg', tolerance: _microTolerance),
      _NutrientSpec(label: 'ビタミンE', target: target.targetVitaminE, actual: actualVitaminE, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: 'ビタミンK', target: target.targetVitaminK, actual: actualVitaminK, unit: 'μg', tolerance: _microTolerance),
      _NutrientSpec(label: 'ビタミンB1', target: target.targetVitaminB1, actual: actualVitaminB1, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: 'ビタミンB2', target: target.targetVitaminB2, actual: actualVitaminB2, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: 'ナイアシン', target: target.targetNiacin, actual: actualNiacin, unit: 'mgNE', tolerance: _microTolerance),
      _NutrientSpec(label: 'ビタミンB6', target: target.targetVitaminB6, actual: actualVitaminB6, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: 'ビタミンB12', target: target.targetVitaminB12, actual: actualVitaminB12, unit: 'μg', tolerance: _microTolerance),
      _NutrientSpec(label: '葉酸', target: target.targetFolate, actual: actualFolate, unit: 'μg', tolerance: _microTolerance),
      _NutrientSpec(label: 'パントテン酸', target: target.targetPantothenicAcid, actual: actualPantothenicAcid, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: 'ビタミンC', target: target.targetVitaminC, actual: actualVitaminC, unit: 'mg', tolerance: _microTolerance),
      _NutrientSpec(label: 'ビオチン', target: target.targetBiotin, actual: actualBiotin, unit: 'μg', tolerance: _microTolerance),
    ];

    // specsリスト(27項目分の_NutrientSpec)の1つ1つに対して、
    // 下の_compare()メソッドを実行し、その結果(判定済みの
    // NutrientComparison)だけを集めたリストを作って返す。
    // ".map(関数)"は「リストの各要素に、その関数を適用する」という
    // 意味(for文で1つずつ回すのと同じ結果になる、短い書き方)。
    // ".toList()"で、mapの結果を実際のリストの形に変換している。
    return specs.map(_compare).toList();
  }

  // ------------------------------------------------------------
  // 1項目分の比較を行う(メッセージも自動生成)
  // ------------------------------------------------------------
  NutrientComparison _compare(_NutrientSpec spec) {
    // まず、目標値が0以下(=そもそも目標が設定されていない)か
    // どうかを確認する。0で割り算をすると不具合が起きるため、
    // このケースは他の判定より先に、特別扱いで処理する。
    if (spec.target <= 0) {
      // 目標未設定の場合は、良い/悪いの判断がそもそもできないので
      // 便宜上「good」(適正)扱いにして、その旨のメッセージを返す。
      return NutrientComparison(
        label: spec.label,
        target: spec.target,
        actual: spec.actual,
        unit: spec.unit,
        status: ComparisonStatus.good,
        message: '${spec.label}の目標が設定されていません',
      );
    }

    // 達成率を計算する。例えば目標100・実際120なら ratio = 1.2
    // (120%摂れている、という意味)。
    final ratio = spec.actual / spec.target;

    // 達成率が「1 + 許容範囲」を超えていたら、「多い」と判定する。
    // 例：許容範囲が0.15(15%)なら、115%を超えたら「多い」。
    if (ratio > 1 + spec.tolerance) {
      return NutrientComparison(
        label: spec.label,
        target: spec.target,
        actual: spec.actual,
        unit: spec.unit,
        status: ComparisonStatus.high,
        message: '${spec.label}が多めです',
      );
    }

    // 達成率が「1 − 許容範囲」を下回っていたら、「不足」と判定する。
    // 例：許容範囲が0.15(15%)なら、85%未満なら「不足」。
    if (ratio < 1 - spec.tolerance) {
      return NutrientComparison(
        label: spec.label,
        target: spec.target,
        actual: spec.actual,
        unit: spec.unit,
        status: ComparisonStatus.low,
        message: '${spec.label}が不足しています',
      );
    }

    // ここまでの2つのif文のどちらにも当てはまらなかった場合、
    // つまり「多すぎず、少なすぎない」範囲に収まっているということ
    // なので、「適正」と判定して返す。
    return NutrientComparison(
      label: spec.label,
      target: spec.target,
      actual: spec.actual,
      unit: spec.unit,
      status: ComparisonStatus.good,
      message: '${spec.label}は適正範囲です',
    );
  }
}

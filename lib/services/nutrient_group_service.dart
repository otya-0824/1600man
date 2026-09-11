import '../models/nutrient_comparison.dart';
import '../models/nutrient_group_score.dart';

// ============================================================
// NutrientGroupService
// ============================================================
// NutritionFeedbackService.compare() が返す27項目の
// List<NutrientComparison> を受け取り、「ビタミン」「ミネラル」の
// ようなグループ単位で平均達成率をまとめるサービス。
//
// 【なぜ必要か】
// カロリー・P・F・Cはそれぞれ単位が同じ(kcal/g)なので、
// 実績を単純に合計しても意味を持つ。
// しかしビタミン・ミネラルは、項目ごとに単位(mg/μg/mgNE等)も
// 目標値の大きさもバラバラなため、生の数値のまま合計しても
// 意味のある数字にならない。
// そこで「目標に対する達成率(ratio)」に揃えたうえで平均し、
// グループ全体を1本のバーやスコアとして表示できるようにする。
// ============================================================
class NutrientGroupService {
  // ------------------------------------------------------------
  // ビタミングループに含める項目のラベル一覧。
  // NutritionFeedbackService.compare() が返す label と
  // 完全に同じ文字列である必要がある。
  // ------------------------------------------------------------
  static const List<String> vitaminLabels = [
    'ビタミンA',
    'ビタミンD',
    'ビタミンE',
    'ビタミンK',
    'ビタミンB1',
    'ビタミンB2',
    'ナイアシン',
    'ビタミンB6',
    'ビタミンB12',
    '葉酸',
    'パントテン酸',
    'ビタミンC',
    'ビオチン',
  ];

  // ------------------------------------------------------------
  // ミネラルグループに含める項目のラベル一覧。
  // ------------------------------------------------------------
  static const List<String> mineralLabels = [
    'カリウム',
    'カルシウム',
    'マグネシウム',
    'リン',
    '鉄',
    '亜鉛',
    '銅',
  ];

  // ------------------------------------------------------------
  // グループの平均達成率から、「低い/適正/多い」を判定する際の
  // 許容範囲。個別項目の判定(NutritionFeedbackServiceの
  // _microTolerance)と同じ±20%を採用し、基準を揃えている。
  // ------------------------------------------------------------
  static const double _groupTolerance = 0.20;

  /// 全比較結果(comparisons)の中から、指定したラベル一覧
  /// (labels)に含まれる項目だけを取り出し、平均達成率を計算する。
  ///
  /// 該当する項目が1件も無かった場合は null を返す
  /// (0件で平均を計算しようとすると0除算になるため、
  ///  安全のためこのケースを先にはじいている)。
  NutrientGroupScore? _averageFor({
    required List<NutrientComparison> comparisons,
    required String groupLabel,
    required List<String> labels,
  }) {
    // comparisonsの中から、labelsに含まれるものだけを絞り込む。
    final matched =
        comparisons.where((c) => labels.contains(c.label)).toList();

    // 該当する項目が1件も無ければ、平均の計算のしようがないので
    // null を返して終了する(0除算を避けるための安全策)。
    if (matched.isEmpty) {
      return null;
    }

    // 該当した項目それぞれの達成率(ratio)を合計し、件数で割って
    // 平均を求める。
    final totalRatio = matched.fold(0.0, (sum, c) => sum + c.ratio);
    final averageRatio = totalRatio / matched.length;

    // 平均達成率から、グループ全体としての判定(低い/適正/多い)を
    // 決める。個別項目の判定ロジック(NutritionFeedbackService)と
    // 同じ考え方(1.0を基準に、上下20%を「適正」とみなす)。
    final ComparisonStatus status;
    if (averageRatio > 1 + _groupTolerance) {
      status = ComparisonStatus.high;
    } else if (averageRatio < 1 - _groupTolerance) {
      status = ComparisonStatus.low;
    } else {
      status = ComparisonStatus.good;
    }

    return NutrientGroupScore(
      groupLabel: groupLabel,
      averageRatio: averageRatio,
      status: status,
      items: matched,
    );
  }

  /// ビタミングループの平均達成率を計算する。
  NutrientGroupScore? vitaminScore(List<NutrientComparison> comparisons) {
    return _averageFor(
      comparisons: comparisons,
      groupLabel: 'ビタミン',
      labels: vitaminLabels,
    );
  }

  /// ミネラルグループの平均達成率を計算する。
  NutrientGroupScore? mineralScore(List<NutrientComparison> comparisons) {
    return _averageFor(
      comparisons: comparisons,
      groupLabel: 'ミネラル',
      labels: mineralLabels,
    );
  }

  /// ビタミン・ミネラル両方のスコアをまとめて計算する便利メソッド。
  /// (該当項目が無い方はリストに含まれない)
  List<NutrientGroupScore> allGroupScores(
    List<NutrientComparison> comparisons,
  ) {
    final results = <NutrientGroupScore>[];

    final vitamin = vitaminScore(comparisons);
    if (vitamin != null) {
      results.add(vitamin);
    }

    final mineral = mineralScore(comparisons);
    if (mineral != null) {
      results.add(mineral);
    }

    return results;
  }
}

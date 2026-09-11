import 'nutrient_comparison.dart';

// ============================================================
// NutrientGroupScore
// ============================================================
// 「ビタミン」「ミネラル」のような、複数の栄養素をまとめた
// グループ全体の達成状況を表すモデル。
//
// 個々の栄養素(例：ビタミンA・ビタミンC…)はそれぞれ単位も
// 目標値も異なるため、そのままでは1つの数値として合計できない。
// そこで「目標に対する達成率(ratio)」に揃えたうえで平均し、
// グループ全体を1つのスコアとして表現できるようにしたもの。
//
// これを計算するロジック(どの栄養素をどのグループに含めるか等)は
// services/nutrient_group_service.dart にある。
// このファイルには「計算結果の入れ物」だけを定義している。
// ============================================================
class NutrientGroupScore {
  /// グループ名(例："ビタミン"、"ミネラル")
  final String groupLabel;

  /// グループに含まれる栄養素の、目標に対する達成率の平均。
  /// 1.0 = 100%(ちょうど目標通り)。
  final double averageRatio;

  /// グループ全体としての判定(低い/適正/多い)。
  final ComparisonStatus status;

  /// このスコアの元になった、個別の栄養素の比較結果一覧。
  /// (画面側で「グループの中身を1つずつ見せたい」場合に使う)
  final List<NutrientComparison> items;

  const NutrientGroupScore({
    required this.groupLabel,
    required this.averageRatio,
    required this.status,
    required this.items,
  });

  /// フロント側(他画面・他アプリ)に渡すためのMap形式に変換する。
  /// itemsは詳細情報なので、必要に応じてitems.map((i) => i.toJson())
  /// を別途呼び出す想定で、ここには含めていない
  /// (グラフの1本のバーとしては、groupLabel/averageRatio/statusの
  ///  3つがあれば十分描画できるため)。
  Map<String, dynamic> toJson() {
    return {
      'groupLabel': groupLabel,
      'averageRatio': averageRatio,
      'status': status.name,
    };
  }
}

// ============================================================
// ComparisonStatus
// ============================================================
// 目標値に対して、実際の摂取量が「少ない/適正/多い」の
// どれに当たるかを表す。
// ============================================================
enum ComparisonStatus {
  low,
  good,
  high,
}


// ============================================================
// NutrientComparison
// ============================================================
// 1つの栄養項目(カロリー・P・F・C)について、
// 目標値と実際の値を比較した結果。
// ============================================================
class NutrientComparison {
  final String label;
  final double target;
  final double actual;
  final String unit;
  final ComparisonStatus status;
  final String message;

  const NutrientComparison({
    required this.label,
    required this.target,
    required this.actual,
    required this.unit,
    required this.status,
    required this.message,
  });

  /// 実際の値と目標値の差(実際−目標)
  double get diff => actual - target;

  /// 目標値に対する達成率(0.0〜、目標が0の場合は0)
  double get ratio => target <= 0 ? 0 : actual / target;

  /// フロント側(他画面・他アプリ)に渡すためのMap形式に変換する。
  /// statusはenum名の文字列("low"/"good"/"high")として渡す。
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'target': target,
      'actual': actual,
      'unit': unit,
      'status': status.name,
      'message': message,
      'diff': diff,
      'ratio': ratio,
    };
  }
}

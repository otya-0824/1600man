// ============================================================
// GoalDurationEstimate
// ============================================================
// 目標体重に到達するまでの、おおよその期間の見積もり。
// あくまで一定のペースで進んだ場合の目安であり、
// 実際の体重変化を保証するものではない。
// ============================================================
class GoalDurationEstimate {
  /// 目標体重に到達するまでの目安週数
  final double weeksToGoal;

  /// 週あたりの体重変化量(kg)。
  /// 正の値なら増加、負の値なら減少方向。
  final double weeklyWeightChangeKg;

  const GoalDurationEstimate({
    required this.weeksToGoal,
    required this.weeklyWeightChangeKg,
  });

  Map<String, dynamic> toJson() {
    return {
      'weeksToGoal': weeksToGoal,
      'weeklyWeightChangeKg': weeklyWeightChangeKg,
    };
  }
}

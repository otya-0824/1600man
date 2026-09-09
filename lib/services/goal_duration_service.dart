import '../models/goal_duration_estimate.dart';
import '../models/user_profile.dart';
import '../utils/app_exceptions.dart';

// ============================================================
// GoalDurationService
// ============================================================
// 目標体重(goalWeight)までの、おおよその到達期間を計算する。
//
// 【設計方針：数値の二重管理を避ける】
// 「1日にどれだけカロリーを増減するか」は、
// Goal.defaultKcalAdjustment (calorie_target_service.dartが
// 目標カロリー計算に使っているのと同じ値) を"そのまま再利用"する。
//
// もしチームで「減量は-500kcalではなく-600kcalにする」といった
// 変更が決まった場合も、Goal.defaultKcalAdjustment を1箇所
// 直すだけで、目標カロリー計算・期間計算の両方に自動的に
// 反映される(このクラス自身は何も変更する必要がない)。
// ============================================================
class GoalDurationService {
  /// 体脂肪1kgあたりの熱量(kcal)の目安。
  /// 7200〜7700程度で立場により幅があるため、
  /// 既定値として持ちつつ、呼び出し側で上書きできるようにしている。
  static const double defaultKcalPerKgBodyFat = 7700;

  /// 目標体重までの目安期間を計算する。
  ///
  /// 次のいずれかの場合は null を返す(期間という概念が無いため)。
  ///   - 現在体重と目標体重が既に同じ
  ///   - 目標(Goal)の1日あたり増減が0(「維持」など)
  ///
  /// 目標(Goal)の方向性(増える/減る)と、
  /// 現在体重・目標体重の大小関係が矛盾している場合は
  /// [GoalDirectionMismatchException] を投げる
  /// (例：「減量」なのに目標体重の方が重い、といったケース)。
  GoalDurationEstimate? estimate({
    required UserProfile profile,
    required double currentWeightKg,
    required double goalWeightKg,
    double? kcalAdjustmentOverride,
    double kcalPerKgBodyFat = defaultKcalPerKgBodyFat,
  }) {
    // ここから3行：目標体重(goalWeightKg)が、UserProfileの体重と
    // 同じ現実的な範囲(20kg〜300kg)に収まっているかを確認する。
    // 範囲外なら、計算を進める前にここで例外を投げて止める。
    if (goalWeightKg < UserProfile.minWeightKg ||
        goalWeightKg > UserProfile.maxWeightKg) {
      throw ProfileOutOfRangeException(
        fieldName: 'goalWeightKg(目標体重)',
        receivedValue: goalWeightKg,
        minValue: UserProfile.minWeightKg,
        maxValue: UserProfile.maxWeightKg,
      );
    }

    final weightDiff = goalWeightKg - currentWeightKg;

    // 既に目標体重に到達している
    if (weightDiff == 0) {
      return null;
    }

    // 目標カロリー計算と同じ値を再利用する(数値の二重管理を避ける)
    final dailyKcalAdjustment =
        kcalAdjustmentOverride ?? profile.goal.defaultKcalAdjustment;

    // 「維持」など、そもそも増減が無い目標では期間を計算できない
    if (dailyKcalAdjustment == 0) {
      return null;
    }

    final weeklyWeightChangeKg =
        (dailyKcalAdjustment * 7) / kcalPerKgBodyFat;

    final weightNeedsToIncrease = weightDiff > 0;
    final planWillIncreaseWeight = weeklyWeightChangeKg > 0;

    // 目標の方向性と、体重差の向きが矛盾していないか確認する
    if (weightNeedsToIncrease != planWillIncreaseWeight) {
      throw GoalDirectionMismatchException(
        goalLabel: profile.goal.label,
        currentWeightKg: currentWeightKg,
        goalWeightKg: goalWeightKg,
      );
    }

    final weeksToGoal = (weightDiff / weeklyWeightChangeKg).abs();

    return GoalDurationEstimate(
      weeksToGoal: weeksToGoal,
      weeklyWeightChangeKg: weeklyWeightChangeKg,
    );
  }
}

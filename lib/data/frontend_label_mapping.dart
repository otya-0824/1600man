import '../models/user_profile.dart';
import '../utils/app_exceptions.dart';

// ============================================================
// フロント連携用 ラベル対応表
// ============================================================
// フロント(登録係)がFirestoreに保存する日本語ラベルの文字列と、
// こちらの Goal / ActivityLevel を対応させる表。
//
// 【重要】あえて models/user_profile.dart の label ゲッター
// (画面表示用の詳細な文言、例："軽い運動(週1〜3日)")とは
// 完全に切り離している。
// 表示用ラベルはこちらの画面デザインの都合で変わることがあるが、
// フロント連携用のラベルは相手チームとの取り決めであり、
// 変わるタイミングも理由も別物だから。
// この2つを共有すると、片方の変更がもう片方に意図せず
// 影響してしまう。
//
// フロントの表記が変わった場合は、この対応表だけを直せばよい。
// ============================================================

/// フロントの goal ラベル → Goal
/// 2026年時点でチームと確認済みの4パターンのみ。
const Map<String, Goal> goalFromFrontendLabel = {
  '減量': Goal.loseWeight,
  '維持': Goal.maintain,
  '増量': Goal.gainWeight,
  '筋トレ': Goal.muscleGain,
};

/// フロントの activityLevel ラベル → ActivityLevel
/// 2026年時点でチームと確認済みの5段階のみ。
const Map<String, ActivityLevel> activityLevelFromFrontendLabel = {
  'ほとんど運動しない': ActivityLevel.sedentary,
  '軽い運動': ActivityLevel.light,
  '普通': ActivityLevel.moderate,
  '激しい運動': ActivityLevel.active,
  '非常に激しい運動': ActivityLevel.veryActive,
};

/// フロントから届いた goal ラベルを Goal に変換する。
/// 想定外の文字列が来た場合は [UnknownLabelException] を投げる
/// (静かに既定値へフォールバックすると、フロント側の表記変更や
/// タイプミスに気づけなくなるため、あえて例外にしている)。
Goal parseGoalLabel(String label) {
  final goal = goalFromFrontendLabel[label];

  if (goal == null) {
    throw UnknownLabelException(
      fieldName: 'goal',
      receivedLabel: label,
      expectedLabels: goalFromFrontendLabel.keys.toList(),
    );
  }

  return goal;
}

/// フロントから届いた activityLevel ラベルを ActivityLevel に変換する。
/// 想定外の文字列が来た場合は [UnknownLabelException] を投げる。
ActivityLevel parseActivityLevelLabel(String label) {
  final level = activityLevelFromFrontendLabel[label];

  if (level == null) {
    throw UnknownLabelException(
      fieldName: 'activityLevel',
      receivedLabel: label,
      expectedLabels: activityLevelFromFrontendLabel.keys.toList(),
    );
  }

  return level;
}

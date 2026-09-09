// ============================================================
// UnknownLabelException
// ============================================================
// フロント(登録係)から届いた日本語ラベルが、
// こちら側で想定しているどの選択肢にも一致しなかった場合に
// 投げる例外。
//
// 「知らないラベルが来た」ことに気づかず、誤って既定値に
// 差し替えてしまう(バグを隠してしまう)ことを避けるため、
// あえて例外を投げる設計にしている。
// ============================================================
class UnknownLabelException implements Exception {
  final String fieldName;
  final String receivedLabel;
  final List<String> expectedLabels;

  UnknownLabelException({
    required this.fieldName,
    required this.receivedLabel,
    required this.expectedLabels,
  });

  @override
  String toString() {
    return 'UnknownLabelException: "$fieldName" に想定外の値 '
        '"$receivedLabel" が届きました。'
        '想定している値は $expectedLabels のいずれかです。';
  }
}


// ============================================================
// ProfileOutOfRangeException
// ============================================================
// 身長・体重・年齢が、人間として現実的にあり得ない範囲だった
// 場合に投げる例外。
//
// アプリの入力画面(UI)を経由しない経路(Firestoreへの直接書き込み、
// フロント側の別画面からのデータなど)でも異常値を検知できるよう、
// UserProfile自身が持つ validate() から投げられる想定。
// ============================================================
class ProfileOutOfRangeException implements Exception {
  final String fieldName;
  final num receivedValue;
  final num minValue;
  final num maxValue;

  ProfileOutOfRangeException({
    required this.fieldName,
    required this.receivedValue,
    required this.minValue,
    required this.maxValue,
  });

  @override
  String toString() {
    return 'ProfileOutOfRangeException: "$fieldName" の値 '
        '$receivedValue が現実的な範囲($minValue〜$maxValue)の外です。';
  }
}

// ============================================================
// GoalDirectionMismatchException
// ============================================================
// 目標(減量/増量など)と、現在体重・目標体重の大小関係が
// 矛盾している場合に投げる例外。
// (例：「減量」が選ばれているのに、目標体重が現在体重より重い)
// ============================================================
class GoalDirectionMismatchException implements Exception {
  final String goalLabel;
  final double currentWeightKg;
  final double goalWeightKg;

  GoalDirectionMismatchException({
    required this.goalLabel,
    required this.currentWeightKg,
    required this.goalWeightKg,
  });

  @override
  String toString() {
    return 'GoalDirectionMismatchException: 目標「$goalLabel」に対して、'
        '現在体重(${currentWeightKg}kg)と目標体重(${goalWeightKg}kg)の'
        '大小関係が矛盾しています。';
  }
}

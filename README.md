# 栄養計算エンジン(バックエンド計算部分)

このフォルダには、「身長・体重・目標などのプロフィール」と
「食べた食品名+量(g)」から、目標カロリー・PFC・栄養バランスの
計算だけを行うロジックが入っています。

**画面(UI)やFirestoreへの保存処理は含まれていません。**
それらは別の担当の方が用意する前提で、この計算部分だけを
切り出しています。

---

## フォルダ構成

```
lib/
├── models/     … データの入れ物(型)を定義
├── data/       … 食品データベースの読み込み、ラベル変換の対応表
├── utils/      … 汎用の小さな補助関数・例外クラス
├── search/     … 食品のキーワード検索ロジック
└── services/   … 実際の計算を行うクラス(★ここが本体)
```

`assets/food_database.json` は、食品成分データベース(約2500件)です。
`pubspec.yaml` の `flutter: assets:` にこのファイルのパスを
追加しておく必要があります。

---

## 全体の流れ(誰が何を渡すか)

```
① Firebase担当のコードから
      UserProfile を受け取る(身長・体重・年齢・性別・活動量・目標)
    ↓
② CalorieTargetService.calculate(profile)
      → NutritionTarget(目標カロリー・PFC・ビタミン・ミネラル)を返す
    ↓
③ フロントから「食品名 + 量(g)」を受け取る
    ↓
④ MealCalculationService.calculate(foodName, amountGrams)
      → MealEntry(栄養計算済みの1品分のデータ)を返す
    ↓
⑤ MealEntry を「食品名+量」とセットでローカル保存担当に渡す
    ↓
⑥ その日の MealEntry のリストがまとまったら、
      NutritionFeedbackService.compare(target: ..., actualKcal: ...)
      → NutrientComparison のリスト(「不足しています」等の判定)を返す
    ↓
⑦ ②・④・⑥の結果をフロントに渡して画面表示
```

---

## ①② プロフィール → 目標値の計算

```dart
import 'models/user_profile.dart';
import 'services/calorie_target_service.dart';

// Firebase担当のコードから受け取った値を、UserProfileの形にする
final profile = UserProfile(
  heightCm: 156,
  weightKg: 44,
  age: 20,                       // 生年月日からの年齢計算は utils/date_utils.dart を参照
  gender: Gender.male,
  activityLevel: ActivityLevel.moderate,
  goal: Goal.muscleGain,
);

// 念のため、現実的な範囲かどうかを確認する(推奨)
// 範囲外なら ProfileOutOfRangeException が投げられる
profile.validate();

// 目標値を計算する
final target = CalorieTargetService().calculate(profile);

print(target.targetKcal);      // 目標カロリー
print(target.targetProtein);   // 目標たんぱく質(g)
print(target.targetCalcium);   // 目標カルシウム(mg) など、全28項目
```

### 生年月日から年齢を計算したい場合

```dart
import 'utils/date_utils.dart';

final age = calculateAgeFromBirthDate('2006-3-6'); // "yyyy-M-d"形式
```

### 目標・運動量が日本語ラベルで届く場合の変換

```dart
import 'data/frontend_label_mapping.dart';

final goal = parseGoalLabel('筋トレ');                 // Goal.muscleGain
final level = parseActivityLevelLabel('普通');          // ActivityLevel.moderate
// 想定外の文字列が来た場合は UnknownLabelException が投げられる
```

---

## ③④⑤ 食品名+量 → 栄養計算 → 渡す

```dart
import 'data/food_repository.dart';
import 'services/meal_calculation_service.dart';

// 食品データベースを読み込む(アプリ起動時に1回でよい)
final foods = await FoodRepository().loadFoodDatabase();
final calcService = MealCalculationService(foods);

// フロントから届いた「食品名+量」を計算する
final entry = calcService.calculate(
  foodName: '普通牛乳',   // 完全一致しなくても、検索と同じ仕組みであいまい一致する
  amountGrams: 200,
);

if (entry == null) {
  // 該当する食品が見つからなかった場合の処理
} else {
  // entry.kcal / entry.protein / entry.calcium など、
  // 実際に食べた量に換算済みの値が入っている。
  // この entry を、食品名+量とセットでローカル保存担当に渡す。
}
```

複数の食品をまとめて計算したい場合は `calcService.calculateAll(...)` も使えます
(`services/meal_calculation_service.dart` 内にコメント付きで説明があります)。

---

## ⑥ 目標との比較(「不足しています」等の判定)

ローカル保存担当から、その日食べた `MealEntry` のリストが返ってきたら、
以下のように合計を出してから比較します。

```dart
import 'models/meal_entry.dart'; // List<MealEntry> の合計を出す拡張メソッドを含む
import 'services/nutrition_feedback_service.dart';

List<MealEntry> todayEntries = ...; // ローカル保存担当から受け取ったその日の記録

final comparisons = NutritionFeedbackService().compare(
  target: target, // ②で計算したNutritionTarget
  actualKcal: todayEntries.totalKcal,
  actualProtein: todayEntries.totalProtein,
  actualFat: todayEntries.totalFat,
  actualCarbohydrate: todayEntries.totalCarbohydrate,
  actualFiber: todayEntries.totalFiber,
  actualSalt: todayEntries.totalSalt,
  actualCholesterol: todayEntries.totalCholesterol,
  actualPotassium: todayEntries.totalPotassium,
  actualCalcium: todayEntries.totalCalcium,
  actualMagnesium: todayEntries.totalMagnesium,
  actualPhosphorus: todayEntries.totalPhosphorus,
  actualIron: todayEntries.totalIron,
  actualZinc: todayEntries.totalZinc,
  actualCopper: todayEntries.totalCopper,
  actualVitaminA: todayEntries.totalVitaminA,
  actualVitaminD: todayEntries.totalVitaminD,
  actualVitaminE: todayEntries.totalVitaminE,
  actualVitaminK: todayEntries.totalVitaminK,
  actualVitaminB1: todayEntries.totalVitaminB1,
  actualVitaminB2: todayEntries.totalVitaminB2,
  actualNiacin: todayEntries.totalNiacin,
  actualVitaminB6: todayEntries.totalVitaminB6,
  actualVitaminB12: todayEntries.totalVitaminB12,
  actualFolate: todayEntries.totalFolate,
  actualPantothenicAcid: todayEntries.totalPantothenicAcid,
  actualVitaminC: todayEntries.totalVitaminC,
  actualBiotin: todayEntries.totalBiotin,
);

// comparisons は27項目分の判定結果のリスト。
// 各要素は label(栄養素名)・target(目標)・actual(実績)・
// status(low/good/high)・message(表示用の文言)を持つ。
```

---

## おまけ:目標体重までの期間

```dart
import 'services/goal_duration_service.dart';

final estimate = GoalDurationService().estimate(
  profile: profile,
  currentWeightKg: 44,
  goalWeightKg: 88,
);

if (estimate != null) {
  print('目標まで約${estimate.weeksToGoal.toStringAsFixed(0)}週間');
}
// 「維持」目標など、期間の概念が無い場合は null が返る。
// 現在体重と目標体重の増減方向が矛盾している場合は
// GoalDirectionMismatchException が投げられる。
```

---

## エラー処理について

このエンジンは、想定外の値が来た場合に「静かに握りつぶす」のではなく、
基本的に例外(Exception)を投げる設計にしています。
呼び出す側で `try-catch` して、画面にエラーメッセージを出す、
といった対応をお願いします。

| 例外クラス | 投げられる場面 |
|---|---|
| `ProfileOutOfRangeException` | 身長・体重・年齢・目標体重が現実的な範囲の外だったとき |
| `UnknownLabelException` | goal/activityLevelの日本語ラベルが想定外だったとき |
| `GoalDirectionMismatchException` | 目標(減量等)と体重の増減方向が矛盾していたとき |

(定義場所：`utils/app_exceptions.dart`)

---

## 質問がある場合

各ファイルの中に、処理の意図を説明するコメントを多めに入れています。
迷ったときはまずファイル内のコメントを見ていただき、
それでも分からない点があれば都度確認してください。

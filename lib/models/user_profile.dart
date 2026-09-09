// ============================================================
// Gender
// ============================================================
// 基礎代謝(BMR)の計算式で使用する、生物学的な性別の区分。
// Mifflin-St Jeor式は男女で計算式の定数が異なるため必要になる。
// ============================================================
enum Gender {
  male,
  female,
}

extension GenderLabel on Gender {
  String get label {
    switch (this) {
      case Gender.male:
        return '男性';
      case Gender.female:
        return '女性';
    }
  }
}


// ============================================================
// ActivityLevel
// ============================================================
// 日常の活動量・運動量のレベル。
// 基礎代謝(BMR)に掛け合わせて、TDEE(総消費カロリー)を求める際の
// 活動係数として使用する。
// ============================================================
enum ActivityLevel {
  /// ほとんど運動しない(デスクワーク中心)
  sedentary,

  /// 軽い運動・スポーツ(週1〜3日)
  light,

  /// 中程度の運動・スポーツ(週3〜5日)
  moderate,

  /// 激しい運動・スポーツ(週6〜7日)
  active,

  /// 非常に激しい運動 + 肉体労働
  veryActive,
}

extension ActivityLevelInfo on ActivityLevel {
  /// 活動係数(基礎代謝に掛け合わせてTDEEを求める)
  double get factor {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
    }
  }

  /// 画面表示用のラベル
  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'ほとんど運動しない';
      case ActivityLevel.light:
        return '軽い運動(週1〜3日)';
      case ActivityLevel.moderate:
        return '中程度の運動(週3〜5日)';
      case ActivityLevel.active:
        return '激しい運動(週6〜7日)';
      case ActivityLevel.veryActive:
        return '非常に激しい運動・肉体労働';
    }
  }
}


// ============================================================
// Goal
// ============================================================
// 減量・維持・増量・筋トレなどの目標。
// TDEEからの増減幅(kcal)、およびたんぱく質量の目安に使用する。
// ============================================================
enum Goal {
  /// 減量(TDEEから減らす)
  loseWeight,

  /// 現状維持
  maintain,

  /// 増量(TDEEに上乗せする、体重を増やすことを重視)
  gainWeight,

  /// 筋トレ(小さめの増減で、たんぱく質を多めに確保する)
  muscleGain,
}

extension GoalInfo on Goal {
  /// TDEEに対する増減量(kcal)の目安。
  /// 減量: 週あたり約0.5kgの減少を想定した一般的な目安値。
  /// 増量: 週あたり約0.3〜0.5kgの増加を想定した一般的な目安値。
  /// 筋トレ: 体脂肪の増加を抑えつつ筋肉をつけるための、
  ///        小さめのカロリー余剰(リーンバルク)を想定。
  /// あくまで目安であり、個人差があることに注意。
  double get defaultKcalAdjustment {
    switch (this) {
      case Goal.loseWeight:
        return -500;
      case Goal.maintain:
        return 0;
      case Goal.gainWeight:
        return 400;
      case Goal.muscleGain:
        return 200;
    }
  }

  /// 体重1kgあたりのたんぱく質目標量(g)。
  /// 筋トレ目標では、筋肉の合成を優先して多めに設定している。
  /// 減量時も、筋肉量の維持のためやや多めに設定している。
  double get defaultProteinPerKg {
    switch (this) {
      case Goal.loseWeight:
        return 2.0;
      case Goal.maintain:
        return 1.6;
      case Goal.gainWeight:
        return 1.8;
      case Goal.muscleGain:
        return 2.2;
    }
  }

  String get label {
    switch (this) {
      case Goal.loseWeight:
        return '減量';
      case Goal.maintain:
        return '維持';
      case Goal.gainWeight:
        return '増量';
      case Goal.muscleGain:
        return '筋トレ';
    }
  }
}


import '../utils/app_exceptions.dart';
// ↑ 範囲外の値を検知したときに投げる ProfileOutOfRangeException を
//   ここから読み込む(このファイルの外、utilsフォルダに定義されている)

// ============================================================
// UserProfile
// ============================================================
// 目標カロリー・PFCを計算するために必要な、ユーザーの身体情報。
// ============================================================
class UserProfile {
  // ------------------------------------------------------------
  // 現実的な範囲(セキュリティ・データ品質のガード用)
  // ------------------------------------------------------------
  // ここから4行：身長の下限。50cm未満はあり得ないため、これより
  // 小さい値が来たら異常値として弾く。
  static const double minHeightCm = 50;
  // 身長の上限。250cmを超える値は現実的でないため異常値とする。
  static const double maxHeightCm = 250;
  // 体重の下限。20kg未満は極端な低体重で通常あり得ないため弾く。
  static const double minWeightKg = 20;
  // 体重の上限。300kgを超える値は現実的でないため異常値とする。
  static const double maxWeightKg = 300;
  // 年齢の下限。0歳未満(マイナス)はあり得ないので弾く。
  static const int minAge = 0;
  // 年齢の上限。120歳を超える値は現実的でないため異常値とする。
  static const int maxAge = 120;

  // 身長(cm)。上のminHeightCm〜maxHeightCmの範囲であることを想定。
  final double heightCm;
  // 体重(kg)。上のminWeightKg〜maxWeightKgの範囲であることを想定。
  final double weightKg;
  // 年齢(歳)。上のminAge〜maxAgeの範囲であることを想定。
  final int age;
  // 性別。基礎代謝(BMR)の計算式で使う(上のGender enumを参照)。
  final Gender gender;
  // 活動量。TDEE(総消費カロリー)の計算で使う(上のActivityLevelを参照)。
  final ActivityLevel activityLevel;
  // 目標(減量/維持/増量/筋トレ)。カロリー・PFCの目標値計算で使う。
  final Goal goal;

  // コンストラクタ。すべての項目を必須(required)にしている。
  // 値の中身が正しいかどうかまではここではチェックしない
  // (チェックは下のvalidate()を呼んで行う設計にしている)。
  const UserProfile({
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.goal,
  });

  // ------------------------------------------------------------
  // validate()
  // ------------------------------------------------------------
  // 身長・体重・年齢が、上で定義した現実的な範囲に収まっているかを
  // チェックする。
  //
  // 【なぜ必要か】
  // 画面の入力チェック(バリデーション)だけでは、
  // 「アプリを経由しない書き込み」(Firestoreへの直接書き込みなど)
  // までは防げない。このメソッドを、値を受け取った直後
  // (Firestoreから読み込んだ直後や、フロントからデータを
  //  受け取った直後)に呼ぶことで、どの経路から来た値であっても
  // 同じ基準で異常値をはじけるようにしている(多層防御の考え方)。
  //
  // 範囲外の項目があれば ProfileOutOfRangeException を投げる。
  // 問題が無ければ何も起きず、そのまま処理を続けられる。
  // ------------------------------------------------------------
  void validate() {
    // 身長のチェック。範囲外なら例外を投げてここで処理を止める。
    if (heightCm < minHeightCm || heightCm > maxHeightCm) {
      // 例外オブジェクトを作って投げる(throw)。
      // fieldNameには、どの項目が原因かを人間が読める形で入れる。
      throw ProfileOutOfRangeException(
        fieldName: 'heightCm(身長)',
        receivedValue: heightCm,
        minValue: minHeightCm,
        maxValue: maxHeightCm,
      );
    }

    // 体重のチェック。範囲外なら例外を投げてここで処理を止める。
    if (weightKg < minWeightKg || weightKg > maxWeightKg) {
      throw ProfileOutOfRangeException(
        fieldName: 'weightKg(体重)',
        receivedValue: weightKg,
        minValue: minWeightKg,
        maxValue: maxWeightKg,
      );
    }

    // 年齢のチェック。範囲外なら例外を投げてここで処理を止める。
    if (age < minAge || age > maxAge) {
      throw ProfileOutOfRangeException(
        fieldName: 'age(年齢)',
        receivedValue: age,
        minValue: minAge,
        maxValue: maxAge,
      );
    }

    // ここまで例外が投げられずに到達したら、
    // 3項目とも範囲内だったということなので、何もせず終了する。
  }

  /// Firestore(users/{uid}/profile)に保存するためのMap形式に変換する。
  /// enum値は name(文字列)として保存する。
  Map<String, dynamic> toJson() {
    return {
      'heightCm': heightCm,
      'weightKg': weightKg,
      'age': age,
      'gender': gender.name,
      'activityLevel': activityLevel.name,
      'goal': goal.name,
    };
  }

  /// Firestoreから読み込んだMapからUserProfileを復元する。
  /// enum値の文字列が不正・欠損している場合は、安全側の既定値
  /// (性別:male、運動量:moderate、目標:maintain)にフォールバックする。
  ///
  /// 【注意】ここでは validate() を自動では呼ばない。
  /// 呼び出し側(UserProfileRepositoryなど)が、用途に応じて
  /// 明示的に validate() を呼ぶ設計にしている
  /// (読み込んだ直後に呼ぶことを強く推奨する)。
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: Gender.values.firstWhere(
        (g) => g.name == json['gender'],
        orElse: () => Gender.male,
      ),
      activityLevel: ActivityLevel.values.firstWhere(
        (a) => a.name == json['activityLevel'],
        orElse: () => ActivityLevel.moderate,
      ),
      goal: Goal.values.firstWhere(
        (g) => g.name == json['goal'],
        orElse: () => Goal.maintain,
      ),
    );
  }
}

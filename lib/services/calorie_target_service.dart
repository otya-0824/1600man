import '../models/nutrition_target.dart';
import '../models/user_profile.dart';

// ============================================================
// _AgeBand / _byAge
// ============================================================
// 年齢帯ごとに異なる推奨量を簡潔に表現するための小さなヘルパー。
// [maxAge]以下ならその値を採用する(先頭から順に判定)。
// 最後の区分は「75歳以上」など、上限なしの区分として扱う。
// ============================================================
// _AgeBand: 1つの年齢区分と、その区分での値をセットで持つクラス。
// 例：_AgeBand(29, 800) なら「29歳以下なら800」という意味。
class _AgeBand {
  // この区分の年齢の上限(この年齢まではこのvalueを使う)。
  final int maxAge;
  // この年齢区分での実際の値(推奨量など)。
  final double value;
  // コンストラクタ。_AgeBand(29, 800)のように、
  // 上限年齢と値を順番に渡して作る。
  const _AgeBand(this.maxAge, this.value);
}

// _byAge: 年齢(age)と、年齢帯のリスト(bands)を受け取り、
// 該当する区分の値を返す関数。
double _byAge(int age, List<_AgeBand> bands) {
  // リストの先頭から順番に、年齢が上限以下の区分を探す。
  // (リストは若い年齢の区分から順に並んでいる前提)
  for (final band in bands) {
    // もし年齢がこの区分の上限以下なら、この区分の値を採用して返す。
    if (age <= band.maxAge) {
      return band.value;
    }
  }
  // どの区分にも当てはまらなかった場合(=年齢がリストの最後の区分の
  // 上限より大きい場合)は、最後の区分(通常「75歳以上」など、
  // 上限なしの区分として使っている)の値を返す。
  return bands.last.value;
}


// ============================================================
// CalorieTargetService
// ============================================================
// 身長・体重・年齢・性別・活動量・目標(減量/維持/増量/筋トレ)から、
// 1日の目標エネルギー・PFC・その他の一般的な栄養素の目標量を
// 計算するサービス。
//
// 【計算の考え方】
//   1. 基礎代謝(BMR)を Mifflin-St Jeor 式で算出
//   2. 総消費カロリー(TDEE) = BMR × 活動係数
//   3. 目標摂取カロリー = TDEE + 目標による増減
//   4. PFCバランス(たんぱく質→脂質→炭水化物の順に配分)
//   5. その他の栄養素(ミネラル・ビタミン・食物繊維・食塩など)は、
//      厚生労働省「日本人の食事摂取基準(2025年版)」の
//      推奨量・目安量・目標量を、年齢・性別から算出する
//      (体重・活動量・目標によっては変化しない)。
//
// 【簡略化している点】
//   - 鉄の推奨量は、本来「月経の有無」で大きく変わる。
//     このアプリでは月経の有無を入力させていないため、
//     50歳未満の女性は「月経あり」、50歳以上の女性は
//     「月経なし」の値を暫定的に採用している(あくまで近似)。
//   - コレステロールには明確な推奨量が定められていないため、
//     脂質異常症の重症化予防の観点で広く使われる200mg/日を
//     参考値として使用している。
//
// これらはあくまで一般的な目安であり、医療的な指導に代わるもの
// ではない。持病がある場合や大きな増減量を行う場合は、
// 医師・管理栄養士に相談することが望ましい。
// ============================================================
class CalorieTargetService {
  static const double _minimumKcalMargin = 200;

  // ------------------------------------------------------------
  // 食物繊維(g/日、以上)
  // ------------------------------------------------------------
  static const List<_AgeBand> _fiberMale = [
    _AgeBand(29, 20), _AgeBand(49, 22), _AgeBand(64, 22),
    _AgeBand(74, 21), _AgeBand(200, 20),
  ];
  static const List<_AgeBand> _fiberFemale = [
    _AgeBand(200, 18),
  ];

  // ------------------------------------------------------------
  // マグネシウム(mg/日)
  // ------------------------------------------------------------
  static const List<_AgeBand> _magnesiumMale = [
    _AgeBand(29, 340), _AgeBand(49, 380), _AgeBand(64, 370),
    _AgeBand(74, 350), _AgeBand(200, 330),
  ];
  static const List<_AgeBand> _magnesiumFemale = [
    _AgeBand(29, 280), _AgeBand(49, 290), _AgeBand(64, 290),
    _AgeBand(74, 280), _AgeBand(200, 270),
  ];

  // ------------------------------------------------------------
  // 鉄(mg/日) ※上記の月経あり/なしの簡略化を参照
  // ------------------------------------------------------------
  static const List<_AgeBand> _ironMale = [
    _AgeBand(29, 7.0), _AgeBand(49, 7.5), _AgeBand(64, 7.0),
    _AgeBand(74, 7.0), _AgeBand(200, 6.5),
  ];
  static const List<_AgeBand> _ironFemaleMenstruating = [
    _AgeBand(29, 10.0), _AgeBand(200, 10.5),
  ];
  static const List<_AgeBand> _ironFemaleNonMenstruating = [
    _AgeBand(64, 6.0), _AgeBand(74, 6.0), _AgeBand(200, 5.5),
  ];

  // ------------------------------------------------------------
  // 亜鉛(mg/日)
  // ------------------------------------------------------------
  static const List<_AgeBand> _zincMale = [
    _AgeBand(29, 9.0), _AgeBand(49, 9.5), _AgeBand(64, 9.5),
    _AgeBand(74, 9.0), _AgeBand(200, 9.0),
  ];
  static const List<_AgeBand> _zincFemale = [
    _AgeBand(29, 7.5), _AgeBand(49, 8.0), _AgeBand(64, 8.0),
    _AgeBand(74, 7.5), _AgeBand(200, 7.0),
  ];

  // ------------------------------------------------------------
  // 銅(mg/日)
  // ------------------------------------------------------------
  static const List<_AgeBand> _copperMale = [
    _AgeBand(29, 0.8), _AgeBand(49, 0.9), _AgeBand(64, 0.9),
    _AgeBand(74, 0.8), _AgeBand(200, 0.8),
  ];
  static const List<_AgeBand> _copperFemale = [
    _AgeBand(200, 0.7),
  ];

  // ------------------------------------------------------------
  // カルシウム(mg/日)
  // ------------------------------------------------------------
  static const List<_AgeBand> _calciumMale = [
    _AgeBand(29, 800), _AgeBand(200, 750),
  ];
  static const List<_AgeBand> _calciumFemale = [
    _AgeBand(74, 650), _AgeBand(200, 600),
  ];

  // ------------------------------------------------------------
  // ビタミンA(μgRAE/日)
  // ------------------------------------------------------------
  static const List<_AgeBand> _vitaminAMale = [
    _AgeBand(29, 850), _AgeBand(49, 900), _AgeBand(64, 900),
    _AgeBand(74, 850), _AgeBand(200, 800),
  ];
  static const List<_AgeBand> _vitaminAFemale = [
    _AgeBand(29, 650), _AgeBand(49, 700), _AgeBand(64, 700),
    _AgeBand(74, 700), _AgeBand(200, 650),
  ];

  // ------------------------------------------------------------
  // ビタミンE(mg/日)
  // ------------------------------------------------------------
  static const List<_AgeBand> _vitaminEMale = [
    _AgeBand(29, 6.5), _AgeBand(49, 6.5), _AgeBand(64, 6.5),
    _AgeBand(74, 7.5), _AgeBand(200, 7.0),
  ];
  static const List<_AgeBand> _vitaminEFemale = [
    _AgeBand(29, 5.0), _AgeBand(49, 6.0), _AgeBand(64, 6.0),
    _AgeBand(74, 7.0), _AgeBand(200, 6.0),
  ];

  // ------------------------------------------------------------
  // ビタミンB1(mg/日)
  // ------------------------------------------------------------
  static const List<_AgeBand> _vitaminB1Male = [
    _AgeBand(29, 1.1), _AgeBand(49, 1.2), _AgeBand(64, 1.1),
    _AgeBand(74, 1.0), _AgeBand(200, 1.0),
  ];
  static const List<_AgeBand> _vitaminB1Female = [
    _AgeBand(29, 0.8), _AgeBand(49, 0.9), _AgeBand(64, 0.8),
    _AgeBand(74, 0.8), _AgeBand(200, 0.7),
  ];

  // ------------------------------------------------------------
  // ビタミンB2(mg/日)
  // ------------------------------------------------------------
  static const List<_AgeBand> _vitaminB2Male = [
    _AgeBand(29, 1.6), _AgeBand(49, 1.7), _AgeBand(64, 1.6),
    _AgeBand(74, 1.4), _AgeBand(200, 1.4),
  ];
  static const List<_AgeBand> _vitaminB2Female = [
    _AgeBand(29, 1.2), _AgeBand(49, 1.2), _AgeBand(64, 1.2),
    _AgeBand(74, 1.1), _AgeBand(200, 1.1),
  ];

  // ------------------------------------------------------------
  // ナイアシン(mgNE/日)
  // ------------------------------------------------------------
  static const List<_AgeBand> _niacinMale = [
    _AgeBand(29, 15), _AgeBand(49, 16), _AgeBand(64, 15),
    _AgeBand(74, 14), _AgeBand(200, 13),
  ];
  static const List<_AgeBand> _niacinFemale = [
    _AgeBand(29, 11), _AgeBand(49, 12), _AgeBand(64, 11),
    _AgeBand(74, 11), _AgeBand(200, 10),
  ];

  // ------------------------------------------------------------
  // ビタミンB6(mg/日)
  // ------------------------------------------------------------
  static const List<_AgeBand> _vitaminB6Male = [
    _AgeBand(29, 1.5), _AgeBand(49, 1.5), _AgeBand(64, 1.5),
    _AgeBand(74, 1.4), _AgeBand(200, 1.4),
  ];
  static const List<_AgeBand> _vitaminB6Female = [
    _AgeBand(200, 1.2),
  ];

  // ------------------------------------------------------------
  // パントテン酸(mg/日)
  // ------------------------------------------------------------
  static const double _pantothenicAcidMale = 6;
  static const double _pantothenicAcidFemale = 5;

  // ------------------------------------------------------------
  // 年齢・性別に依存しない固定値
  // ------------------------------------------------------------
  static const double _saltMale = 7.5; // g/日、未満が目標
  static const double _saltFemale = 6.5;

  static const double _potassiumMale = 3000; // mg/日、以上が目標
  static const double _potassiumFemale = 2600;

  static const double _phosphorusMale = 1000; // mg/日
  static const double _phosphorusFemale = 800;

  static const double _vitaminD = 9.0; // μg/日(男女共通)
  static const double _vitaminK = 150; // μg/日(男女共通)
  static const double _vitaminB12 = 4.0; // μg/日(男女共通)
  static const double _folate = 240; // μg/日(男女共通)
  static const double _vitaminC = 100; // mg/日(男女共通)
  static const double _biotin = 50; // μg/日(男女共通)

  /// コレステロールの参考値(mg/日)。
  /// 明確な推奨量は定められていないため、脂質異常症の重症化予防の
  /// 観点で広く使われる目安値を参考値として使用している。
  static const double _cholesterolReference = 200;

  NutritionTarget calculate(
    UserProfile profile, {
    double? kcalAdjustmentOverride,
    double? proteinPerKgOverride,
    double fatRatio = 0.25,
    double? calciumMgOverride,
    double? zincMgOverride,
  }) {
    // 1行目：基礎代謝(BMR)を計算する(下の_calculateBmr()を参照)。
    final bmr = _calculateBmr(profile);
    // 2行目：基礎代謝に活動係数(1.2〜1.9)を掛けて、
    //        1日に消費する総カロリー(TDEE)を求める。
    final tdee = bmr * profile.activityLevel.factor;

    // 目標(減量/維持/増量/筋トレ)ごとの1日の増減カロリーを取得する。
    // kcalAdjustmentOverrideが指定されていればそちらを優先し、
    // 指定が無ければGoal.defaultKcalAdjustment(既定値)を使う。
    final adjustment =
        kcalAdjustmentOverride ?? profile.goal.defaultKcalAdjustment;

    // 極端な減量設定でも、基礎代謝を大きく下回らないようにするための
    // 下限値を計算しておく(安全マージン200kcal分だけ余裕を持たせる)。
    final minimumKcal = bmr - _minimumKcalMargin;

    // 目標カロリー = 総消費カロリー(tdee) + 増減量(adjustment)。
    // varにしているのは、次の行で下限に達していないか
    // チェックしたあとに値を書き換える可能性があるため。
    var targetKcal = tdee + adjustment;
    // もし計算結果が下限(minimumKcal)を下回っていたら、
    // 安全のため下限の値まで引き上げる。
    if (targetKcal < minimumKcal) {
      targetKcal = minimumKcal;
    }

    // 体重1kgあたりのたんぱく質量(g)を取得する。
    // proteinPerKgOverrideが指定されていればそちらを優先し、
    // 指定が無ければGoal.defaultProteinPerKg(既定値)を使う。
    final proteinPerKg =
        proteinPerKgOverride ?? profile.goal.defaultProteinPerKg;

    // たんぱく質の目標量(g) = 体重(kg) × 体重1kgあたりのg数。
    final targetProtein = profile.weightKg * proteinPerKg;
    // 脂質の目標量(g) = (目標カロリー × 脂質の割合) ÷ 9
    // (脂質は1gあたり9kcalなので、カロリーをgに変換している)。
    final targetFat = (targetKcal * fatRatio) / 9;

    // たんぱく質のカロリー(kcal) = たんぱく質(g) × 4
    // (たんぱく質は1gあたり4kcal)。
    final proteinKcal = targetProtein * 4;
    // 脂質のカロリー(kcal) = 脂質(g) × 9。
    final fatKcal = targetFat * 9;
    // 目標カロリーから、たんぱく質と脂質の分を引いた残りを、
    // 炭水化物に割り当てるカロリーとする。
    final remainingKcalForCarb = targetKcal - proteinKcal - fatKcal;

    // 残りカロリーが0より大きければ、4で割って炭水化物のg数に変換する
    // (炭水化物は1gあたり4kcal)。
    // 0以下(たんぱく質・脂質だけで目標カロリーを超えてしまった場合)は、
    // マイナスにならないよう0.0にしておく。
    final targetCarbohydrate =
        remainingKcalForCarb > 0 ? remainingKcalForCarb / 4 : 0.0;

    // 以下の各栄養素の目標値を出す際、男性か女性かで参照する表が
    // 変わるため、判定結果を変数にしておいて何度も使い回す。
    final isMale = profile.gender == Gender.male;
    // 年齢帯ごとの表を参照する際に使う、年齢の変数。
    final age = profile.age;

    // ここまでに計算した値と、これから年齢・性別ごとの表から
    // 引く値をまとめて、NutritionTarget(結果オブジェクト)を作って
    // 呼び出し元に返す。
    return NutritionTarget(
      bmr: bmr,
      tdee: tdee,
      targetKcal: targetKcal,
      targetProtein: targetProtein,
      targetFat: targetFat,
      targetCarbohydrate: targetCarbohydrate,
      targetFiber: isMale

          ? _byAge(age, _fiberMale)
          : _byAge(age, _fiberFemale),
      targetSalt: isMale ? _saltMale : _saltFemale,
      targetCholesterol: _cholesterolReference,
      targetPotassium: isMale ? _potassiumMale : _potassiumFemale,
      targetCalcium: calciumMgOverride ??
          (isMale ? _byAge(age, _calciumMale) : _byAge(age, _calciumFemale)),
      targetMagnesium: isMale
          ? _byAge(age, _magnesiumMale)
          : _byAge(age, _magnesiumFemale),
      targetPhosphorus: isMale ? _phosphorusMale : _phosphorusFemale,
      targetIron: _ironRda(profile),
      targetZinc: zincMgOverride ??
          (isMale ? _byAge(age, _zincMale) : _byAge(age, _zincFemale)),
      targetCopper:
          isMale ? _byAge(age, _copperMale) : _byAge(age, _copperFemale),
      targetVitaminA: isMale
          ? _byAge(age, _vitaminAMale)
          : _byAge(age, _vitaminAFemale),
      targetVitaminD: _vitaminD,
      targetVitaminE: isMale
          ? _byAge(age, _vitaminEMale)
          : _byAge(age, _vitaminEFemale),
      targetVitaminK: _vitaminK,
      targetVitaminB1: isMale
          ? _byAge(age, _vitaminB1Male)
          : _byAge(age, _vitaminB1Female),
      targetVitaminB2: isMale
          ? _byAge(age, _vitaminB2Male)
          : _byAge(age, _vitaminB2Female),
      targetNiacin:
          isMale ? _byAge(age, _niacinMale) : _byAge(age, _niacinFemale),
      targetVitaminB6: isMale
          ? _byAge(age, _vitaminB6Male)
          : _byAge(age, _vitaminB6Female),
      targetVitaminB12: _vitaminB12,
      targetFolate: _folate,
      targetPantothenicAcid:
          isMale ? _pantothenicAcidMale : _pantothenicAcidFemale,
      targetVitaminC: _vitaminC,
      targetBiotin: _biotin,
    );
  }

  // ------------------------------------------------------------
  // 基礎代謝(BMR)を Mifflin-St Jeor 式で計算する
  // ------------------------------------------------------------
  double _calculateBmr(UserProfile profile) {
    // 男女共通の計算部分。
    // 体重(kg)×10 + 身長(cm)×6.25 − 年齢×5 を先に計算しておく。
    final base = 10 * profile.weightKg +
        6.25 * profile.heightCm -
        5 * profile.age;

    // 性別によって最後に足す/引く数字が変わる。
    // 男性なら base に +5、女性なら base から -161 する。
    // (?: は「条件 ? 真の場合の値 : 偽の場合の値」という意味の
    //  三項演算子。if文を1行で書く書き方)
    return profile.gender == Gender.male ? base + 5 : base - 161;
  }

  // ------------------------------------------------------------
  // 鉄の推奨量。女性は50歳を境に「月経あり/なし」を近似する
  // (詳細はクラスコメント参照)。
  // ------------------------------------------------------------
  double _ironRda(UserProfile profile) {
    // まず男性かどうかを判定する。
    if (profile.gender == Gender.male) {
      // 男性なら、男性用の年齢帯テーブル(_ironMale)から値を取る。
      return _byAge(profile.age, _ironMale);
    }

    // ここから下は女性の場合の処理。
    // 50歳未満なら「月経あり」を想定したテーブルを使う。
    if (profile.age < 50) {
      return _byAge(profile.age, _ironFemaleMenstruating);
    }

    // 50歳以上なら「月経なし」を想定したテーブルを使う。
    return _byAge(profile.age, _ironFemaleNonMenstruating);
  }
}

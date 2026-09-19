import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'models/meal.dart';
import 'models/nutrition_target.dart';
import 'models/nutrient_comparison.dart';
import 'models/user_profile.dart';
import 'services/profile_service.dart';
import 'services/nutrition_facade.dart';
import 'services/nutrition_feedback_service.dart';
import 'services/nutrient_group_service.dart';
import 'meal_storage_service.dart';
import 'meal.dart';
import 'gurahu.dart';
import 'calendar.dart';
import 'mypage.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // 計算エンジン(panpan)との橋渡し役。プロフィールから目標値を計算する。
  final NutritionFacade _facade = NutritionFacade();

  // その日の合計はローカル(SharedPreferences)から集計する。
  final DateTime _today = DateTime.now();
  late final Future<DailySummary> _summaryFuture =
      MealStorageService.getDailySummary(_today);

  // 目標(NutritionTarget)は表示のたびに再計算せず、一度だけ計算して使い回す。
  // 保存済みプロフィールから算出。未登録や取得が遅い/失敗した場合は
  // 既定プロフィールの目標にフォールバックする(3秒タイムアウト付き)。
  late final Future<NutritionTarget> _targetFuture = _facade.loadTargetOrDefault();

  // 栄養バランス(五角形)の5軸の達成率(%)と、各軸の「成功まであとどれだけか」。
  // せなさんの NutrientGroupService でビタミン/ミネラルをグループ平均する。
  late final Future<_RadarData> _radarFuture = _computeRadarData();

  Future<_RadarData> _computeRadarData() async {
    final summary = await _summaryFuture;
    final micros = await MealStorageService.getDailyMicros(_today);
    // プロフィールから「現在の目標」と「維持を基準にした目標」の2つを計算する。
    // 赤い五角形は、維持(正五角形)を基準に、目標(減量/増量等)で目標量が
    // どう変わるかを"形"で表すために baseline を使う。
    final profile = await ProfileService().loadProfile() ?? _homeDefaultProfile;
    final target = _facade.targetFor(profile); // 現在の目標
    final baseline = _facade.targetFor(_asMaintain(profile)); // 維持基準

    final comparisons = NutritionFeedbackService().compare(
      target: target,
      actualKcal: summary.totalCalorie,
      actualProtein: summary.totalProtein,
      actualFat: summary.totalFat,
      actualCarbohydrate: summary.totalCarbo,
      actualFiber: micros['fiber'] ?? 0,
      actualSalt: micros['salt'] ?? 0,
      actualCholesterol: micros['cholesterol'] ?? 0,
      actualPotassium: micros['potassium'] ?? 0,
      actualCalcium: micros['calcium'] ?? 0,
      actualMagnesium: micros['magnesium'] ?? 0,
      actualPhosphorus: micros['phosphorus'] ?? 0,
      actualIron: micros['iron'] ?? 0,
      actualZinc: micros['zinc'] ?? 0,
      actualCopper: micros['copper'] ?? 0,
      actualVitaminA: micros['vitaminA'] ?? 0,
      actualVitaminD: micros['vitaminD'] ?? 0,
      actualVitaminE: micros['vitaminE'] ?? 0,
      actualVitaminK: micros['vitaminK'] ?? 0,
      actualVitaminB1: micros['vitaminB1'] ?? 0,
      actualVitaminB2: micros['vitaminB2'] ?? 0,
      actualNiacin: micros['niacin'] ?? 0,
      actualVitaminB6: micros['vitaminB6'] ?? 0,
      actualVitaminB12: micros['vitaminB12'] ?? 0,
      actualFolate: micros['folate'] ?? 0,
      actualPantothenicAcid: micros['pantothenicAcid'] ?? 0,
      actualVitaminC: micros['vitaminC'] ?? 0,
      actualBiotin: micros['biotin'] ?? 0,
    );

    double ratioOf(String label) {
      for (final c in comparisons) {
        if (c.label == label) return c.ratio;
      }
      return 0;
    }

    final group = NutrientGroupService();
    final vitamin = group.vitaminScore(comparisons)?.averageRatio ?? 0;
    final mineral = group.mineralScore(comparisons)?.averageRatio ?? 0;

    // タンパク質 / 脂質 / 炭水化物 / ビタミン / ミネラル の達成率(%)
    final values = [
      ratioOf('たんぱく質') * 100,
      ratioOf('脂質') * 100,
      ratioOf('炭水化物') * 100,
      vitamin * 100,
      mineral * 100,
    ];

    // 各軸について「成功(適正範囲)まであとどれだけ取ればよいか」を作る。
    // P/F/C は具体的なグラム、ビタミン/ミネラルはグループ平均の達成率(%)で示す。
    final goals = [
      _macroGoal(comparisons, 'たんぱく質'),
      _macroGoal(comparisons, '脂質'),
      _macroGoal(comparisons, '炭水化物'),
      _groupGoal('ビタミン', vitamin * 100),
      _groupGoal('ミネラル', mineral * 100),
    ];

    // レーダー用の値は「維持基準(baseline)に対する割合(%)」で揃える。
    // ・赤(目標ライン) = 現在の目標 ÷ 維持基準 → 目標(減量/増量)で形が変わる
    //   (P/F/C は目標で変化。ビタミン/ミネラルは年齢・性別依存で目標不変=100)
    // ・緑(実績)       = 実測 ÷ 維持基準 → 緑が赤に届く=目標達成、の関係は保たれる
    double rel(double a, double b) => b <= 0 ? 0 : a / b * 100;
    final radarRed = [
      rel(target.targetProtein, baseline.targetProtein),
      rel(target.targetFat, baseline.targetFat),
      rel(target.targetCarbohydrate, baseline.targetCarbohydrate),
      100.0, // ビタミン(目標は目標設定で変わらない)
      100.0, // ミネラル(同上)
    ];
    final radarGreen = [
      rel(summary.totalProtein, baseline.targetProtein),
      rel(summary.totalFat, baseline.targetFat),
      rel(summary.totalCarbo, baseline.targetCarbohydrate),
      vitamin * 100, // ビタミンは目標不変なので達成率と一致
      mineral * 100,
    ];

    return _RadarData(
      values: values,
      goals: goals,
      radarRed: radarRed,
      radarGreen: radarGreen,
    );
  }

  // プロフィール未登録時の既定プロフィール(維持基準の算出にも使う)。
  static const UserProfile _homeDefaultProfile = UserProfile(
    heightCm: 170,
    weightKg: 60,
    age: 30,
    gender: Gender.male,
    activityLevel: ActivityLevel.moderate,
    goal: Goal.maintain,
  );

  // 同じ体格のまま目標だけ「維持」にしたプロフィールを作る(赤の基準用)。
  UserProfile _asMaintain(UserProfile p) => UserProfile(
        heightCm: p.heightCm,
        weightKg: p.weightKg,
        age: p.age,
        gender: p.gender,
        activityLevel: p.activityLevel,
        goal: Goal.maintain,
        birthDate: p.birthDate,
        goalWeightKg: p.goalWeightKg,
      );

  // P/F/C の「成功まであと何g」。適正範囲は目標±15%(NutritionFeedbackServiceと同じ)。
  _AxisGoal _macroGoal(List<NutrientComparison> comparisons, String label) {
    NutrientComparison? c;
    for (final e in comparisons) {
      if (e.label == label) {
        c = e;
        break;
      }
    }
    if (c == null || c.target <= 0) {
      return _AxisGoal(label: label, status: _GoalStatus.low, detail: '—');
    }
    const tolerance = 0.15;
    final lower = c.target * (1 - tolerance);
    final upper = c.target * (1 + tolerance);
    final unit = c.unit;
    if (c.actual < lower) {
      final need = (lower - c.actual).round();
      return _AxisGoal(
          label: label, status: _GoalStatus.low, detail: 'あと$need$unit');
    } else if (c.actual > upper) {
      final over = (c.actual - upper).round();
      return _AxisGoal(
          label: label, status: _GoalStatus.high, detail: '$over$unit 超過');
    }
    return _AxisGoal(label: label, status: _GoalStatus.good, detail: '達成');
  }

  // ビタミン/ミネラルの「成功まであと何%」。適正範囲は目標±20%。
  _AxisGoal _groupGoal(String label, double percent) {
    const lower = 80.0; // 目標の80%(=1-0.20)以上で成功
    const upper = 120.0;
    if (percent < lower) {
      final need = (lower - percent).round();
      return _AxisGoal(
          label: label, status: _GoalStatus.low, detail: 'あと$need%');
    } else if (percent > upper) {
      final over = (percent - upper).round();
      return _AxisGoal(
          label: label, status: _GoalStatus.high, detail: '$over% 超過');
    }
    return _AxisGoal(label: label, status: _GoalStatus.good, detail: '達成');
  }

  @override
  Widget build(BuildContext context) {
    final today = _today;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(
          Icons.menu,
          color: Colors.black,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.notifications_none,
              color: Colors.black,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "今日の栄養サマリー",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "${today.year}/${today.month}/${today.day}",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            // プロフィールから計算した目標(panpanの計算エンジン)を受け取る。
            // 目標が計算できたら分母に「/ 目標kcal」を表示する。
            FutureBuilder<NutritionTarget>(
              future: _targetFuture,
              builder: (context, targetSnap) {
                final target = targetSnap.data;
                final kcalDenominator = target == null
                    ? "/ --- kcal"
                    : "/ ${target.targetKcal.round()} kcal";

                // その日の合計をローカル集計から受け取って表示する
                return FutureBuilder<DailySummary>(
              future: _summaryFuture,
              builder: (context, snapshot) {
                final summary = snapshot.data ?? const DailySummary();
                final hasData = snapshot.hasData;

                // 数値を文字列に（データ取得前は "---" のまま）
                String kcal =
                    hasData ? summary.totalCalorie.round().toString() : "---";
                String p = hasData
                    ? "${summary.totalProtein.round()} g"
                    : "--- g";
                String f =
                    hasData ? "${summary.totalFat.round()} g" : "--- g";
                String c =
                    hasData ? "${summary.totalCarbo.round()} g" : "--- g";

                return Column(
                  children: [
                    // 摂取が目標に近づくにつれて緑がチャージされるリング。
                    _CalorieRing(
                      actual: summary.totalCalorie,
                      target: target?.targetKcal ?? 0,
                      hasData: hasData,
                      kcalText: kcal,
                      denominatorText: kcalDenominator,
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        _nutritionItem(
                          title: "P",
                          value: p,
                          color: Colors.green,
                        ),
                        _nutritionItem(
                          title: "F",
                          value: f,
                          color: Colors.orange,
                        ),
                        _nutritionItem(
                          title: "C",
                          value: c,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                );
              },
                );
              },
            ),

            const SizedBox(height: 35),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "栄養バランス",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            FutureBuilder<_RadarData>(
              future: _radarFuture,
              builder: (context, snap) {
                final data = snap.data;
                final values = data?.values ?? const [0, 0, 0, 0, 0];
                return Column(
                  children: [
                    _NutritionRadarChart(
                      values: data?.radarGreen ?? const [0, 0, 0, 0, 0],
                      redValues: data?.radarRed ?? const [100, 100, 100, 100, 100],
                    ),
                    if (data != null && !values.every((v) => v <= 0)) ...[
                      const SizedBox(height: 8),
                      _NutrientBars(values: values, goals: data.goals),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return; // 現在ホームなので何もしない
          switch (index) {
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MealPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const GraphScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MypageScreen()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "ホーム",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "記録",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "グラフ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "カレンダー",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "マイページ",
          ),
        ],
      ),
    );
  }

  static Widget _nutritionItem({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// 栄養バランス レーダーチャート（五角形 / fl_chart）
// 軸: タンパク質 / 脂質 / 炭水化物 / ビタミン / ミネラル（上から時計回り）
// 実データ(DailySummary)を目標・参照値に対する達成率(%)で表示する。
// =====================================================================
class _NutritionRadarChart extends StatelessWidget {
  /// 緑(実績)の5軸の値(%)。維持基準に対する割合。
  final List<double> values;

  /// 赤(目標ライン)の5軸の値(%)。維持基準に対する現在目標の割合。
  /// 目標(減量/増量等)によって形が変わる。
  final List<double> redValues;

  const _NutritionRadarChart({required this.values, required this.redValues});

  @override
  Widget build(BuildContext context) {
    const titles = ['タンパク質', '脂質', '炭水化物', 'ビタミン', 'ミネラル'];

    const green = Color(0xFF66BB6A);

    // 目標(赤)も実績(緑)も無い場合のみプレースホルダ。
    // (通常は赤=目標ラインが常にあるので、記録が無くても目標の形は表示する)
    if (values.every((v) => v <= 0) && redValues.every((v) => v <= 0)) {
      return Container(
        height: 320,
        width: double.infinity,
        alignment: Alignment.center,
        color: Colors.white,
        child: const Text(
          '記録がありません',
          style: TextStyle(color: Colors.black38, fontSize: 14),
        ),
      );
    }

    // 外枠(=グラフの最大値)を、赤(目標)・緑(実績)の最大より広げる。
    // こうすることで目標ラインが外枠と重ならず、五角形の内側に描かれる。
    final maxActual = values.reduce((a, b) => a > b ? a : b);
    final maxRed = redValues.reduce((a, b) => a > b ? a : b);
    final maxVal = maxActual > maxRed ? maxActual : maxRed;
    final ceiling = (maxVal > 100 ? maxVal : 100) * 1.25;

    return Container(
      height: 320,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 28, 8, 24),
      color: Colors.white,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          dataSets: [
            // 外枠を広げるための透明データセット(全軸=ceiling)。
            // これで五角形の外周が100%より外側になり、赤い目標ラインが内側に入る。
            RadarDataSet(
              dataEntries: [
                for (var i = 0; i < values.length; i++)
                  RadarEntry(value: ceiling)
              ],
              fillColor: Colors.transparent,
              borderColor: Colors.transparent,
              borderWidth: 0,
              entryRadius: 0,
            ),
            // 目標ライン(赤)。目標(減量/増量等)に応じて形が変わる五角形。
            // 塗りは無し。外枠の内側に描かれ、実績がどこまで届いているか比較できる。
            RadarDataSet(
              dataEntries: [for (final v in redValues) RadarEntry(value: v)],
              fillColor: Colors.transparent,
              borderColor: Colors.red,
              borderWidth: 2,
              entryRadius: 2,
            ),
            // 実績(達成率%)。緑のポリゴンで表示する。
            RadarDataSet(
              dataEntries: [for (final v in values) RadarEntry(value: v)],
              fillColor: green.withValues(alpha: 0.25),
              borderColor: green,
              borderWidth: 2,
              entryRadius: 3,
            ),
          ],
          getTitle: (index, angle) => RadarChartTitle(text: titles[index]),
          titleTextStyle: const TextStyle(fontSize: 12, color: Colors.black87),
          titlePositionPercentageOffset: 0.12,
          radarBackgroundColor: Colors.transparent,
          radarBorderData: const BorderSide(color: Colors.black87, width: 1.2),
          gridBorderData: const BorderSide(color: Colors.black54, width: 1),
          tickBorderData: const BorderSide(color: Colors.black54, width: 1),
          tickCount: 5,
          ticksTextStyle:
              const TextStyle(fontSize: 9, color: Colors.black45),
        ),
      ),
    );
  }
}

// =====================================================================
// 栄養バランスの計算結果(レーダー5軸の達成率 + 各軸の成功までの残量)
// =====================================================================
class _RadarData {
  /// 5軸の達成率(%)。順に タンパク質 / 脂質 / 炭水化物 / ビタミン / ミネラル。
  /// (下部のプログレスバー用。現在の目標に対する達成率)
  final List<double> values;

  /// 5軸それぞれの「成功まであとどれだけ取ればよいか」。
  final List<_AxisGoal> goals;

  /// レーダーの赤い目標ライン(維持基準に対する現在目標の割合%)。
  final List<double> radarRed;

  /// レーダーの緑の実績(維持基準に対する実測の割合%)。
  final List<double> radarGreen;

  const _RadarData({
    required this.values,
    required this.goals,
    required this.radarRed,
    required this.radarGreen,
  });
}

/// 成功判定の状態。不足 / 適正(成功) / 過剰。
enum _GoalStatus { low, good, high }

/// 1軸ぶんの成功情報。detail は "あと12g" / "達成" / "8g 超過" など。
class _AxisGoal {
  final String label;
  final _GoalStatus status;
  final String detail;

  const _AxisGoal({
    required this.label,
    required this.status,
    required this.detail,
  });
}

// =====================================================================
// 栄養素プログレスバー一覧（Lifesum / Yazio 系の栄養アプリUIを参考）
// レーダーの5軸に対応。達成率(%)を丸みのあるバーで満たし、右端に%を表示。
// 色で 不足(オレンジ) / 適正(緑) / 過剰(赤) を示す。
// =====================================================================
class _NutrientBars extends StatelessWidget {
  final List<double> values; // 達成率(%)
  final List<_AxisGoal> goals;

  const _NutrientBars({required this.values, required this.goals});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < goals.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: _bar(goals[i], values[i]),
            ),
        ],
      ),
    );
  }

  Widget _bar(_AxisGoal g, double percent) {
    final color = _color(g.status);
    final fill = (percent / 100).clamp(0.0, 1.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            g.label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(height: 10, color: const Color(0xFFEDEFF1)),
                // 満たされていくバー本体。グラデーションで質感を出す。
                FractionallySizedBox(
                  widthFactor: fill,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.7), color],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 42,
          child: Text(
            '${percent.round()}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        // 適正(成功)に届いた軸はチェックを添える。
        SizedBox(
          width: 20,
          child: g.status == _GoalStatus.good
              ? Icon(Icons.check_circle, size: 16, color: color)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Color _color(_GoalStatus status) {
    switch (status) {
      case _GoalStatus.low:
        return const Color(0xFFFFA726); // 不足=オレンジ(あと少し)
      case _GoalStatus.good:
        return const Color(0xFF66BB6A); // 適正=緑
      case _GoalStatus.high:
        return const Color(0xFFEF5350); // 過剰=赤
    }
  }
}

// =====================================================================
// カロリーのチャージ型リング（摂取/目標 の達成度で緑が満ちていく）
// 目標到達で金色＋チェックの達成表現に切り替わる。
// =====================================================================
class _CalorieRing extends StatelessWidget {
  final double actual;
  final double target;
  final bool hasData;
  final String kcalText;
  final String denominatorText;

  const _CalorieRing({
    required this.actual,
    required this.target,
    required this.hasData,
    required this.kcalText,
    required this.denominatorText,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (actual / target) : 0.0;
    final reached = progress >= 1.0;
    final percent = (progress * 100);

    const green = Color(0xFF66BB6A);
    const gold = Color(0xFFFFC107);
    final ringColor = reached ? gold : green;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // リング本体（背景の薄いリング＋進捗アーク）
          CustomPaint(
            size: const Size(200, 200),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              color: ringColor,
              trackColor: const Color(0xFFEDEFF1),
              strokeWidth: 16,
            ),
          ),
          // 中央のテキスト
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                reached ? '達成 🎉' : 'カロリー',
                style: TextStyle(
                  color: reached ? gold : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                kcalText,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                denominatorText,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 4),
              // 達成度(%)。データが無いときは非表示。
              if (hasData && target > 0)
                Text(
                  '${percent.round()}%',
                  style: TextStyle(
                    color: ringColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// 進捗リングを描画するペインター。上(12時)から時計回りに満ちていく。
class _RingPainter extends CustomPainter {
  final double progress; // 0.0〜1.0
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 背景トラック（薄いリング）
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // 進捗アーク（グラデーションで質感を出す）
    final sweep = 2 * 3.141592653589793 * progress;
    const start = -3.141592653589793 / 2; // 12時方向から開始
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + 2 * 3.141592653589793,
        colors: [color.withValues(alpha: 0.55), color],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
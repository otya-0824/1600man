import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'models/meal.dart';
import 'models/nutrition_target.dart';
import 'services/nutrition_facade.dart';
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
  late final Future<NutritionTarget?> _targetFuture = _facade.loadTarget();

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
            FutureBuilder<NutritionTarget?>(
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
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green,
                          width: 10,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "カロリー",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            kcal,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // 目標カロリー(分母)。プロフィール未登録なら "---"。
                          Text(
                            kcalDenominator,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
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

            FutureBuilder<NutritionTarget?>(
              future: _targetFuture,
              builder: (context, targetSnap) {
                return FutureBuilder<DailySummary>(
                  future: _summaryFuture,
                  builder: (context, sumSnap) {
                    final summary = sumSnap.data ?? const DailySummary();
                    return _NutritionRadarChart(
                      summary: summary,
                      target: targetSnap.data,
                    );
                  },
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
  final DailySummary summary;
  final NutritionTarget? target;

  const _NutritionRadarChart({required this.summary, required this.target});

  @override
  Widget build(BuildContext context) {
    // ビタミン・ミネラルは専用の目標が無いため参照値で正規化（暫定・調整可）
    const refVitamin = 100.0;
    const refMineral = 100.0;

    double pct(double actual, double ref) => ref <= 0 ? 0 : actual / ref * 100;

    final values = <double>[
      pct(summary.totalProtein, target?.targetProtein ?? 60),
      pct(summary.totalFat, target?.targetFat ?? 60),
      pct(summary.totalCarbo, target?.targetCarbohydrate ?? 250),
      pct(summary.totalVitamin, refVitamin),
      pct(summary.totalMineral, refMineral),
    ];
    const titles = ['タンパク質', '脂質', '炭水化物', 'ビタミン', 'ミネラル'];

    const green = Color(0xFF66BB6A);

    return Container(
      height: 320,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 28, 8, 24),
      color: Colors.white,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          dataSets: [
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
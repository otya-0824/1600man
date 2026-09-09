import 'package:flutter/material.dart';

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

            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "レーダーチャート\n(後で実装)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ),
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
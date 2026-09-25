import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'meal.dart';
import 'gurahu.dart';
import 'calendar.dart';
import 'mypage.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode; // ← ダークモードの状態を受け取る変数

  const HomePage({
    super.key,
    this.isDarkMode = false, // デフォルトはライトモード
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ==========================================
  // 【バックエンド連携用変数定義】
  // ==========================================

  // 1. 基本情報
  String userId = "user_12345";
  DateTime currentDate = DateTime.now();

  // 2. 目標数値 (Goal Data)
  int targetCalorie = 2000;
  double targetProtein = 60.0;
  double targetFat = 50.0;
  double targetCarbo = 250.0;
  double targetVitamin = 100.0; // ビタミン目標(%)
  double targetMineral = 100.0; // ミネラル目標(%)

  // 3. 本日の合計摂取数値 (Consumed Data)
  int consumedCalorie = 1450;
  double consumedProtein = 42.0; // 60g中42g (70%)
  double consumedFat = 30.0;     // 50g中30g (60%)
  double consumedCarbo = 200.0;  // 250g中200g (80%)
  double consumedVitamin = 50.0; // 50%
  double consumedMineral = 90.0; // 90%

  // 4. 食事リストデータ (Meal List Data)
  List<Map<String, dynamic>> todayMeals = [
    {
      "mealId": "m_01",
      "category": "朝食",
      "menuName": "トーストと目玉焼き",
      "calorie": 400,
      "protein": 15.0,
      "fat": 12.0,
      "carbo": 50.0,
    },
    {
      "mealId": "m_02",
      "category": "昼食",
      "menuName": "和風ハンバーグ定食",
      "calorie": 750,
      "protein": 22.5,
      "fat": 18.0,
      "carbo": 90.0,
    },
  ];

  // レーダーチャート用の達成率計算ヘルパー (%)
  double _calculatePercentage(double consumed, double target) {
    if (target == 0) return 0.0;
    double ratio = (consumed / target) * 100;
    return ratio > 100 ? 100 : ratio; // 上限100%
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF66BB6A);
    // 受け取った widget.isDarkMode の状態を使用
    final bool isDarkMode = widget.isDarkMode;

    // モードに応じた背景色・文字色・カード色を定義
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "ホーム",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 日付表示
            Text(
              "${currentDate.year}/${currentDate.month}/${currentDate.day}",
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // カロリーサークル
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryGreen,
                  width: 10,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "摂取カロリー",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$consumedCalorie", // 変数を反映
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      "/ $targetCalorie kcal",
                      style: TextStyle(color: textColor),
                    ) // 変数を反映
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // PFCカード表示
            Row(
              children: [
                Expanded(
                  child: _pfcCard("P", "${consumedProtein.toStringAsFixed(1)} g", const Color(0xFF66BB6A), cardColor, textColor),
                ),
                Expanded(
                  child: _pfcCard("F", "${consumedFat.toStringAsFixed(1)} g", Colors.orange, cardColor, textColor),
                ),
                Expanded(
                  child: _pfcCard("C", "${consumedCarbo.toStringAsFixed(1)} g", Colors.redAccent, cardColor, textColor),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "栄養バランス",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // レーダーチャート（変数連動）
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: RadarChart(
                    RadarChartData(
                      radarShape: RadarShape.polygon,
                      tickCount: 5,
                      titlePositionPercentageOffset: 0.3,
                      ticksTextStyle: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.grey,
                        fontSize: 10,
                      ),
                      titleTextStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      getTitle: (index, angle) {
                        switch (index) {
                          case 0:
                            return const RadarChartTitle(text: 'タンパク質');
                          case 1:
                            return const RadarChartTitle(text: '脂質');
                          case 2:
                            return const RadarChartTitle(text: '炭水化物');
                          case 3:
                            return const RadarChartTitle(text: 'ビタミン');
                          case 4:
                            return const RadarChartTitle(text: 'ミネラル');
                          default:
                            return const RadarChartTitle(text: '');
                        }
                      },
                      dataSets: [
                        // 目標基準線 (100%固定の外枠)
                        RadarDataSet(
                          borderColor: Colors.redAccent,
                          borderWidth: 3,
                          fillColor: (isDarkMode ? Colors.white : Colors.grey).withOpacity(0.15),
                          entryRadius: 0,
                          dataEntries: const [
                            RadarEntry(value: 100),
                            RadarEntry(value: 100),
                            RadarEntry(value: 100),
                            RadarEntry(value: 100),
                            RadarEntry(value: 100),
                          ],
                        ),
                        // 実際の摂取量 (変数から計算した割合データ)
                        RadarDataSet(
                          borderColor: primaryGreen,
                          borderWidth: 3,
                          fillColor: primaryGreen.withOpacity(0.4),
                          entryRadius: 3,
                          dataEntries: [
                            RadarEntry(
                                value: _calculatePercentage(
                                    consumedProtein, targetProtein)),
                            RadarEntry(
                                value: _calculatePercentage(
                                    consumedFat, targetFat)),
                            RadarEntry(
                                value: _calculatePercentage(
                                    consumedCarbo, targetCarbo)),
                            RadarEntry(
                                value: _calculatePercentage(
                                    consumedVitamin, targetVitamin)),
                            RadarEntry(
                                value: _calculatePercentage(
                                    consumedMineral, targetMineral)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "ユーザーID: $userId",
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        backgroundColor: backgroundColor,
        onTap: (index) {
          if (index == 0) return;
          switch (index) {
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MealPage(isDarkMode: widget.isDarkMode)),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => GraphScreen(isDarkMode: widget.isDarkMode)),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => CalendarScreen(isDarkMode: widget.isDarkMode)),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MypageScreen(isDarkMode: widget.isDarkMode)),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: '記録'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'グラフ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
      ),
    );
  }

  // PFCカードを生成するヘルパー関数
  static Widget _pfcCard(String title, String value, Color color, Color cardColor, Color textColor) {
    return Card(
      elevation: 0,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
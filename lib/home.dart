import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'meal.dart';
import 'gurahu.dart';
import 'calendar.dart';
import 'mypage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "ホーム",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "${today.year}/${today.month}/${today.day}",
              style: const TextStyle(
                color: Colors.grey,
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
                  color: Colors.green,
                  width: 10,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "摂取カロリー",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "---",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("/ --- kcal")
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // PFC
            Row(
              children: [
                Expanded(
                  child: _pfcCard("P", "--- g", Colors.green),
                ),
                Expanded(
                  child: _pfcCard("F", "--- g", Colors.orange),
                ),
                Expanded(
                  child: _pfcCard("C", "--- g", Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "栄養バランス",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
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
                      ticksTextStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                      titleTextStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
                        RadarDataSet(
                          borderColor: Colors.red,
                          borderWidth: 3,
                          fillColor: Colors.grey.withOpacity(0.15),
                          entryRadius: 0,
                          dataEntries: const [
                            RadarEntry(value: 70),
                            RadarEntry(value: 70),
                            RadarEntry(value: 60),
                            RadarEntry(value: 100),
                            RadarEntry(value: 100),
                          ],
                        ),
                        RadarDataSet(
                          borderColor: Colors.green,
                          borderWidth: 3,
                          fillColor: Colors.green.withOpacity(0.4),
                          entryRadius: 3,
                          dataEntries: const [
                            RadarEntry(value: 70),
                            RadarEntry(value: 60),
                            RadarEntry(value: 80),
                            RadarEntry(value: 50),
                            RadarEntry(value: 90),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "※現在はテストデータを表示中",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF66BB6A),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) return;
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: '記録'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'グラフ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
      ),
    );
  }

  static Widget _pfcCard(String title, String value, Color color) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
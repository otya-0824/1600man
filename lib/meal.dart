import 'package:flutter/material.dart';
import 'meal_detail.dart';
import 'meal_model.dart';
import 'meal_storage_service.dart';
import 'home.dart';
import 'gurahu.dart';
import 'calendar.dart';
import 'mypage.dart';

class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  // 朝食・昼食・夕食・間食の各保存データを保持するマップ
  Map<String, DailyMeal?> mealDataMap = {
    "朝食": null,
    "昼食": null,
    "夕食": null,
    "間食": null,
  };

  @override
  void initState() {
    super.initState();
    _loadAllMeals();
  }

  // 当日の各食事データを独立して全取得
  Future<void> _loadAllMeals() async {
    DateTime now = DateTime.now();
    String dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    Map<String, DailyMeal?> tempMap = {};
    for (String type in ["朝食", "昼食", "夕食", "間食"]) {
      String storageKey = "${dateStr}_$type";
      DailyMeal? meal = await MealStorageService.getDailyMeal(storageKey);
      tempMap[type] = meal;
    }

    setState(() {
      mealDataMap = tempMap;
    });
  }

  // 食事記録画面への遷移（mealTypeを指定）
  Future<void> _navigateToDetail(String mealType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealDetailPage(mealType: mealType),
      ),
    );

    if (result == true) {
      _loadAllMeals(); // 保存後に戻ってきたら再描画
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF66BB6A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("食事一覧", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMealCard("朝食", Icons.wb_sunny_outlined, primaryGreen),
          const SizedBox(height: 12),
          _buildMealCard("昼食", Icons.wb_sunny, primaryGreen),
          const SizedBox(height: 12),
          _buildMealCard("夕食", Icons.nights_stay, primaryGreen),
          const SizedBox(height: 12),
          _buildMealCard("間食", Icons.cookie, primaryGreen),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) return;
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GraphScreen()));
              break;
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
              break;
            case 4:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MypageScreen()));
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

  // 各食事カードのコンポーネント
  Widget _buildMealCard(String mealType, IconData icon, Color primaryColor) {
    DailyMeal? meal = mealDataMap[mealType];
    List<FoodItem> foods = meal?.foods ?? [];
    int totalCalories = foods.fold(0, (sum, item) => sum + item.calorie);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  mealType,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  "$totalCalories kcal",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.add_circle, color: primaryColor, size: 28),
                  onPressed: () => _navigateToDetail(mealType),
                ),
              ],
            ),
            if (foods.isNotEmpty) ...[
              const Divider(),
              Column(
                children: foods.map((food) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(food.name, style: const TextStyle(fontSize: 14)),
                        Text("${food.calorie} kcal", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
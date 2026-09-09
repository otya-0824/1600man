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
  // 朝食・昼食・夕食・間食ごとに、その日の記録一覧を保持するマップ
  Map<String, List<FoodItem>> mealDataMap = {
    "朝食": [],
    "昼食": [],
    "夕食": [],
    "間食": [],
  };

  @override
  void initState() {
    super.initState();
    _loadAllMeals();
  }

  // 当日の記録をローカル(SharedPreferences)から食事区分ごとに読み込む
  Future<void> _loadAllMeals() async {
    final ds = MealStorageService.dateStr(DateTime.now());

    final tempMap = <String, List<FoodItem>>{};
    for (final type in MealStorageService.mealTypes) {
      final meal = await MealStorageService.getDailyMeal("${ds}_$type");
      tempMap[type] = meal?.foods ?? [];
    }
    if (!mounted) return;

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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
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
    List<FoodItem> foods = mealDataMap[mealType] ?? [];
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
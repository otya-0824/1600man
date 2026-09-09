import 'package:flutter/material.dart';
import 'meal_detail.dart';
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
  DateTime selectedDate = DateTime.now();

  // 仮データ（将来的にFirebaseから取得）
  final Map<String, List<Map<String, String>>> mealData = {
    "2026-08-26": [
      {"title": "朝食", "calorie": "400 kcal"},
      {"title": "昼食", "calorie": "750 kcal"},
      {"title": "夕食", "calorie": "600 kcal"},
      {"title": "その他", "calorie": "150 kcal"},
    ]
  };

  // デフォルトの入力用初期枠（今日用）
  final List<Map<String, String>> defaultMealSlots = [
    {"title": "朝食", "calorie": "--- kcal"},
    {"title": "昼食", "calorie": "--- kcal"},
    {"title": "夕食", "calorie": "--- kcal"},
    {"title": "その他", "calorie": "--- kcal"},
  ];

  String get dateKey {
    return "${selectedDate.year}"
        "-${selectedDate.month.toString().padLeft(2, '0')}"
        "-${selectedDate.day.toString().padLeft(2, '0')}";
  }

  // 選択中の日付が「今日」かどうか判定
  bool get isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  String get formattedDate {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return "${selectedDate.year}年"
        "${selectedDate.month}月"
        "${selectedDate.day}日"
        "（${weekdays[selectedDate.weekday - 1]}）";
  }

  void previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
  }

  void nextDay() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    // データ取得ロジック
    // 1. 今日の場合: 保存データがあればそれを使い、無ければデフォルトの入力枠を表示
    // 2. 今日以外の場合: 保存データがあれば表示し、無ければ null（データなし表示）
    List<Map<String, String>>? meals;
    if (isToday) {
      meals = mealData[dateKey] ?? defaultMealSlots;
    } else {
      meals = mealData[dateKey];
    }

    const Color primaryGreen = Color(0xFF66BB6A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "食事の記録",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // 日付切り替えヘッダー
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: previousDay,
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: nextDay,
                ),
              ],
            ),
          ),

          // 食事リスト表示エリア
          Expanded(
            child: meals == null
                ? const Center(
                    child: Text(
                      "データがありません",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      return mealCard(
                        context: context,
                        title: meals![index]["title"]!,
                        calorie: meals[index]["calorie"]!,
                        canEdit: isToday, // 今日だけ編集可能にする
                      );
                    },
                  ),
          ),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
      ),
    );
  }

  Widget mealCard({
    required BuildContext context,
    required String title,
    required String calorie,
    required bool canEdit,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant,
              size: 40,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(calorie),
              ],
            ),
          ),
          // 今日（編集可能）の場合のみ ＋ ボタンを表示
          if (canEdit)
            CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: IconButton(
                icon: const Icon(
                  Icons.add,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MealDetailPage(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
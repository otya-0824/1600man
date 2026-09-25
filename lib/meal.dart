import 'package:flutter/material.dart';
import 'meal_detail.dart';
import 'home.dart';
import 'gurahu.dart';
import 'calendar.dart';
import 'mypage.dart';

class MealPage extends StatefulWidget {
  final bool isDarkMode; // ← ダークモードの状態を受け取る変数

  const MealPage({
    super.key,
    this.isDarkMode = false, // デフォルトはライトモード
  });

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
    List<Map<String, String>>? meals;
    if (isToday) {
      meals = mealData[dateKey] ?? defaultMealSlots;
    } else {
      meals = mealData[dateKey];
    }

    const Color primaryGreen = Color(0xFF66BB6A);

    // ダークモードに応じた色の定義
    final backgroundColor = widget.isDarkMode ? const Color(0xFF121212) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "食事の記録",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
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
                  icon: Icon(Icons.chevron_left, color: textColor),
                  onPressed: previousDay,
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: textColor),
                  onPressed: nextDay,
                ),
              ],
            ),
          ),

          // 食事リスト表示エリア
          Expanded(
            child: meals == null
                ? Center(
                    child: Text(
                      "データがありません",
                      style: TextStyle(
                        color: subTextColor,
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
        backgroundColor: backgroundColor,
        onTap: (index) {
          if (index == 1) return;

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage(isDarkMode: widget.isDarkMode)), // ← 修正：isDarkModeを渡す
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MealPage(isDarkMode: widget.isDarkMode)),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => GraphScreen(isDarkMode: widget.isDarkMode)), // ← 修正：isDarkModeを渡す
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => CalendarScreen(isDarkMode: widget.isDarkMode)), // ← 修正：isDarkModeを渡す
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MypageScreen(isDarkMode: widget.isDarkMode)), // ← 修正：isDarkModeを渡す
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
    final cardColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.grey;
    final iconBgColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widget.isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
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
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.restaurant,
              size: 40,
              color: subTextColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  calorie,
                  style: TextStyle(color: subTextColor),
                ),
              ],
            ),
          ),
          // 今日（編集可能）の場合のみ ＋ ボタンを表示
          if (canEdit)
            CircleAvatar(
              backgroundColor: iconBgColor,
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: textColor,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MealDetailPage(isDarkMode: widget.isDarkMode),
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
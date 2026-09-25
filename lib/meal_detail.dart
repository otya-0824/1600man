import 'package:flutter/material.dart';

class MealDetailPage extends StatefulWidget {
  final bool isDarkMode; // ダークモードの状態を受け取る変数

  const MealDetailPage({
    super.key,
    this.isDarkMode = false, // デフォルトはライトモード
  });

  @override
  State<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  // 選択中のタブ (0: よく食べる, 1: 履歴, 2: Myメニュー)
  int selectedTabIndex = 0;

  // 1. ユーザーが実際に選択して「追加した」食べた料理の一覧
  final List<Map<String, dynamic>> selectedFoods = [];

  // 2. 候補用データの定義（タブや検索で表示）
  final Map<int, List<Map<String, dynamic>>> foodCandidates = {
    0: [
      {"name": "ごはん(白米)", "amount": "150g", "calorie": 252, "icon": Icons.rice_bowl},
      {"name": "納豆", "amount": "1パック", "calorie": 100, "icon": Icons.breakfast_dining},
      {"name": "卵(生)", "amount": "1個", "calorie": 78, "icon": Icons.egg},
    ],
    1: [
      {"name": "味噌汁", "amount": "1杯", "calorie": 50, "icon": Icons.soup_kitchen},
      {"name": "バナナ", "amount": "1本", "calorie": 86, "icon": Icons.apple},
    ],
    2: [
      {"name": "特製プロテインシェイク", "amount": "1杯", "calorie": 200, "icon": Icons.local_drink},
    ],
  };

  // 合計カロリーの自動計算
  int get totalCalories {
    return selectedFoods.fold(0, (sum, item) => sum + (item["calorie"] as int));
  }

  // 料理の追加処理
  void _addFood(Map<String, dynamic> food) {
    setState(() {
      selectedFoods.add(food);
    });
  }

  // 料理の削除処理
  void _removeFood(int index) {
    setState(() {
      selectedFoods.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF66BB6A);

    // ダークモードに応じた色の定義
    final backgroundColor = widget.isDarkMode ? const Color(0xFF121212) : Colors.white;
    final cardColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.grey;
    final fillColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;
    final dividerColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "朝食の記録",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "食品を検索",
                hintStyle: TextStyle(color: subTextColor),
                prefixIcon: Icon(Icons.search, color: subTextColor),
                filled: true,
                fillColor: fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // タブボタン（よく食べる / 履歴 / Myメニュー）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTabButton("よく食べる", 0),
                const SizedBox(width: 8),
                _buildTabButton("履歴", 1),
                const SizedBox(width: 8),
                _buildTabButton("Myメニュー", 2),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 候補リスト（タブに応じて切り替え）
          SizedBox(
            height: 160,
            child: ListView.builder(
              itemCount: foodCandidates[selectedTabIndex]?.length ?? 0,
              itemBuilder: (context, index) {
                final food = foodCandidates[selectedTabIndex]![index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: widget.isDarkMode ? Colors.grey.shade800 : Colors.green.shade50,
                    child: Icon(food["icon"], color: primaryGreen, size: 20),
                  ),
                  title: Text(food["name"], style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  subtitle: Text("${food["amount"]} - ${food["calorie"]} kcal", style: TextStyle(color: subTextColor)),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: primaryGreen),
                    onPressed: () => _addFood(food),
                  ),
                );
              },
            ),
          ),

          Divider(thickness: 1, color: dividerColor),

          // 選択された料理の一覧表示領域
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "選択した料理 (${selectedFoods.length})",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
              ),
            ),
          ),

          Expanded(
            child: selectedFoods.isEmpty
                ? Center(
                    child: Text(
                      "追加された料理はありません\n上のリストから「＋」で追加してください",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subTextColor),
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedFoods.length,
                    itemBuilder: (context, index) {
                      final food = selectedFoods[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                          child: Icon(food["icon"], color: widget.isDarkMode ? Colors.white70 : Colors.black54),
                        ),
                        title: Text(food["name"], style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        subtitle: Text(food["amount"], style: TextStyle(color: subTextColor)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${food["calorie"]} kcal",
                              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => _removeFood(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // フッター（合計カロリー・保存ボタン）
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color: widget.isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("合計 ", style: TextStyle(fontSize: 18, color: textColor)),
                    Text(
                      "$totalCalories",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    Text(" kcal", style: TextStyle(fontSize: 18, color: textColor)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "保存",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // タブボタン生成ヘルパー
  Widget _buildTabButton(String label, int index) {
    final bool isSelected = selectedTabIndex == index;
    
    // タブの非選択時の背景色と文字色をダークモード対応に調整
    final unselectedBgColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final unselectedTextColor = widget.isDarkMode ? Colors.white70 : Colors.black;

    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF66BB6A) : unselectedBgColor,
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : unselectedTextColor),
        ),
      ),
    );
  }
}
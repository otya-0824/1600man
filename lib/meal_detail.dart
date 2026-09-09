import 'package:flutter/material.dart';

class MealDetailPage extends StatefulWidget {
  const MealDetailPage({super.key});

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
    const Color primaryGreen = Colors.green;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "朝食の記録",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        // actions を削除して右上の完了ボタンを消去しました
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "食品を検索",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
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
                    backgroundColor: Colors.green.shade50,
                    child: Icon(food["icon"], color: primaryGreen, size: 20),
                  ),
                  title: Text(food["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${food["amount"]} - ${food["calorie"]} kcal"),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: primaryGreen),
                    onPressed: () => _addFood(food),
                  ),
                );
              },
            ),
          ),

          const Divider(thickness: 1),

          // 選択された料理の一覧表示領域
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "選択した料理 (${selectedFoods.length})",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          Expanded(
            child: selectedFoods.isEmpty
                ? const Center(
                    child: Text(
                      "追加された料理はありません\n上のリストから「＋」で追加してください",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedFoods.length,
                    itemBuilder: (context, index) {
                      final food = selectedFoods[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: Icon(food["icon"], color: Colors.black54),
                        ),
                        title: Text(food["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(food["amount"]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${food["calorie"]} kcal",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
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
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("合計 ", style: TextStyle(fontSize: 18)),
                    Text(
                      "$totalCalories",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Text(" kcal", style: TextStyle(fontSize: 18)),
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
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green : Colors.grey.shade200,
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
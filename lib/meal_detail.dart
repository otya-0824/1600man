import 'package:flutter/material.dart';
import 'meal_model.dart';
import 'meal_storage_service.dart';
import 'my_menu_create.dart';
import 'models/food_item.dart' as db; // panpanの食品DBモデル(FoodItem名が衝突するため接頭辞付き)
import 'models/meal.dart';
import 'services/nutrition_facade.dart';
import 'services/record_service.dart';

class MealDetailPage extends StatefulWidget {
  final String mealType; // "朝食", "昼食", "夕食", "間食" などを受け取る

  const MealDetailPage({
    super.key,
    this.mealType = "朝食",
  });

  @override
  State<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  int selectedTabIndex = 0;
  List<Map<String, dynamic>> selectedFoods = [];

  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _vitaminController = TextEditingController();
  final TextEditingController _mineralController = TextEditingController();

  List<MyMenu> myMenuList = [];

  // 栄養計算エンジン(panpan)との橋渡し役。食品DB検索・栄養計算に使う。
  final NutritionFacade _facade = NutritionFacade();
  // 「栄養DB」タブの検索結果
  List<db.FoodItem> _dbResults = [];
  final TextEditingController _dbSearchController = TextEditingController();

  Map<int, List<Map<String, dynamic>>> foodCandidates = {
    0: [
      {"name": "ごはん(白米)", "amount": "150g", "calorie": 252, "protein": 3.8, "fat": 0.5, "carbs": 55.7, "vitamin": 0.0, "mineral": 0.0, "icon": Icons.rice_bowl},
      {"name": "納豆", "amount": "1パック", "calorie": 100, "protein": 8.6, "fat": 5.0, "carbs": 6.0, "vitamin": 0.0, "mineral": 0.0, "icon": Icons.breakfast_dining},
      {"name": "卵(生)", "amount": "1個", "calorie": 78, "protein": 6.2, "fat": 5.2, "carbs": 0.2, "vitamin": 0.0, "mineral": 0.0, "icon": Icons.egg},
    ],
    1: [],
  };

  @override
  void initState() {
    super.initState();
    _loadSavedDataAndHistory();
    _loadMyMenuList();
  }

  Future<void> _loadMyMenuList() async {
    List<MyMenu> list = await MealStorageService.getMyMenuList();
    setState(() {
      myMenuList = list;
    });
  }

  // 当日の記録＆履歴データの取得（日付 + 食事区分で完全に個別管理）
  Future<void> _loadSavedDataAndHistory() async {
    DateTime now = DateTime.now();
    String dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    String storageKey = "${dateStr}_${widget.mealType}";

    DailyMeal? savedMeal = await MealStorageService.getDailyMeal(storageKey);
    
    if (savedMeal != null) {
      setState(() {
        selectedFoods = savedMeal.foods.map((food) => {
          "name": food.name,
          "amount": food.amount,
          "calorie": food.calorie,
          "protein": food.protein,
          "fat": food.fat,
          "carbs": food.carbs,
          "vitamin": food.vitamin,
          "mineral": food.mineral,
          "icon": Icons.restaurant,
        }).toList();
      });
    } else {
      // 該当する食事区分に保存データがない場合は空リストでリセット
      setState(() {
        selectedFoods = [];
      });
    }

    List<Map<String, dynamic>> historyItems = [];
    if (savedMeal != null) {
      for (var f in savedMeal.foods) {
        historyItems.add({
          "name": f.name,
          "amount": f.amount,
          "calorie": f.calorie,
          "protein": f.protein,
          "fat": f.fat,
          "carbs": f.carbs,
          "vitamin": f.vitamin,
          "mineral": f.mineral,
          "icon": Icons.history,
        });
      }
    }

    setState(() {
      foodCandidates[1] = historyItems;
    });
  }

  int get totalCalories {
    return selectedFoods.fold(0, (sum, item) => sum + (item["calorie"] as int));
  }

  void _addFood(Map<String, dynamic> food) {
    setState(() {
      selectedFoods.add(food);
    });
  }

  void _addMyMenu(MyMenu menu) {
    setState(() {
      for (var food in menu.foods) {
        selectedFoods.add({
          "name": food.name,
          "amount": food.amount,
          "calorie": food.calorie,
          "protein": food.protein,
          "fat": food.fat,
          "carbs": food.carbs,
          "vitamin": food.vitamin,
          "mineral": food.mineral,
          "icon": Icons.restaurant_menu,
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("「${menu.title}」を追加しました"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFood(int index) {
    setState(() {
      selectedFoods.removeAt(index);
    });
  }

  void _addCustomFood() {
    if (_nameController.text.isEmpty) return;

    final customFood = {
      "name": _nameController.text,
      "amount": "1食",
      "calorie": int.tryParse(_calorieController.text) ?? 0,
      "protein": double.tryParse(_proteinController.text) ?? 0.0,
      "fat": double.tryParse(_fatController.text) ?? 0.0,
      "carbs": double.tryParse(_carbsController.text) ?? 0.0,
      "vitamin": double.tryParse(_vitaminController.text) ?? 0.0,
      "mineral": double.tryParse(_mineralController.text) ?? 0.0,
      "icon": Icons.edit_note,
    };

    _addFood(customFood);

    setState(() {
      foodCandidates[1]?.insert(0, customFood);
    });

    _nameController.clear();
    _calorieController.clear();
    _proteinController.clear();
    _fatController.clear();
    _carbsController.clear();
    _vitaminController.clear();
    _mineralController.clear();

    FocusScope.of(context).unfocus();
  }

  // 「栄養DB」タブ：食品DB(約2500件)をキーワード検索する
  Future<void> _searchDb(String query) async {
    if (query.trim().isEmpty) return;
    final results = await _facade.searchFoods(query.trim());
    if (!mounted) return;
    setState(() {
      _dbResults = results;
    });
  }

  // DB検索結果を選び、量(g)を入力して栄養を自動計算し、リストに追加する
  Future<void> _addFromDb(db.FoodItem food) async {
    final gramsController = TextEditingController(text: "100");
    final grams = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(food.name),
        content: TextField(
          controller: gramsController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(labelText: "量", suffixText: "g"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("キャンセル"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              ctx,
              double.tryParse(gramsController.text) ?? 0,
            ),
            child: const Text("追加"),
          ),
        ],
      ),
    );

    if (grams == null || grams <= 0) return;

    // panpanの計算エンジンで栄養を計算する
    final entry =
        await _facade.calcEntry(foodName: food.name, amountGrams: grams);
    if (!mounted) return;
    if (entry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("栄養データが見つかりませんでした")),
      );
      return;
    }

    _addFood({
      "name": entry.name,
      "amount": "${grams.round()}g",
      "calorie": entry.kcal.round(),
      "protein": double.parse(entry.protein.toStringAsFixed(1)),
      "fat": double.parse(entry.fat.toStringAsFixed(1)),
      "carbs": double.parse(entry.carbohydrate.toStringAsFixed(1)),
      "vitamin": 0.0,
      "mineral": 0.0,
      "icon": Icons.local_dining,
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Colors.green;

    List<Map<String, dynamic>> currentCandidates = foodCandidates[selectedTabIndex] ?? [];
    if (searchQuery.isNotEmpty && selectedTabIndex < 2) {
      currentCandidates = currentCandidates
          .where((food) => (food["name"] as String).contains(searchQuery))
          .toList();
    }

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
        title: Text(
          "${widget.mealType}の記録",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: "料理・食品を検索",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton("栄養DB", 4),
                  const SizedBox(width: 6),
                  _buildTabButton("よく食べる", 0),
                  const SizedBox(width: 6),
                  _buildTabButton("履歴", 1),
                  const SizedBox(width: 6),
                  _buildTabButton("Myメニュー", 2),
                  const SizedBox(width: 6),
                  _buildTabButton("手動入力", 3),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 180,
            child: selectedTabIndex == 4
                ? _buildDbSearchTab(primaryGreen)
                : selectedTabIndex == 2
                ? _buildMyMenuTab(primaryGreen)
                : selectedTabIndex == 3
                    ? _buildCustomInputForm(primaryGreen)
                    : currentCandidates.isEmpty
                        ? const Center(
                            child: Text("該当する料理がありません", style: TextStyle(color: Colors.grey)),
                          )
                        : ListView.builder(
                            itemCount: currentCandidates.length,
                            itemBuilder: (context, index) {
                              final food = currentCandidates[index];
                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade50,
                                  child: Icon(food["icon"] ?? Icons.restaurant, color: primaryGreen, size: 20),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                      "追加された料理はありません",
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
                          child: Icon(food["icon"] ?? Icons.restaurant, color: Colors.black54),
                        ),
                        title: Text(food["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "${food["amount"]} - ${food["calorie"]} kcal\n(P:${food["protein"]}g F:${food["fat"]}g C:${food["carbs"]}g)",
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeFood(index),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("合計 ", style: TextStyle(fontSize: 16)),
                    Text(
                      "$totalCalories",
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const Text(" kcal", style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      List<FoodItem> foodList = selectedFoods.map((item) {
                        return FoodItem(
                          name: item["name"] ?? "",
                          amount: item["amount"] ?? "1食",
                          calorie: item["calorie"] ?? 0,
                          protein: (item["protein"] ?? 0.0).toDouble(),
                          fat: (item["fat"] ?? 0.0).toDouble(),
                          carbs: (item["carbs"] ?? 0.0).toDouble(),
                          vitamin: (item["vitamin"] ?? 0.0).toDouble(),
                          mineral: (item["mineral"] ?? 0.0).toDouble(),
                        );
                      }).toList();

                      DateTime now = DateTime.now();
                      String dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                      String storageKey = "${dateStr}_${widget.mealType}";

                      DailyMeal dailyMeal = DailyMeal(
                        date: storageKey,
                        foods: foodList,
                      );
                      await MealStorageService.saveDailyMeal(dailyMeal);

                      // ホーム画面の集計元であるFirestoreにも反映する。
                      // 同じ食事区分を置き換える形で保存し、二重計上を防ぐ。
                      final okabeMeals = selectedFoods
                          .map((item) => Meal(
                                name: item["name"] ?? "",
                                calorie: (item["calorie"] ?? 0).toDouble(),
                                protein: (item["protein"] ?? 0.0).toDouble(),
                                fat: (item["fat"] ?? 0.0).toDouble(),
                                carbo: (item["carbs"] ?? 0.0).toDouble(),
                                time: now,
                                mealType: widget.mealType,
                              ))
                          .toList();
                      try {
                        await RecordService().replaceMealsForType(
                          now,
                          widget.mealType,
                          okabeMeals,
                        );
                      } catch (_) {
                        // Firestore未接続などでも、ローカル保存は成立させる
                      }

                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "${widget.mealType}を保存",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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

  // 「栄養DB」タブ：食品DBを検索し、量(g)から栄養を自動計算して追加する
  Widget _buildDbSearchTab(Color primaryGreen) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _dbSearchController,
            textInputAction: TextInputAction.search,
            onSubmitted: _searchDb,
            decoration: InputDecoration(
              hintText: "食品DBを検索(例: 普通牛乳)",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _searchDb(_dbSearchController.text),
              ),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        Expanded(
          child: _dbResults.isEmpty
              ? const Center(
                  child: Text(
                    "食品名で検索してください",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                )
              : ListView.builder(
                  itemCount: _dbResults.length,
                  itemBuilder: (ctx, i) {
                    final food = _dbResults[i];
                    return ListTile(
                      dense: true,
                      title: Text(
                        food.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text("100gあたり ${food.kcal.round()} kcal"),
                      trailing: IconButton(
                        icon: Icon(Icons.add_circle, color: primaryGreen),
                        onPressed: () => _addFromDb(food),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMyMenuTab(Color primaryGreen) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ElevatedButton.icon(
            onPressed: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyMenuCreatePage()),
              );
              if (res == true) {
                _loadMyMenuList();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("Myメニューを新規作成"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 36),
            ),
          ),
        ),
        Expanded(
          child: myMenuList.isEmpty
              ? const Center(child: Text("登録されたMyメニューはありません", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: myMenuList.length,
                  itemBuilder: (ctx, i) {
                    final menu = myMenuList[i];
                    int totalCal = menu.foods.fold(0, (sum, item) => sum + item.calorie);
                    return ListTile(
                      dense: true,
                      onTap: () => _addMyMenu(menu),
                      title: Text(menu.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${menu.foods.length}品 - 計 $totalCal kcal"),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () => _addMyMenu(menu),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCustomInputForm(Color primaryGreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(flex: 2, child: _buildInputField(_nameController, "料理名", TextInputType.text)),
                const SizedBox(width: 8),
                Expanded(flex: 1, child: _buildInputField(_calorieController, "カロリー (kcal)", TextInputType.number)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: _buildInputField(_proteinController, "タンパク質 (g)", TextInputType.number)),
                const SizedBox(width: 6),
                Expanded(child: _buildInputField(_fatController, "脂質 (g)", TextInputType.number)),
                const SizedBox(width: 6),
                Expanded(child: _buildInputField(_carbsController, "炭水化物 (g)", TextInputType.number)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: _buildInputField(_vitaminController, "ビタミン (mg)", TextInputType.number)),
                const SizedBox(width: 6),
                Expanded(child: _buildInputField(_mineralController, "ミネラル (mg)", TextInputType.number)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                onPressed: _addCustomFood,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("リストに追加"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, TextInputType keyboardType) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final bool isSelected = selectedTabIndex == index;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.grey.shade200,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 13),
      ),
    );
  }
}
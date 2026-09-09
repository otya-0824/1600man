import 'package:flutter/material.dart';
import 'meal_model.dart';
import 'meal_storage_service.dart';

class MyMenuCreatePage extends StatefulWidget {
  const MyMenuCreatePage({super.key});

  @override
  State<MyMenuCreatePage> createState() => _MyMenuCreatePageState();
}

class _MyMenuCreatePageState extends State<MyMenuCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final List<FoodItem> _selectedFoods = [];

  // 検索・入力用コントローラー
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  
  // 五大栄養素用のコントローラー
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _vitaminController = TextEditingController();
  final TextEditingController _mineralController = TextEditingController();

  String _searchQuery = "";
  int _inputTab = 0; // 0: 検索から追加, 1: 手動入力

  final List<Map<String, dynamic>> _presetFoods = [
    {"name": "ごはん(白米)", "amount": "150g", "calorie": 252, "protein": 3.8, "fat": 0.5, "carbs": 55.7, "vitamin": 0.0, "mineral": 0.0},
    {"name": "納豆", "amount": "1パック", "calorie": 100, "protein": 8.6, "fat": 5.0, "carbs": 6.0, "vitamin": 0.0, "mineral": 0.0},
    {"name": "目玉焼き", "amount": "1個", "calorie": 90, "protein": 6.2, "fat": 7.0, "carbs": 0.2, "vitamin": 0.0, "mineral": 0.0},
    {"name": "味噌汁", "amount": "1杯", "calorie": 50, "protein": 2.5, "fat": 1.0, "carbs": 5.0, "vitamin": 0.0, "mineral": 0.0},
    {"name": "プロテイン", "amount": "1食", "calorie": 120, "protein": 20.0, "fat": 1.5, "carbs": 3.0, "vitamin": 0.0, "mineral": 0.0},
  ];

  void _addFood(FoodItem food) {
    setState(() {
      _selectedFoods.add(food);
    });
  }

  // 手動入力から五大栄養素を含めて追加する処理
  void _addCustomFood() {
    if (_nameController.text.isEmpty) return;
    
    final item = FoodItem(
      name: _nameController.text,
      amount: "1食",
      calorie: int.tryParse(_calorieController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0.0,
      fat: double.tryParse(_fatController.text) ?? 0.0,
      carbs: double.tryParse(_carbsController.text) ?? 0.0,
      vitamin: double.tryParse(_vitaminController.text) ?? 0.0,
      mineral: double.tryParse(_mineralController.text) ?? 0.0,
    );
    _addFood(item);

    // フォームのクリア
    _nameController.clear();
    _calorieController.clear();
    _proteinController.clear();
    _fatController.clear();
    _carbsController.clear();
    _vitaminController.clear();
    _mineralController.clear();
    
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveMyMenu() async {
    if (_titleController.text.isEmpty || _selectedFoods.isEmpty) return;

    List<MyMenu> currentList = await MealStorageService.getMyMenuList();
    MyMenu newMenu = MyMenu(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      foods: _selectedFoods,
    );

    currentList.add(newMenu);
    await MealStorageService.saveMyMenuList(currentList);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _vitaminController.dispose();
    _mineralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Colors.green;

    List<Map<String, dynamic>> filteredPresets = _presetFoods
        .where((item) => (item["name"] as String).contains(_searchQuery))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Myメニューの新規作成", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Myメニュー名 (例: 筋トレ日の朝食)",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text("検索から追加"),
                selected: _inputTab == 0,
                onSelected: (val) => setState(() => _inputTab = 0),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text("手動入力"),
                selected: _inputTab == 1,
                onSelected: (val) => setState(() => _inputTab = 1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // 入力エリア
          SizedBox(
            height: 180,
            child: _inputTab == 0
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: const InputDecoration(
                            hintText: "料理を検索",
                            isDense: true,
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredPresets.length,
                          itemBuilder: (ctx, i) {
                            final item = filteredPresets[i];
                            return ListTile(
                              dense: true,
                              title: Text(item["name"]),
                              subtitle: Text("${item["calorie"]} kcal"),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle, color: primaryGreen),
                                onPressed: () {
                                  _addFood(FoodItem(
                                    name: item["name"],
                                    amount: item["amount"],
                                    calorie: item["calorie"],
                                    protein: (item["protein"] ?? 0.0).toDouble(),
                                    fat: (item["fat"] ?? 0.0).toDouble(),
                                    carbs: (item["carbs"] ?? 0.0).toDouble(),
                                    vitamin: (item["vitamin"] ?? 0.0).toDouble(),
                                    mineral: (item["mineral"] ?? 0.0).toDouble(),
                                  ));
                                },
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  )
                : _buildCustomInputForm(primaryGreen),
          ),
          const Divider(),
          const Text("構成する料理一覧", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: _selectedFoods.isEmpty
                ? const Center(child: Text("料理が追加されていません", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _selectedFoods.length,
                    itemBuilder: (ctx, i) {
                      final item = _selectedFoods[i];
                      return ListTile(
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${item.calorie} kcal | P:${item.protein}g F:${item.fat}g C:${item.carbs}g"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => _selectedFoods.removeAt(i)),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveMyMenu,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen, 
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Myメニューを保存", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // 五大栄養素入力用フォーム
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
                label: const Text("構成リストに追加"),
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
}
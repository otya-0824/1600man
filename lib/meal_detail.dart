import 'package:flutter/material.dart';

class MealDetailPage extends StatefulWidget {
  const MealDetailPage({super.key});

  @override
  State<MealDetailPage> createState() =>
      _MealDetailPageState();
}

class _MealDetailPageState
    extends State<MealDetailPage> {
  int totalCalories = 566;

  final List<Map<String, dynamic>> foods = [
    {
      "name": "ごはん(白米)",
      "amount": "150g",
      "calorie": 252,
      "icon": Icons.rice_bowl,
    },
    {
      "name": "納豆",
      "amount": "1パック",
      "calorie": 100,
      "icon": Icons.breakfast_dining,
    },
    {
      "name": "味噌汁",
      "amount": "1杯",
      "calorie": 50,
      "icon": Icons.soup_kitchen,
    },
    {
      "name": "卵(生)",
      "amount": "1個",
      "calorie": 78,
      "icon": Icons.egg,
    },
    {
      "name": "バナナ",
      "amount": "1本",
      "calorie": 86,
      "icon": Icons.apple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        centerTitle: true,

        title: const Text(
          "朝食の記録",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "完了",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),

            child: TextField(
              decoration: InputDecoration(
                hintText: "食品を検索",

                prefixIcon:
                    const Icon(Icons.search),

                filled: true,
                fillColor: Colors.grey.shade100,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // タブ
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green,
                    ),
                    child: const Text(
                      "よく食べる",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.grey.shade200,
                    ),
                    child: const Text(
                      "履歴",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.grey.shade200,
                    ),
                    child: const Text(
                      "Myメニュー",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: foods.length,

              itemBuilder:
                  (context, index) {
                final food =
                    foods[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.green.shade50,
                    child: Icon(
                      food["icon"],
                      color: Colors.green,
                    ),
                  ),

                  title: Text(
                    food["name"],
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle:
                      Text(food["amount"]),

                  trailing: Text(
                    "${food["calorie"]} kcal",
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(
                    0.05,
                  ),
                  blurRadius: 10,
                ),
              ],
            ),

            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: [
                    const Text(
                      "合計 ",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "$totalCalories",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const Text(
                      " kcal",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                          context);
                    },

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),

                    child: const Text(
                      "保存",
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
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
}
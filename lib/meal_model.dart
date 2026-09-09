import 'dart:convert';

class FoodItem {
  final String name;
  final String amount;
  final int calorie;
  final double protein;
  final double fat;
  final double carbs;
  final double vitamin;
  final double mineral;

  FoodItem({
    required this.name,
    required this.amount,
    required this.calorie,
    this.protein = 0.0,
    this.fat = 0.0,
    this.carbs = 0.0,
    this.vitamin = 0.0,
    this.mineral = 0.0,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] ?? '',
      amount: map['amount'] ?? '',
      calorie: map['calorie'] ?? 0,
      protein: (map['protein'] ?? 0.0).toDouble(),
      fat: (map['fat'] ?? 0.0).toDouble(),
      carbs: (map['carbs'] ?? 0.0).toDouble(),
      vitamin: (map['vitamin'] ?? 0.0).toDouble(),
      mineral: (map['mineral'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'calorie': calorie,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'vitamin': vitamin,
      'mineral': mineral,
    };
  }
}

class DailyMeal {
  final String date;
  final List<FoodItem> foods;

  DailyMeal({
    required this.date,
    required this.foods,
  });

  factory DailyMeal.fromJson(String source) {
    final Map<String, dynamic> map = json.decode(source);
    return DailyMeal(
      date: map['date'] ?? '',
      foods: List<FoodItem>.from(
        (map['foods'] as List<dynamic>).map(
          (x) => FoodItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() {
    final Map<String, dynamic> map = {
      'date': date,
      'foods': foods.map((x) => x.toMap()).toList(),
    };
    return json.encode(map);
  }
}

// ★追加：Myメニューモデル
class MyMenu {
  final String id;
  final String title;
  final List<FoodItem> foods;

  MyMenu({
    required this.id,
    required this.title,
    required this.foods,
  });

  factory MyMenu.fromMap(Map<String, dynamic> map) {
    return MyMenu(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      foods: List<FoodItem>.from(
        (map['foods'] as List<dynamic>).map(
          (x) => FoodItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'foods': foods.map((x) => x.toMap()).toList(),
    };
  }
}
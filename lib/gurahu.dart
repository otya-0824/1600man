import 'package:flutter/material.dart';
import 'home.dart';
import 'meal.dart';
import 'calendar.dart';
import 'mypage.dart';
import 'models/meal.dart';
import 'models/nutrition_target.dart';
import 'meal_storage_service.dart';
import 'services/nutrition_facade.dart';
import 'services/nutrition_feedback_service.dart';
import 'services/nutrient_group_service.dart';

/// グラフに表示する指標(上段=カロリー/ビタミン/ミネラル, 下段=P/F/C)。
/// 1日ぶんの実測値と目標値の取り出し方を、指標ごとにここへ集約する。
class _Metric {
  final String label;
  final String unit;

  /// 1日ぶんの実測値を取り出す(summary=その日の合計, micros=微量栄養素の内訳)。
  final double Function(DailySummary summary, Map<String, double> micros) value;

  /// 目標値(グラフ上の目標ライン)。ビタミン/ミネラルは達成率(%)表示のため100。
  final double target;

  const _Metric({
    required this.label,
    required this.unit,
    required this.value,
    required this.target,
  });
}

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  // 0: カロリー, 1: ビタミン, 2: ミネラル (-1は未選択)
  int _selectedUpperIndex = 0;
  // 0: タンパク質, 1: 脂質, 2: 炭水化物 (-1は未選択)
  int _selectedLowerIndex = -1;

  final DateTime _minDate = DateTime(2026, 8, 20);
  final DateTime _maxDate = DateTime(2090, 12, 31);
  
  late DateTime _currentMonday;

  // 表示中の週(月〜日)の実データ。ローカル記録から集計する。
  final NutritionFacade _facade = NutritionFacade();
  List<DailySummary> _weekSummaries = List.filled(7, const DailySummary());
  List<Map<String, double>> _weekMicros = List.filled(7, const {});
  NutritionTarget? _target;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    DateTime target = now.isBefore(_minDate)
        ? _minDate
        : (now.isAfter(_maxDate) ? _maxDate : now);
    _currentMonday = _getMondayOfWeek(target);
    _loadWeek();
  }

  // 表示中の週(月〜日)の合計・微量栄養素・目標を読み込む。
  Future<void> _loadWeek() async {
    setState(() => _loading = true);

    final target = await _facade.loadTargetOrDefault();
    final summaries = <DailySummary>[];
    final micros = <Map<String, double>>[];
    for (int i = 0; i < 7; i++) {
      final day = _currentMonday.add(Duration(days: i));
      summaries.add(await MealStorageService.getDailySummary(day));
      micros.add(await MealStorageService.getDailyMicros(day));
    }

    if (!mounted) return;
    setState(() {
      _target = target;
      _weekSummaries = summaries;
      _weekMicros = micros;
      _loading = false;
    });
  }

  // 現在選択中の指標を返す(上段が選択されていればそれ、なければ下段)。
  _Metric get _selectedMetric {
    final t = _target;
    switch (_selectedUpperIndex) {
      case 0:
        return _Metric(
          label: 'カロリー',
          unit: 'kcal',
          value: (s, m) => s.totalCalorie,
          target: t?.targetKcal ?? 0,
        );
      case 1:
        return _Metric(
          label: 'ビタミン',
          unit: '%',
          value: _vitaminRatio,
          target: 100,
        );
      case 2:
        return _Metric(
          label: 'ミネラル',
          unit: '%',
          value: _mineralRatio,
          target: 100,
        );
    }
    switch (_selectedLowerIndex) {
      case 0:
        return _Metric(
          label: 'タンパク質',
          unit: 'g',
          value: (s, m) => s.totalProtein,
          target: t?.targetProtein ?? 0,
        );
      case 1:
        return _Metric(
          label: '脂質',
          unit: 'g',
          value: (s, m) => s.totalFat,
          target: t?.targetFat ?? 0,
        );
      case 2:
        return _Metric(
          label: '炭水化物',
          unit: 'g',
          value: (s, m) => s.totalCarbo,
          target: t?.targetCarbohydrate ?? 0,
        );
    }
    // どちらも未選択(-1)になることは無いが、保険でカロリーを返す。
    return _Metric(
      label: 'カロリー',
      unit: 'kcal',
      value: (s, m) => s.totalCalorie,
      target: t?.targetKcal ?? 0,
    );
  }

  // ビタミン/ミネラルは項目別に単位が異なるため、目標に対する達成率(%)の平均で表す。
  double _vitaminRatio(DailySummary summary, Map<String, double> micros) =>
      _groupRatio(summary, micros, vitamin: true);

  double _mineralRatio(DailySummary summary, Map<String, double> micros) =>
      _groupRatio(summary, micros, vitamin: false);

  double _groupRatio(DailySummary summary, Map<String, double> micros,
      {required bool vitamin}) {
    final target = _target;
    if (target == null) return 0;
    final comparisons = NutritionFeedbackService().compare(
      target: target,
      actualKcal: summary.totalCalorie,
      actualProtein: summary.totalProtein,
      actualFat: summary.totalFat,
      actualCarbohydrate: summary.totalCarbo,
      actualFiber: micros['fiber'] ?? 0,
      actualSalt: micros['salt'] ?? 0,
      actualCholesterol: micros['cholesterol'] ?? 0,
      actualPotassium: micros['potassium'] ?? 0,
      actualCalcium: micros['calcium'] ?? 0,
      actualMagnesium: micros['magnesium'] ?? 0,
      actualPhosphorus: micros['phosphorus'] ?? 0,
      actualIron: micros['iron'] ?? 0,
      actualZinc: micros['zinc'] ?? 0,
      actualCopper: micros['copper'] ?? 0,
      actualVitaminA: micros['vitaminA'] ?? 0,
      actualVitaminD: micros['vitaminD'] ?? 0,
      actualVitaminE: micros['vitaminE'] ?? 0,
      actualVitaminK: micros['vitaminK'] ?? 0,
      actualVitaminB1: micros['vitaminB1'] ?? 0,
      actualVitaminB2: micros['vitaminB2'] ?? 0,
      actualNiacin: micros['niacin'] ?? 0,
      actualVitaminB6: micros['vitaminB6'] ?? 0,
      actualVitaminB12: micros['vitaminB12'] ?? 0,
      actualFolate: micros['folate'] ?? 0,
      actualPantothenicAcid: micros['pantothenicAcid'] ?? 0,
      actualVitaminC: micros['vitaminC'] ?? 0,
      actualBiotin: micros['biotin'] ?? 0,
    );
    final group = NutrientGroupService();
    final score = vitamin
        ? group.vitaminScore(comparisons)
        : group.mineralScore(comparisons);
    return (score?.averageRatio ?? 0) * 100;
  }

  DateTime _getMondayOfWeek(DateTime date) {
    int daysToSubtract = date.weekday - 1;
    return date.subtract(Duration(days: daysToSubtract));
  }

  void _nextWeek() {
    DateTime nextMonday = _currentMonday.add(const Duration(days: 7));
    if (nextMonday.isBefore(_maxDate) || nextMonday.isAtSameMomentAs(_maxDate)) {
      _currentMonday = nextMonday;
      _loadWeek();
    }
  }

  void _prevWeek() {
    DateTime prevMonday = _currentMonday.subtract(const Duration(days: 7));
    DateTime limitMonday = _getMondayOfWeek(_minDate);
    if (prevMonday.isAfter(limitMonday) || prevMonday.isAtSameMomentAs(limitMonday)) {
      _currentMonday = prevMonday;
    } else {
      _currentMonday = limitMonday;
    }
    _loadWeek();
  }

  String _formatDateRange() {
    DateTime sunday = _currentMonday.add(const Duration(days: 6));
    
    if (_currentMonday.year != sunday.year) {
      return '${_currentMonday.year}年${_currentMonday.month}/${_currentMonday.day}（月）〜 ${sunday.year}年${sunday.month}/${sunday.day}（日）';
    } else {
      return '${_currentMonday.year}年 ${_currentMonday.month}/${_currentMonday.day}（月）〜 ${sunday.month}/${sunday.day}（日）';
    }
  }

  String _getWeekDay(DateTime date) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    DateTime limitMonday = _getMondayOfWeek(_minDate);
    bool canGoPrev = _currentMonday.isAfter(limitMonday);
    bool canGoNext = _currentMonday.add(const Duration(days: 7)).isBefore(_maxDate);

    // ==========================================
    // 【実データから選択中の指標の系列を作る】
    // ==========================================
    final metric = _selectedMetric;
    // その週の7日分の値(月〜日)。ローカル記録から算出。
    final List<double> calorieData = List.generate(
      7,
      (i) => metric.value(_weekSummaries[i], _weekMicros[i]),
    );
    final double targetCalories = metric.target;
    // 平均は「記録がある日(値>0)」だけで計算する。記録なしの週は0。
    final recorded = calorieData.where((v) => v > 0).toList();
    final double averageCalories = recorded.isEmpty
        ? 0
        : recorded.reduce((a, b) => a + b) / recorded.length;

    // ==========================================
    // 【動的スケール計算】
    // ==========================================
    double maxDataValue = calorieData.isNotEmpty
        ? calorieData.reduce((curr, next) => curr > next ? curr : next)
        : 0.0;

    double baseMax = maxDataValue > targetCalories ? maxDataValue : targetCalories;
    // 目盛りの余白。データが極端に小さい場合でも0除算しないよう下限を設ける。
    double maxGraphValue = baseMax > 0 ? baseMax * 1.2 : 100.0;
    double topScaleValue = maxGraphValue;

    const Color primaryGreen = Color(0xFF66BB6A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          '栄養素グラフ',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // 上段タブ：カロリー / ビタミン / ミネラル
              Row(
                children: [
                  _buildTabButton('カロリー', 0, isUpper: true),
                  const SizedBox(width: 8),
                  _buildTabButton('ビタミン', 1, isUpper: true),
                  const SizedBox(width: 8),
                  _buildTabButton('ミネラル', 2, isUpper: true),
                ],
              ),
              const SizedBox(height: 8),
              // 下段タブ：タンパク質 / 脂質 / 炭水化物
              Row(
                children: [
                  _buildTabButton('タンパク質', 0, isUpper: false),
                  const SizedBox(width: 8),
                  _buildTabButton('脂質', 1, isUpper: false),
                  const SizedBox(width: 8),
                  _buildTabButton('炭水化物', 2, isUpper: false),
                ],
              ),
              const SizedBox(height: 16),

              // 期間切り替え
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: canGoPrev ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    onPressed: canGoPrev ? _prevWeek : null,
                  ),
                  Flexible(
                    child: Text(
                      _formatDateRange(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: canGoNext ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    onPressed: canGoNext ? _nextWeek : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 平均・目標のラベル
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text('平均', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(
                        '${averageCalories.toInt()} ${metric.unit}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  Column(
                    children: [
                      const Text('目標', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(
                        '${targetCalories.toInt()} ${metric.unit}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // グラフエリア
              Container(
                height: 250,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: _loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF66BB6A),
                              ),
                            )
                          : LayoutBuilder(
                        builder: (context, constraints) {
                          double chartHeight = constraints.maxHeight;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 左側の縦軸目盛り
                              SizedBox(
                                width: 45,
                                child: Stack(
                                  children: [
                                    Positioned(top: chartHeight * 0.0, right: 0, child: Text('${(topScaleValue * 1.0).toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey))),
                                    Positioned(top: chartHeight * 0.2, right: 0, child: Text('${(topScaleValue * 0.8).toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey))),
                                    Positioned(top: chartHeight * 0.4, right: 0, child: Text('${(topScaleValue * 0.6).toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey))),
                                    Positioned(top: chartHeight * 0.6, right: 0, child: Text('${(topScaleValue * 0.4).toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey))),
                                    Positioned(top: chartHeight * 0.8, right: 0, child: Text('${(topScaleValue * 0.2).toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey))),
                                    Positioned(bottom: 0, right: 0, child: const Text('0', style: TextStyle(fontSize: 10, color: Colors.grey))),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 右側のグラフ本体
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                  child: Stack(
                                    children: [
                                      // 背景の目盛り線（6本）
                                      ...List.generate(6, (index) {
                                        double ratio = index / 5;
                                        return Positioned(
                                          top: chartHeight * ratio,
                                          left: 0,
                                          right: 0,
                                          child: Divider(color: Colors.grey.shade200, height: 1),
                                        );
                                      }),
                                      
                                      // 目標ライン（黄色い横棒）
                                      Positioned(
                                        top: chartHeight * (1 - (targetCalories / topScaleValue)),
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 2,
                                          color: Colors.amber,
                                        ),
                                      ),

                                      // 棒グラフ部分
                                      Positioned.fill(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: calorieData.map((calories) {
                                              double ratio = calories / topScaleValue;
                                              double barHeight = chartHeight * ratio;
                                              return Container(
                                                width: 16,
                                                height: barHeight > 0 ? barHeight : 0,
                                                decoration: BoxDecoration(
                                                  color: primaryGreen,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 下部エリア
                    Row(
                      children: [
                        SizedBox(
                          width: 45,
                          child: Text(
                            '(${metric.unit})',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(7, (index) {
                              DateTime targetDate = _currentMonday.add(Duration(days: index));
                              DateTime now = DateTime.now();
                              bool isToday = targetDate.year == now.year &&
                                  targetDate.month == now.month &&
                                  targetDate.day == now.day;

                              return SizedBox(
                                width: 16,
                                child: Column(
                                  children: [
                                    Text(
                                      '${targetDate.day}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isToday ? primaryGreen : Colors.black87,
                                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      _getWeekDay(targetDate),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isToday ? primaryGreen : Colors.grey,
                                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) return;
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage()), // constを削除
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MealPage()),
              );
              break;
            case 2:
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

  Widget _buildTabButton(String text, int index, {required bool isUpper}) {
    bool isSelected = isUpper
        ? (_selectedUpperIndex == index)
        : (_selectedLowerIndex == index);
    const Color primaryGreen = Color(0xFF66BB6A);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isUpper) {
              _selectedUpperIndex = index;
              _selectedLowerIndex = -1;
            } else {
              _selectedLowerIndex = index;
              _selectedUpperIndex = -1;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? primaryGreen : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
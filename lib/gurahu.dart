import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _currentMonday = _getMondayOfWeek(DateTime(2026, 8, 20));
  }

  DateTime _getMondayOfWeek(DateTime date) {
    int daysToSubtract = date.weekday - 1;
    return date.subtract(Duration(days: daysToSubtract));
  }

  void _nextWeek() {
    setState(() {
      DateTime nextMonday = _currentMonday.add(const Duration(days: 7));
      if (nextMonday.isBefore(_maxDate) || nextMonday.isAtSameMomentAs(_maxDate)) {
        _currentMonday = nextMonday;
      }
    });
  }

  void _prevWeek() {
    setState(() {
      DateTime prevMonday = _currentMonday.subtract(const Duration(days: 7));
      DateTime limitMonday = _getMondayOfWeek(_minDate);
      if (prevMonday.isAfter(limitMonday) || prevMonday.isAtSameMomentAs(limitMonday)) {
        _currentMonday = prevMonday;
      } else {
        _currentMonday = limitMonday;
      }
    });
  }

  String _formatDateRange() {
    DateTime sunday = _currentMonday.add(const Duration(days: 6));
    return '${_currentMonday.month}/${_currentMonday.day} (月) 〜 ${sunday.month}/${sunday.day} (日)';
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
    // 【バックエンド連携用サンプルデータ】
    // ==========================================
    final List<double> calorieData = [1800, 2100, 1600, 2500, 1900, 2200, 1700];
    final double targetCalories = 1200.0; 
    final double averageCalories = 2028.0;

    // ==========================================
    // 【動的スケール計算】
    // ==========================================
    double maxDataValue = calorieData.isNotEmpty 
        ? calorieData.reduce((curr, next) => curr > next ? curr : next) 
        : 2000.0;
    
    double baseMax = maxDataValue > targetCalories ? maxDataValue : targetCalories;
    double maxGraphValue = baseMax + 500.0;
    double topScaleValue = maxGraphValue;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54, size: 18),
          onPressed: () {},
        ),
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
              // 下段タブ：タンパク質 / 脂質 / 炭水化物（五大栄養素のうち3つ）
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
                        '${averageCalories.toInt()} kcal',
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
                        '${targetCalories.toInt()} kcal', 
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
                      child: LayoutBuilder(
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
                                                color: const Color(0xFF66BB6A),
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
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 下部エリア：左側に単位 (kcal)、右側に日付・曜日を配置
                    Row(
                      children: [
                        const SizedBox(
                          width: 45,
                          child: Text(
                            '(kcal)',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(7, (index) {
                              DateTime targetDate = _currentMonday.add(Duration(days: index));
                              return _DayLabel(
                                day: '${targetDate.day}',
                                weekDay: _getWeekDay(targetDate),
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
              _selectedLowerIndex = -1; // 上段が押されたら下段の選択を解除
            } else {
              _selectedLowerIndex = index;
              _selectedUpperIndex = -1; // 下段が押されたら上段の選択を解除
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

class _DayLabel extends StatelessWidget {
  final String day;
  final String weekDay;

  const _DayLabel({required this.day, required this.weekDay});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day, style: const TextStyle(fontSize: 11, color: Colors.black87)),
        Text(weekDay, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'home.dart';
import 'meal.dart';
import 'calendar.dart';
import 'mypage.dart';

class GraphScreen extends StatefulWidget {
  final bool isDarkMode; // ← ダークモードの状態を受け取る変数

  const GraphScreen({
    super.key,
    this.isDarkMode = false, // デフォルトはライトモード
  });

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
    DateTime now = DateTime.now();
    DateTime target = now.isBefore(_minDate) 
        ? _minDate 
        : (now.isAfter(_maxDate) ? _maxDate : now);
    _currentMonday = _getMondayOfWeek(target);
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

    final List<double> calorieData = [1800, 2100, 1600, 2500, 1900, 2200, 1700];
    final double targetCalories = 1200.0; 
    final double averageCalories = 2028.0;

    double maxDataValue = calorieData.isNotEmpty 
        ? calorieData.reduce((curr, next) => curr > next ? curr : next) 
        : 2000.0;
    
    double baseMax = maxDataValue > targetCalories ? maxDataValue : targetCalories;
    double maxGraphValue = baseMax + 500.0;
    double topScaleValue = maxGraphValue;

    const Color primaryGreen = Color(0xFF66BB6A);
    // 受け取った widget.isDarkMode の状態を使用
    final bool isDarkMode = widget.isDarkMode;
    
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          '栄養素グラフ',
          style: TextStyle(
            color: textColor,
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
              // 上段タブ
              Row(
                children: [
                  _buildTabButton('カロリー', 0, isUpper: true, isDarkMode: isDarkMode),
                  const SizedBox(width: 8),
                  _buildTabButton('ビタミン', 1, isUpper: true, isDarkMode: isDarkMode),
                  const SizedBox(width: 8),
                  _buildTabButton('ミネラル', 2, isUpper: true, isDarkMode: isDarkMode),
                ],
              ),
              const SizedBox(height: 8),
              // 下段タブ
              Row(
                children: [
                  _buildTabButton('タンパク質', 0, isUpper: false, isDarkMode: isDarkMode),
                  const SizedBox(width: 8),
                  _buildTabButton('脂質', 1, isUpper: false, isDarkMode: isDarkMode),
                  const SizedBox(width: 8),
                  _buildTabButton('炭水化物', 2, isUpper: false, isDarkMode: isDarkMode),
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
                      color: canGoPrev ? (isDarkMode ? Colors.white70 : Colors.grey.shade700) : Colors.grey.shade600,
                    ),
                    onPressed: canGoPrev ? _prevWeek : null,
                  ),
                  Flexible(
                    child: Text(
                      _formatDateRange(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: canGoNext ? (isDarkMode ? Colors.white70 : Colors.grey.shade700) : Colors.grey.shade600,
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                  Column(
                    children: [
                      const Text('目標', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(
                        '${targetCalories.toInt()} kcal', 
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
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
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                  child: Stack(
                                    children: [
                                      // 背景の目盛り線
                                      ...List.generate(6, (index) {
                                        double ratio = index / 5;
                                        return Positioned(
                                          top: chartHeight * ratio,
                                          left: 0,
                                          right: 0,
                                          child: Divider(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200, height: 1),
                                        );
                                      }),
                                      
                                      // 目標ライン
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
                    // 下部エリア：単位と日付
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
                                        color: isToday ? primaryGreen : textColor,
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
        backgroundColor: backgroundColor,
        onTap: (index) {
          if (index == 2) return;
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage(isDarkMode: widget.isDarkMode)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MealPage(isDarkMode: widget.isDarkMode)),
              );
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => CalendarScreen(isDarkMode: widget.isDarkMode)),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MypageScreen(isDarkMode: widget.isDarkMode)),
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

  Widget _buildTabButton(String text, int index, {required bool isUpper, required bool isDarkMode}) {
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
            color: isSelected 
                ? primaryGreen 
                : (isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected 
                  ? primaryGreen 
                  : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white 
                  : (isDarkMode ? Colors.white70 : Colors.black87),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
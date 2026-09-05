import 'package:flutter/material.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  int _selectedCategoryIndex = 0;
  int _selectedPeriodIndex = 0;

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
              // 1段目タブ：カロリー / PFC / 栄養素
              Row(
                children: [
                  _buildTabButton('カロリー', 0, isCategory: true),
                  const SizedBox(width: 8),
                  _buildTabButton('PFC', 1, isCategory: true),
                  const SizedBox(width: 8),
                  _buildTabButton('栄養素', 2, isCategory: true),
                ],
              ),
              const SizedBox(height: 8),
              // 2段目タブ：1日 / 1週間 / 1ヶ月
              Row(
                children: [
                  _buildTabButton('1日', 0, isCategory: false),
                  const SizedBox(width: 8),
                  _buildTabButton('1週間', 1, isCategory: false),
                  const SizedBox(width: 8),
                  _buildTabButton('1ヶ月', 2, isCategory: false),
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
                    children: const [
                      Text('平均', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      SizedBox(height: 2),
                      Text(
                        '-- kcal',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black45,
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
                    children: const [
                      Text('目標', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      SizedBox(height: 2),
                      Text(
                        '-- kcal',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // グラフエリア
              Container(
                height: 240,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('(kcal)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text('2,500', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text('2,000', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text('1,500', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text('1,000', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text('500', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text('0', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    6,
                                    (index) => Divider(color: Colors.grey.shade200, height: 1),
                                  ),
                                ),
                                const Center(
                                  child: Text(
                                    '（ここに後からグラフを追加）',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(7, (index) {
                              DateTime targetDate = _currentMonday.add(Duration(days: index));
                              return _DayLabel(
                                day: '${targetDate.day}',
                                weekDay: _getWeekDay(targetDate),
                              );
                            }),
                          ),
                        ],
                      ),
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

  Widget _buildTabButton(String text, int index, {required bool isCategory}) {
    bool isSelected = isCategory
        ? (_selectedCategoryIndex == index)
        : (_selectedPeriodIndex == index);
    const Color primaryGreen = Color(0xFF66BB6A);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isCategory) {
              _selectedCategoryIndex = index;
            } else {
              _selectedPeriodIndex = index;
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
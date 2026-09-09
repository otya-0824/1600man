import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '栄養素詳細アプリ',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const GraphScreen(),
    );
  }
}

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  int _selectedPeriodIndex = 0; // 0: 1日, 1: 1週間, 2: 1ヶ月

  final DateTime _minDate = DateTime(2026, 8, 21);
  final DateTime _maxDate = DateTime(2090, 12, 31);
  
  late DateTime _currentDate;

  // 目標値（分母）も最初はすべて 0
  final int _targetEnergy = 0;
  final int _targetProtein = 0;
  final int _targetFat = 0;
  final int _targetCarb = 0;
  final int _targetFiber = 0;
  final double _targetSalt = 0.0;
  final int _targetCalcium = 0;
  final int _targetIron = 0;
  final int _targetVitaminC = 0;

  @override
  void initState() {
    super.initState();
    _currentDate = _minDate; // 初期値は2026年8月21日
  }

  // 1日進める
  void _nextDay() {
    setState(() {
      DateTime next = _currentDate.add(const Duration(days: 1));
      if (next.isBefore(_maxDate) || next.isAtSameMomentAs(_maxDate)) {
        _currentDate = next;
      }
    });
  }

  // 1日戻る
  void _prevDay() {
    setState(() {
      DateTime prev = _currentDate.subtract(const Duration(days: 1));
      if (prev.isAfter(_minDate) || prev.isAtSameMomentAs(_minDate)) {
        _currentDate = prev;
      }
    });
  }

  String _formatDate(DateTime date) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    String weekday = weekdays[date.weekday - 1];
    return '${date.year}年${date.month}月${date.day}日 ($weekday)';
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF66BB6A);
    const Color orangeColor = Color(0xFFFFA726);

    bool canGoPrev = _currentDate.isAfter(_minDate);
    bool canGoNext = _currentDate.add(const Duration(days: 1)).isBefore(_maxDate) ||
        _currentDate.isAtSameMomentAs(_minDate);

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
          '栄養素詳細',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // 期間タブ（1日 / 1週間 / 1ヶ月）
              Row(
                children: [
                  _buildPeriodTab('1日', 0),
                  const SizedBox(width: 8),
                  _buildPeriodTab('1週間', 1),
                  const SizedBox(width: 8),
                  _buildPeriodTab('1ヶ月', 2),
                ],
              ),
              const SizedBox(height: 16),

              // 日付切り替え
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: canGoPrev ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    onPressed: canGoPrev ? _prevDay : null,
                  ),
                  Flexible(
                    child: Text(
                      _formatDate(_currentDate),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
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
                    onPressed: canGoNext ? _nextDay : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // カロリー表示セクション（分母も0）
              const Text(
                'エネルギー',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0 / $_targetEnergy kcal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // 各種栄養素リスト（分母もすべて0）
              _buildNutrientRow('たんぱく質', '0 / $_targetProtein g', 0.0, primaryGreen),
              _buildNutrientRow('脂質', '0 / $_targetFat g', 0.0, primaryGreen),
              _buildNutrientRow('炭水化物', '0 / $_targetCarb g', 0.0, orangeColor),
              _buildNutrientRow('食物繊維', '0 / $_targetFiber g', 0.0, primaryGreen),
              _buildNutrientRow('塩分', '0 / $_targetSalt g', 0.0, primaryGreen),
              _buildNutrientRow('カルシウム', '0 / $_targetCalcium mg', 0.0, primaryGreen),
              _buildNutrientRow('鉄', '0 / $_targetIron mg', 0.0, primaryGreen),
              _buildNutrientRow('ビタミンC', '0 / $_targetVitaminC mg', 0.0, primaryGreen),

              const SizedBox(height: 24),

              // 凡例
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _LegendItem(color: Colors.blueAccent, label: '不足'),
                  SizedBox(width: 16),
                  _LegendItem(color: primaryGreen, label: '適正'),
                  SizedBox(width: 16),
                  _LegendItem(color: Colors.redAccent, label: '過剰'),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: '記録'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'グラフ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String text, int index) {
    bool isSelected = (_selectedPeriodIndex == index);
    const Color primaryGreen = Color(0xFF66BB6A);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriodIndex = index;
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

  Widget _buildNutrientRow(String title, String valueText, double progress, Color barColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 95,
                  child: Text(
                    valueText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
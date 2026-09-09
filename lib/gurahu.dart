import 'dart:math';
import 'package:flutter/material.dart';
import 'meal.dart';
import 'home.dart';
import 'calendar.dart';
import 'mypage.dart';
import 'models/meal.dart';
import 'models/nutrition_target.dart';
import 'meal_storage_service.dart';
import 'services/nutrition_facade.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  int _selectedCategoryIndex = 0; // 0:カロリー 1:PFC 2:栄養素
  int _selectedPeriodIndex = 1; // 0:1日 1:1週間 2:1ヶ月

  final DateTime _minDate = DateTime(2026, 8, 20);
  final DateTime _maxDate = DateTime(2090, 12, 31);

  late DateTime _currentMonday;

  final NutritionFacade _facade = NutritionFacade();

  // 取得済みの日次サマリー（キーは "2026-08-30" 形式）と目標値
  Map<String, DailySummary> _summaries = {};
  NutritionTarget? _target;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentMonday = _getMondayOfWeek(DateTime(2026, 8, 20));
    _loadData();
  }

  DateTime _getMondayOfWeek(DateTime date) {
    int daysToSubtract = date.weekday - 1;
    return date.subtract(Duration(days: daysToSubtract));
  }

  // 選択中の期間に応じて、グラフに並べる対象日リストを作る
  List<DateTime> _targetDays() {
    switch (_selectedPeriodIndex) {
      case 0: // 1日：今日のみ
        final now = DateTime.now();
        return [DateTime(now.year, now.month, now.day)];
      case 2: // 1ヶ月：今月の全日
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        return List.generate(
          daysInMonth,
          (i) => DateTime(now.year, now.month, i + 1),
        );
      default: // 1週間：表示中の週（月〜日）
        return List.generate(
          7,
          (i) => _currentMonday.add(Duration(days: i)),
        );
    }
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final days = _targetDays();
    final summaries =
        await MealStorageService.getSummariesInRange(days.first, days.last);
    final target = await _facade.loadTarget();
    if (!mounted) return;
    setState(() {
      _summaries = summaries;
      _target = target;
      _loading = false;
    });
  }

  void _nextWeek() {
    final nextMonday = _currentMonday.add(const Duration(days: 7));
    if (nextMonday.isBefore(_maxDate) ||
        nextMonday.isAtSameMomentAs(_maxDate)) {
      setState(() => _currentMonday = nextMonday);
      _loadData();
    }
  }

  void _prevWeek() {
    final prevMonday = _currentMonday.subtract(const Duration(days: 7));
    final limitMonday = _getMondayOfWeek(_minDate);
    setState(() {
      _currentMonday = (prevMonday.isAfter(limitMonday) ||
              prevMonday.isAtSameMomentAs(limitMonday))
          ? prevMonday
          : limitMonday;
    });
    _loadData();
  }

  String _formatDateRange() {
    final sunday = _currentMonday.add(const Duration(days: 6));
    return '${_currentMonday.month}/${_currentMonday.day} (月) 〜 ${sunday.month}/${sunday.day} (日)';
  }

  String _getWeekDay(DateTime date) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[date.weekday - 1];
  }

  // 選択カテゴリに応じて、その日の値を取り出す
  double _valueOf(DailySummary s) {
    switch (_selectedCategoryIndex) {
      case 1: // PFC（P+F+Cのグラム合計）
        return s.totalProtein + s.totalFat + s.totalCarbo;
      case 2: // 栄養素（ビタミン+ミネラルのmg合計）
        return s.totalVitamin + s.totalMineral;
      default: // カロリー
        return s.totalCalorie;
    }
  }

  // 選択カテゴリの目標値（栄養素は目標を持たないため null）
  double? _targetValue() {
    final t = _target;
    if (t == null) return null;
    switch (_selectedCategoryIndex) {
      case 1:
        return t.targetProtein + t.targetFat + t.targetCarbohydrate;
      case 2:
        return null;
      default:
        return t.targetKcal;
    }
  }

  String _unit() {
    switch (_selectedCategoryIndex) {
      case 1:
      case 2:
        return 'g';
      default:
        return 'kcal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final limitMonday = _getMondayOfWeek(_minDate);
    final canGoPrev = _currentMonday.isAfter(limitMonday);
    final canGoNext =
        _currentMonday.add(const Duration(days: 7)).isBefore(_maxDate);
    const Color primaryGreen = Color(0xFF66BB6A);
    final bool showWeekNav = _selectedPeriodIndex == 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54, size: 18),
          onPressed: () => Navigator.pop(context),
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

              if (showWeekNav)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: canGoPrev
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
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
                        color: canGoNext
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                      onPressed: canGoNext ? _nextWeek : null,
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              _buildAverageAndTarget(),
              const SizedBox(height: 16),

              _buildChart(primaryGreen),
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
                MaterialPageRoute(builder: (_) => HomePage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MealPage()),
              );
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
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
      ),
    );
  }

  // 平均・目標の数値表示
  Widget _buildAverageAndTarget() {
    final days = _targetDays();
    final values = days
        .map((d) => _valueOf(_summaries[MealStorageService.dateStr(d)] ??
            const DailySummary()))
        .toList();
    final recorded = values.where((v) => v > 0).toList();
    final avg = recorded.isEmpty
        ? 0.0
        : recorded.reduce((a, b) => a + b) / recorded.length;
    final target = _targetValue();
    final unit = _unit();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text('平均', style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(
              recorded.isEmpty ? '-- $unit' : '${avg.round()} $unit',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Container(height: 24, width: 1, color: Colors.grey.shade300),
        Column(
          children: [
            const Text('目標', style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(
              target == null ? '-- $unit' : '${target.round()} $unit',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 日次バーチャート本体
  Widget _buildChart(Color primaryGreen) {
    final days = _targetDays();
    final values = days
        .map((d) => _valueOf(_summaries[MealStorageService.dateStr(d)] ??
            const DailySummary()))
        .toList();
    final target = _targetValue();

    // 天井（バーの最大高さの基準）。目標とデータ最大の大きい方を使う。
    double maxV = 0;
    for (final v in values) {
      maxV = max(maxV, v);
    }
    if (target != null) maxV = max(maxV, target);
    if (maxV <= 0) maxV = 1; // 全て0のときの保険

    const double chartHeight = 180;
    final unit = _unit();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: _loading
          ? const SizedBox(
              height: chartHeight + 40,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '($unit)',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
                SizedBox(
                  height: chartHeight,
                  child: Stack(
                    children: [
                      // 目標ライン（点線代わりの細い線）
                      if (target != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: chartHeight * (target / maxV),
                          child: Container(
                            height: 1.5,
                            color: Colors.orange.withValues(alpha: 0.7),
                          ),
                        ),
                      // バー
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(days.length, (i) {
                            final v = values[i];
                            final barHeight = chartHeight * (v / maxV);
                            final reached =
                                target != null && v >= target && target > 0;
                            return Container(
                              width: days.length > 10 ? 14 : 36,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (v > 0)
                                    Text(
                                      '${v.round()}',
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  Container(
                                    height: barHeight < 2 && v > 0
                                        ? 2
                                        : barHeight,
                                    decoration: BoxDecoration(
                                      color: reached
                                          ? primaryGreen
                                          : primaryGreen.withValues(alpha: 0.55),
                                      borderRadius:
                                          const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
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
                ),
                const SizedBox(height: 6),
                // 日付ラベル
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(days.length, (i) {
                      final d = days[i];
                      final wide = days.length <= 10;
                      return Container(
                        width: days.length > 10 ? 20 : 42,
                        alignment: Alignment.center,
                        child: wide
                            ? _DayLabel(day: '${d.day}', weekDay: _getWeekDay(d))
                            : Text(
                                // 1ヶ月表示は5日ごとに数字を出す
                                (d.day == 1 || d.day % 5 == 0) ? '${d.day}' : '',
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.grey),
                              ),
                      );
                    }),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabButton(String text, int index, {required bool isCategory}) {
    final bool isSelected = isCategory
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
          // 期間を変えたらデータを取り直す
          if (!isCategory) _loadData();
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

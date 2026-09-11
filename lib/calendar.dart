import 'package:flutter/material.dart';
import 'home.dart';
import 'meal.dart';
import 'gurahu.dart';
import 'mypage.dart';
import 'meal_storage_service.dart';
import 'services/nutrition_facade.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // 2026年8月スタート
  int _currentYear = 2026;
  int _currentMonth = 8;

  // 日付ごとの達成状況。キーは "yyyy-MM-dd"（MealStorageService.dateStr と同形式）。
  //   'success' -> 緑（達成） / 'warning' -> 黄（やや不足）
  //   'danger'  -> 赤（不足） / 未登録 -> 丸を表示しない
  // ホーム画面と同じ MealStorageService（ローカルの食事記録）から算出する。
  final Map<String, String> _dailyStatusMap = {};
  final NutritionFacade _facade = NutritionFacade();

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  // 表示中の月の食事記録（ローカル）と目標カロリーから日ごとの達成度を算出する。
  Future<void> _loadStatuses() async {
    final first = DateTime(_currentYear, _currentMonth, 1);
    final last = DateTime(_currentYear, _currentMonth + 1, 0);

    // 目標カロリー。プロフィール未整備で取得できない場合はグラフ画面と同じ 1200 を使う。
    final target = await _facade.loadTarget();
    final targetKcal =
        (target != null && target.targetKcal > 0) ? target.targetKcal : 1200.0;

    final summaries = await MealStorageService.getSummariesInRange(first, last);

    final map = <String, String>{};
    summaries.forEach((dateKey, summary) {
      final status = _statusFor(summary.totalCalorie, targetKcal);
      if (status != null) map[dateKey] = status;
    });

    if (!mounted) return;
    setState(() {
      _dailyStatusMap
        ..clear()
        ..addAll(map);
    });
  }

  // カロリーの達成率でステータスを決める。
  //   90%以上=達成 / 70〜90%=やや不足 / 70%未満=不足 / 記録なし=null
  String? _statusFor(double totalCalorie, double targetKcal) {
    if (totalCalorie <= 0) return null; // その日の記録が無ければドットなし
    final ratio = totalCalorie / targetKcal;
    if (ratio >= 0.9) return 'success';
    if (ratio >= 0.7) return 'warning';
    return 'danger';
  }

  // 月を前後に移動する処理（2026年8月 〜 2090年12月）
  void _changeMonth(int offset) {
    setState(() {
      int newMonth = _currentMonth + offset;
      int newYear = _currentYear;

      if (newMonth > 12) {
        newMonth = 1;
        newYear++;
      } else if (newMonth < 1) {
        newMonth = 12;
        newYear--;
      }

      if (newYear > 2090 || (newYear == 2090 && newMonth > 12)) return;
      if (newYear < 2026 || (newYear == 2026 && newMonth < 8)) return;

      _currentYear = newYear;
      _currentMonth = newMonth;
    });

    // 切り替えた月の実データで達成度を再計算する。
    _loadStatuses();
  }

  // ステータス文字列から対応する色を返すヘルパー関数
  Color? _getStatusColor(String? status) {
    switch (status) {
      case 'success':
        return const Color(0xFF66BB6A); // 緑（達成）
      case 'warning':
        return const Color(0xFFFFCA28); // 黄（やや不足）
      case 'danger':
        return const Color(0xFFEF5350); // 赤（不足）
      default:
        return null; // ステータスがない場合は色を返さない
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF66BB6A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'カレンダー',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 5),
          // 年月の切り替え部分
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.grey),
                onPressed: (_currentYear == 2026 && _currentMonth == 8)
                    ? null
                    : () => _changeMonth(-1),
              ),
              Text(
                '$_currentYear年$_currentMonth月',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.grey),
                onPressed: (_currentYear == 2090 && _currentMonth == 12)
                    ? null
                    : () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // カレンダー本体を包むカード
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 曜日ヘッダー
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _WeekDayLabel(text: '月'),
                        _WeekDayLabel(text: '火'),
                        _WeekDayLabel(text: '水'),
                        _WeekDayLabel(text: '木'),
                        _WeekDayLabel(text: '金'),
                        _WeekDayLabel(text: '土'),
                        _WeekDayLabel(text: '日'),
                      ],
                    ),
                  ),

                  // 日付グリッド
                  _buildCalendarGrid(_currentYear, _currentMonth),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 達成状況の凡例
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LegendItem(color: Color(0xFF66BB6A), label: '達成'),
              SizedBox(width: 20),
              _LegendItem(color: Color(0xFFFFCA28), label: 'やや不足'),
              SizedBox(width: 20),
              _LegendItem(color: Color(0xFFEF5350), label: '不足'),
            ],
          ),
        ],
      ),

      // ボトムナビゲーションバーを追加
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // カレンダーをアクティブ表示（0:ホーム, 1:記録, 2:グラフ, 3:カレンダー, 4:マイページ）
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 3) return; // すでにカレンダーにいる場合は何もしない
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
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const GraphScreen()),
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

  // 枠線付きのカレンダーグリッドを生成
  Widget _buildCalendarGrid(int year, int month) {
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    int weekdayOfFirstDay = firstDayOfMonth.weekday; // 月=1, 日=7
    int daysInMonth = DateTime(year, month + 1, 0).day;

    int leadingSpaces = weekdayOfFirstDay - 1;
    int totalCells = leadingSpaces + daysInMonth;
    int totalRows = (totalCells / 7).ceil();

    // 今日の日付を取得
    DateTime now = DateTime.now();

    return Column(
      children: List.generate(totalRows, (row) {
        return Row(
          children: List.generate(7, (col) {
            int index = row * 7 + col;
            int day = index - leadingSpaces + 1;

            bool isEffectiveDay = index >= leadingSpaces && day <= daysInMonth;

            // 各有効な日付のステータスを取得（キーは MealStorageService と同形式）
            String? status;
            if (isEffectiveDay) {
              final dateKey =
                  MealStorageService.dateStr(DateTime(year, month, day));
              status = _dailyStatusMap[dateKey];
            }
            Color? dotColor = _getStatusColor(status);

            // 今日かどうかを判定
            bool isToday = isEffectiveDay &&
                now.year == year &&
                now.month == month &&
                now.day == day;

            const Color primaryGreen = Color(0xFF66BB6A);

            return Expanded(
              child: Container(
                height: 60, 
                padding: const EdgeInsets.only(top: 6),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  border: Border(
                    right: col < 6
                        ? BorderSide(color: Colors.grey.shade300, width: 0.5)
                        : BorderSide.none,
                    bottom: row < totalRows - 1
                        ? BorderSide(color: Colors.grey.shade300, width: 0.5)
                        : BorderSide.none,
                  ),
                ),
                child: isEffectiveDay
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isToday ? primaryGreen : Colors.transparent,
                            ),
                            child: Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 14,
                                color: isToday ? Colors.white : Colors.black87,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4), 
                          // 日付ごとのステータスドット（色が存在する場合のみ表示）
                          SizedBox(
                            height: 6,
                            child: dotColor != null
                                ? Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: dotColor,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            );
          }),
        );
      }),
    );
  }
}

// 曜日の文字を表示する部品
class _WeekDayLabel extends StatelessWidget {
  final String text;
  const _WeekDayLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }
}

// カレンダー下の凡例を作る部品
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
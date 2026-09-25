import 'package:flutter/material.dart';
import 'home.dart';
import 'meal.dart';
import 'gurahu.dart';
import 'mypage.dart';

class CalendarScreen extends StatefulWidget {
  final bool isDarkMode; // ← ダークモードの状態を受け取る変数

  const CalendarScreen({
    super.key,
    this.isDarkMode = false, // デフォルトはライトモード
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _currentYear;
  late int _currentMonth;

  @override
  void initState() {
    super.initState();
    // 開いたときの実際の現在日時を取得し、初期表示に設定する
    DateTime now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;

    // アプリの許可範囲（2026年8月 〜 2090年12月）に収まるようクランプ処理
    if (_currentYear < 2026 || (_currentYear == 2026 && _currentMonth < 8)) {
      _currentYear = 2026;
      _currentMonth = 8;
    } else if (_currentYear > 2090 || (_currentYear == 2090 && _currentMonth > 12)) {
      _currentYear = 2090;
      _currentMonth = 12;
    }
  }

  final Map<String, String> _backendDailyStatusMap = {
    "2026-8-1": 'success',
    "2026-8-2": 'warning',
    "2026-8-3": 'danger',
    "2026-8-17": 'success', 
    "2026-8-18": 'warning', 
    "2026-8-19": 'danger',  
  };

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
        return null; 
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF66BB6A);
    // 受け取った widget.isDarkMode の状態を使用
    final bool isDarkMode = widget.isDarkMode;

    // モードに応じた背景色・文字色・枠線色を定義
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color borderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final Color headerBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'カレンダー',
          style: TextStyle(
            color: textColor,
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
                icon: Icon(Icons.chevron_left, color: isDarkMode ? Colors.white54 : Colors.grey),
                onPressed: (_currentYear == 2026 && _currentMonth == 8)
                    ? null
                    : () => _changeMonth(-1),
              ),
              Text(
                '$_currentYear年$_currentMonth月',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: isDarkMode ? Colors.white54 : Colors.grey),
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
                color: backgroundColor,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 曜日ヘッダー
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: headerBgColor,
                      border: Border(
                        bottom: BorderSide(color: borderColor),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _WeekDayLabel(text: '月', isDarkMode: isDarkMode),
                        _WeekDayLabel(text: '火', isDarkMode: isDarkMode),
                        _WeekDayLabel(text: '水', isDarkMode: isDarkMode),
                        _WeekDayLabel(text: '木', isDarkMode: isDarkMode),
                        _WeekDayLabel(text: '金', isDarkMode: isDarkMode),
                        _WeekDayLabel(text: '土', isDarkMode: isDarkMode),
                        _WeekDayLabel(text: '日', isDarkMode: isDarkMode),
                      ],
                    ),
                  ),

                  // 日付グリッド
                  _buildCalendarGrid(_currentYear, _currentMonth, isDarkMode, borderColor, textColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 達成状況の凡例
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: const Color(0xFF66BB6A), label: '達成', textColor: textColor),
              const SizedBox(width: 20),
              _LegendItem(color: const Color(0xFFFFCA28), label: 'やや不足', textColor: textColor),
              const SizedBox(width: 20),
              _LegendItem(color: const Color(0xFFEF5350), label: '不足', textColor: textColor),
            ],
          ),
        ],
      ),

      // ボトムナビゲーションバー
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, 
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        backgroundColor: backgroundColor,
        onTap: (index) {
          if (index == 3) return; 
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => GraphScreen(isDarkMode: widget.isDarkMode)),
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

  // 枠線付きのカレンダーグリッドを生成
  Widget _buildCalendarGrid(int year, int month, bool isDarkMode, Color borderColor, Color textColor) {
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    int weekdayOfFirstDay = firstDayOfMonth.weekday; // 月=1, 日=7
    int daysInMonth = DateTime(year, month + 1, 0).day;

    int leadingSpaces = weekdayOfFirstDay - 1;
    int totalCells = leadingSpaces + daysInMonth;
    int totalRows = (totalCells / 7).ceil();

    DateTime now = DateTime.now();

    return Column(
      children: List.generate(totalRows, (row) {
        return Row(
          children: List.generate(7, (col) {
            int index = row * 7 + col;
            int day = index - leadingSpaces + 1;

            bool isEffectiveDay = index >= leadingSpaces && day <= daysInMonth;

            String dateKey = "$year-$month-$day";
            String? status = isEffectiveDay ? _backendDailyStatusMap[dateKey] : null;
            Color? dotColor = _getStatusColor(status);

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
                        ? BorderSide(color: borderColor, width: 0.5)
                        : BorderSide.none,
                    bottom: row < totalRows - 1
                        ? BorderSide(color: borderColor, width: 0.5)
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
                                color: isToday ? Colors.white : textColor,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4), 
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
  final bool isDarkMode;
  const _WeekDayLabel({required this.text, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white60 : Colors.black54,
      ),
    );
  }
}

// カレンダー下の凡例を作る部品
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Color textColor;

  const _LegendItem({required this.color, required this.label, required this.textColor});

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
          style: TextStyle(
            fontSize: 13,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
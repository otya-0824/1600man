import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // 2026年8月スタート
  int _currentYear = 2026;
  int _currentMonth = 8;

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

  @override
  Widget build(BuildContext context) {
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
    );
  }

  // 枠線付きのカレンダーグリッドを生成（高さを広げて余白を確保）
  Widget _buildCalendarGrid(int year, int month) {
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    int weekdayOfFirstDay = firstDayOfMonth.weekday; // 月=1, 日=7
    int daysInMonth = DateTime(year, month + 1, 0).day;

    int leadingSpaces = weekdayOfFirstDay - 1;
    int totalCells = leadingSpaces + daysInMonth;
    int totalRows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(totalRows, (row) {
        return Row(
          children: List.generate(7, (col) {
            int index = row * 7 + col;
            int day = index - leadingSpaces + 1;

            bool isEffectiveDay = index >= leadingSpaces && day <= daysInMonth;

            return Expanded(
              child: Container(
                height: 60, // ★マスの高さを 44 から 60 に広げて、数字の下にマークが入る余白を作成
                padding: const EdgeInsets.only(top: 6), // 上からの余白
                alignment: Alignment.topCenter, // 数字を上に配置し、下にスペースを作る
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
                          Text(
                            '$day',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // const SizedBox(height: 4), 
                          // ↑ ここに後ほどマーク（赤丸や緑丸）のウィジェットを追加できます！
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
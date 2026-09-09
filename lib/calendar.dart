import 'package:flutter/material.dart';
import 'meal.dart';
import 'gurahu.dart';
import 'home.dart';
import 'mypage.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _currentYear = 2026;
  int _currentMonth = 8;

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
                  _buildCalendarGrid(_currentYear, _currentMonth),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 3) return;
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
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
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(int year, int month) {
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    int weekdayOfFirstDay = firstDayOfMonth.weekday;
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
                          Text(
                            '$day',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
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
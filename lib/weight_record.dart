import 'package:flutter/material.dart';

import 'meal_storage_service.dart';
import 'models/user_profile.dart';
import 'services/profile_service.dart';
import 'services/goal_duration_service.dart';
import 'utils/app_exceptions.dart';

// =====================================================================
// 体重の記録画面
// 今日の体重を記録し、履歴と「目標体重までの目安期間」を表示する。
// =====================================================================
class WeightRecordScreen extends StatefulWidget {
  const WeightRecordScreen({super.key});

  @override
  State<WeightRecordScreen> createState() => _WeightRecordScreenState();
}

class _WeightRecordScreenState extends State<WeightRecordScreen> {
  static const Color _green = Color(0xFF66BB6A);

  final ProfileService _profileService = ProfileService();
  final TextEditingController _weightController = TextEditingController();

  UserProfile? _profile;
  Map<String, double> _records = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await _profileService.loadProfile();
    final records = await MealStorageService.getWeightRecords();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _records = records;
      _loading = false;
    });
  }

  // 現在体重：記録があれば最新、無ければプロフィールの体重。
  double? get _currentWeight {
    if (_records.isNotEmpty) {
      final keys = _records.keys.toList()..sort();
      return _records[keys.last];
    }
    return _profile?.weightKg;
  }

  Future<void> _record() async {
    final kg = double.tryParse(_weightController.text);
    if (kg == null || kg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('体重を正しく入力してください')),
      );
      return;
    }
    await MealStorageService.saveWeight(DateTime.now(), kg);
    _weightController.clear();
    FocusScope.of(context).unfocus();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('体重を記録しました')),
    );
  }

  // 目標体重までの目安（週数）。維持や方向矛盾などは説明テキストを返す。
  String _goalMessage() {
    final profile = _profile;
    final current = _currentWeight;
    final goalWeight = profile?.goalWeightKg;
    if (profile == null || current == null || goalWeight == null) {
      return '目標体重が未設定です';
    }
    try {
      final est = GoalDurationService().estimate(
        profile: profile,
        currentWeightKg: current,
        goalWeightKg: goalWeight,
      );
      if (est == null) {
        return '目標体重に到達しています 🎉';
      }
      final weeks = est.weeksToGoal.ceil();
      return '目標体重まで あと約 $weeks 週間';
    } on GoalDirectionMismatchException {
      return '目標と体重の増減方向が一致していません';
    } catch (_) {
      return '目安を計算できませんでした';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '体重の記録',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _summaryCard(),
                const SizedBox(height: 20),
                _inputCard(),
                const SizedBox(height: 24),
                const Text('記録の履歴',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                _history(),
              ],
            ),
    );
  }

  Widget _summaryCard() {
    final current = _currentWeight;
    final goal = _profile?.goalWeightKg;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat('現在', current == null ? '--' : '${_fmt(current)}kg'),
              Container(width: 1, height: 40, color: Colors.white54),
              _stat('目標', goal == null ? '--' : '${_fmt(goal)}kg'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _goalMessage(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _inputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '今日の体重(kg)',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _record,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('記録する',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _history() {
    if (_records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('まだ記録がありません',
              style: TextStyle(color: Colors.black38)),
        ),
      );
    }
    final keys = _records.keys.toList()..sort((a, b) => b.compareTo(a));
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < keys.length; i++) ...[
            ListTile(
              leading: const Icon(Icons.monitor_weight_outlined, color: _green),
              title: Text(keys[i]),
              trailing: Text(
                '${_fmt(_records[keys[i]]!)} kg',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (i != keys.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }

  // 整数ならそのまま、小数があれば1桁まで。
  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

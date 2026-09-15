// // Firebaseに送る予定のデータは110~119
import 'package:flutter/material.dart';
import 'mypage.dart'; // マイページをインポート
import 'models/user_profile.dart';
import 'data/frontend_label_mapping.dart';
import 'services/profile_service.dart'; // 初回登録と共通の保存経路(安定uid + 統一スキーマ)

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();  // 初回登録と同じ保存経路を使う
  bool isSaving = false;
  // =========================
  // プロフィール情報
  // =========================

  bool isMale = true;

  String selectedYear = "2000";
  String selectedMonth = "1";
  String selectedDay = "1";

  String goal = "減量";

  int age = 0;

  // =========================
  // 入力欄コントローラー
  // =========================

  final TextEditingController heightController =
      TextEditingController();

  final TextEditingController weightController =
      TextEditingController();

  final TextEditingController goalWeightController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    calculateAge();
    // Firebase に保存済みのプロフィールを読み込んで入力欄へ反映する
    loadExistingProfile();
  }

  // =========================
  // 既存プロフィールの読み込み（安定uidのドキュメント。初回登録と共通）
  // =========================
  Future<void> loadExistingProfile() async {
    final profile = await _profileService.loadProfile();
    if (profile == null || !mounted) return;

    final parts = (profile.birthDate ?? '').split('-');

    setState(() {
      isMale = profile.gender == Gender.male;
      if (parts.length == 3) {
        selectedYear = parts[0];
        selectedMonth = parts[1];
        selectedDay = parts[2];
      }
      goal = profile.goal.label; // 減量/維持/増量/筋トレ
      heightController.text = _numToText(profile.heightCm);
      weightController.text = _numToText(profile.weightKg);
      goalWeightController.text = _numToText(profile.goalWeightKg);
    });
    calculateAge();
  }

  // 数値を入力欄用の文字列に整形（整数なら小数点以下を出さない）
  String _numToText(dynamic value) {
    if (value == null) return '';
    final d = (value as num).toDouble();
    return d == d.roundToDouble() ? d.toInt().toString() : d.toString();
  }

  // =========================
  // 年齢自動計算
  // =========================

  void calculateAge() {
    final today = DateTime.now();

    final birthYear = int.parse(selectedYear);
    final birthMonth = int.parse(selectedMonth);
    final birthDay = int.parse(selectedDay);

    int calculatedAge = today.year - birthYear;

    if (today.month < birthMonth ||
        (today.month == birthMonth &&
            today.day < birthDay)) {
      calculatedAge--;
    }

    setState(() {
      age = calculatedAge;
    });
  }

  // =========================
  // 入力欄デザイン
  // =========================

  InputDecoration customDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  // =========================
  // 登録処理（初回登録と共通の ProfileService 経由で保存）
  // 安定uidの users/{uid} を更新するため、uidは変わらず食事記録等と結びつく。
  // =========================
  Future<void> registerProfile() async {
    if (isSaving) return;

    final profile = UserProfile(
      heightCm: double.tryParse(heightController.text) ?? 0,
      weightKg: double.tryParse(weightController.text) ?? 0,
      age: age,
      gender: isMale ? Gender.male : Gender.female,
      // この画面では活動量を入力しないため、初回登録と同じ既定値を使う
      activityLevel: ActivityLevel.moderate,
      goal: parseGoalLabel(goal),
      birthDate: "$selectedYear-$selectedMonth-$selectedDay",
      goalWeightKg: double.tryParse(goalWeightController.text),
    );

    setState(() => isSaving = true);

    try {
      await _profileService.saveProfile(profile);
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存に失敗しました。入力内容を確認してください。\n$e')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => isSaving = false);

    // 登録完了後にマイページへ遷移（uidは共通なので受け渡し不要）
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MypageScreen(),
      ),
    );
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
          "プロフィール登録",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // 性別
            // =========================

            const Text(
              "性別",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isMale = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isMale ? Colors.green : Colors.white,
                    ),
                    child: Text(
                      "男性",
                      style: TextStyle(
                        color: isMale
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isMale = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !isMale ? Colors.green : Colors.white,
                    ),
                    child: Text(
                      "女性",
                      style: TextStyle(
                        color: !isMale
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =========================
            // 生年月日
            // =========================

            const Text(
              "生年月日",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedYear,
                    decoration: customDecoration("年"),
                    items: List.generate(
                      100,
                      (index) {
                        final year =
                            (DateTime.now().year - index)
                                .toString();

                        return DropdownMenuItem(
                          value: year,
                          child: Text("$year年"),
                        );
                      },
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                      calculateAge();
                    },
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMonth,
                    decoration: customDecoration("月"),
                    items: List.generate(
                      12,
                      (index) {
                        String month =
                            (index + 1).toString();

                        return DropdownMenuItem(
                          value: month,
                          child: Text("$month月"),
                        );
                      },
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                      calculateAge();
                    },
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDay,
                    decoration: customDecoration("日"),
                    items: List.generate(
                      31,
                      (index) {
                        String day =
                            (index + 1).toString();

                        return DropdownMenuItem(
                          value: day,
                          child: Text("$day日"),
                        );
                      },
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedDay = value!;
                      });
                      calculateAge();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =========================
            // 年齢（表示専用）
            // =========================

            TextFormField(
              readOnly: true,
              key: ValueKey(age),
              initialValue: "$age歳",
              decoration: customDecoration("年齢"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: customDecoration("身長(cm)"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: customDecoration("体重(kg)"),
            ),

            const SizedBox(height: 20),

            // =========================
            // 目標
            // =========================

            DropdownButtonFormField<String>(
              value: goal,
              decoration: customDecoration("目標"),
              items: const [
                DropdownMenuItem(
                  value: "減量",
                  child: Text("減量"),
                ),
                DropdownMenuItem(
                  value: "維持",
                  child: Text("維持"),
                ),
                DropdownMenuItem(
                  value: "増量",
                  child: Text("増量"),
                ),
                DropdownMenuItem(
                  value: "筋トレ",
                  child: Text("筋トレ"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  goal = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: goalWeightController,
              keyboardType: TextInputType.number,
              decoration:
                  customDecoration("目標体重(kg)"),
            ),

            const SizedBox(height: 40),

            // =========================
            // 登録ボタン
            // =========================

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isSaving ? null : registerProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "登録",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

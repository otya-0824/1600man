import 'package:flutter/material.dart';
import 'home.dart';
import 'models/user_profile.dart';
import 'data/frontend_label_mapping.dart';
import 'services/profile_service.dart';
import 'meal_storage_service.dart';

class FirstTimeProfilePage extends StatefulWidget {
  const FirstTimeProfilePage({super.key});

  @override
  State<FirstTimeProfilePage> createState() => _FirstTimeProfilePageState();
}

class _FirstTimeProfilePageState extends State<FirstTimeProfilePage> {
  // =========================
  // プロフィール情報
  // =========================

  bool isMale = true;

  String selectedYear = "2000";
  String selectedMonth = "1";
  String selectedDay = "1";

  String goal = "減量";

  int age = 0;

  final ProfileService _profileService = ProfileService();
  bool isSaving = false;

  // =========================
  // 入力欄コントローラー
  // =========================

  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController goalWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    calculateAge();
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    goalWeightController.dispose();
    super.dispose();
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
        (today.month == birthMonth && today.day < birthDay)) {
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
  // 初回登録処理
  // =========================

  Future<void> registerProfile() async {
    if (isSaving) return;

    final profile = UserProfile(
      heightCm: double.tryParse(heightController.text) ?? 0,
      weightKg: double.tryParse(weightController.text) ?? 0,
      age: age,
      gender: isMale ? Gender.male : Gender.female,
      activityLevel: ActivityLevel.moderate,
      goal: parseGoalLabel(goal),
    );

    setState(() => isSaving = true);

    // Firestore等へプロファイルを保存
    await _profileService.saveProfile(profile);

    // 初回登録完了フラグをローカルに保存
    await MealStorageService.setProfileSaved(true);

    if (!mounted) return;
    setState(() => isSaving = false);

    // ホーム画面へ遷移（初回画面に戻れないようスタックをクリア）
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
      (route) => false,
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
        automaticallyImplyLeading: false, // 初回登録のため戻るボタンを表示しない
        title: const Text(
          "初回プロフィール登録",
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
                      backgroundColor: isMale ? Colors.green : Colors.white,
                    ),
                    child: Text(
                      "男性",
                      style: TextStyle(
                        color: isMale ? Colors.white : Colors.black,
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
                      backgroundColor: !isMale ? Colors.green : Colors.white,
                    ),
                    child: Text(
                      "女性",
                      style: TextStyle(
                        color: !isMale ? Colors.white : Colors.black,
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
                            (DateTime.now().year - index).toString();
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
                        String month = (index + 1).toString();
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
                        String day = (index + 1).toString();
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
              key: ValueKey(age),
              readOnly: true,
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
              decoration: customDecoration("目標体重(kg)"),
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "登録して始める",
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
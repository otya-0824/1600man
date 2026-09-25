import 'package:flutter/material.dart';
import 'mypage.dart'; // マイページをインポート

class ProfilePage extends StatefulWidget {
  final bool isDarkMode; // ← 外部からダークモード状態を受け取る

  const ProfilePage({
    super.key,
    this.isDarkMode = false,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // =========================
  // プロフィール情報
  // =========================

  bool isMale = true;

  String selectedYear = "2000";
  String selectedMonth = "1";
  String selectedDay = "1";

  String goal = "ダイエット";

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
  // 入力欄デザイン（ダークモード対応）
  // =========================

  InputDecoration customDecoration(String label, bool isDarkMode) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
      filled: true,
      fillColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
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
  // 登録処理
  // =========================

  void registerProfile() {
    String gender = isMale ? "male" : "female";

    String birthDate =
        "$selectedYear-$selectedMonth-$selectedDay";

    double? height =
        double.tryParse(heightController.text);

    double? weight =
        double.tryParse(weightController.text);

    double? goalWeight =
        double.tryParse(goalWeightController.text);

    // Firebaseに送る予定のデータ
    print({
      "gender": gender,
      "birthDate": birthDate,
      "height": height,
      "weight": weight,
      "goal": goal,
      "goalWeight": goalWeight,
    });

    // ★ 修正：マイページへ戻るときに現在のダークモード状態を確実に渡す
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MypageScreen(isDarkMode: widget.isDarkMode),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDarkMode;

    // ダークモード時の色設定
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F8F8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor), // 戻るボタンの色
        title: Text(
          "プロフィール登録",
          style: TextStyle(
            color: textColor,
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

            Text(
              "性別",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
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
                      backgroundColor: isMale
                          ? Colors.green
                          : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
                    ),
                    child: Text(
                      "男性",
                      style: TextStyle(
                        color: isMale
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
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
                      backgroundColor: !isMale
                          ? Colors.green
                          : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
                    ),
                    child: Text(
                      "女性",
                      style: TextStyle(
                        color: !isMale
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
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

            Text(
              "生年月日",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedYear,
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor),
                    decoration: customDecoration("年", isDark),
                    items: List.generate(
                      100,
                      (index) {
                        final year =
                            (DateTime.now().year - index)
                                .toString();

                        return DropdownMenuItem(
                          value: year,
                          child: Text("$year年", style: TextStyle(color: textColor)),
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
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor),
                    decoration: customDecoration("月", isDark),
                    items: List.generate(
                      12,
                      (index) {
                        String month =
                            (index + 1).toString();

                        return DropdownMenuItem(
                          value: month,
                          child: Text("$month月", style: TextStyle(color: textColor)),
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
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor),
                    decoration: customDecoration("日", isDark),
                    items: List.generate(
                      31,
                      (index) {
                        String day =
                            (index + 1).toString();

                        return DropdownMenuItem(
                          value: day,
                          child: Text("$day日", style: TextStyle(color: textColor)),
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
              style: TextStyle(color: textColor),
              decoration: customDecoration("年齢", isDark),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor),
              decoration: customDecoration("身長(cm)", isDark),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor),
              decoration: customDecoration("体重(kg)", isDark),
            ),

            const SizedBox(height: 20),

            // =========================
            // 目標
            // =========================

            DropdownButtonFormField<String>(
              value: goal,
              dropdownColor: cardColor,
              style: TextStyle(color: textColor),
              decoration: customDecoration("目標", isDark),
              items: [
                DropdownMenuItem(value: "ダイエット", child: Text("ダイエット", style: TextStyle(color: textColor))),
                DropdownMenuItem(value: "維持", child: Text("維持", style: TextStyle(color: textColor))),
                DropdownMenuItem(value: "増量", child: Text("増量", style: TextStyle(color: textColor))),
                DropdownMenuItem(value: "筋トレ", child: Text("筋トレ", style: TextStyle(color: textColor))),
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
              style: TextStyle(color: textColor),
              decoration: customDecoration("目標体重(kg)", isDark),
            ),

            const SizedBox(height: 40),

            // =========================
            // 登録ボタン
            // =========================

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: registerProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
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
// // Firebaseに送る予定のデータは110~119
import 'package:flutter/material.dart';
import 'mypage.dart'; // マイページをインポート
import 'backend/user_service.dart';  // 【編集箇所】Firebaseへのデータ保存処理を行うUserServiceを追加

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService userService = UserService();  // 【編集箇所】Firebaseへの保存処理を行うUserServiceを使用
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
    // Firebase に保存済みのプロフィールを読み込んで入力欄へ反映する
    loadExistingProfile();
  }

  // =========================
  // 既存プロフィールの読み込み（固定ドキュメント）
  // =========================
  Future<void> loadExistingProfile() async {
    final data = await userService.getProfile(UserService.currentUserId);
    if (data == null || !mounted) return;

    final birthDate = (data['birthDate'] ?? '') as String;
    final parts = birthDate.split('-');

    setState(() {
      isMale = (data['gender'] ?? '男性') == '男性';
      if (parts.length == 3) {
        selectedYear = parts[0];
        selectedMonth = parts[1];
        selectedDay = parts[2];
      }
      goal = (data['goal'] ?? goal) as String;
      heightController.text = _numToText(data['height']);
      weightController.text = _numToText(data['weight']);
      goalWeightController.text = _numToText(data['goalWeight']);
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
  // 登録処理
  // 将来的にFirebase送信
  // =========================
  // 【編集箇所】ここからFirebaseへの保存処理
  Future<void> registerProfile() async {
  final String gender = isMale ? "男性" : "女性";

  final String birthDate =
      "$selectedYear-$selectedMonth-$selectedDay";

  final double height =
      double.parse(heightController.text);

  final double weight =
      double.parse(weightController.text);

  final double goalWeight =
      double.parse(goalWeightController.text);

  // saveProfile()に各入力データを渡して保存する
  final String userId = await userService.saveProfile(
    gender: gender,
    birthDate: birthDate,
    height: height,
    weight: weight,
    goal: goal,
    goalWeight: goalWeight,
  );

  print("プロフィールを保存しました");
  print("ユーザーID: $userId");

  // 登録完了後にホームではなくマイページへ遷移
  // 登録したユーザーIDをマイページへ渡す
  if (!mounted) return;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => MypageScreen(
        userId: userId,
      ),
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
                  value: "ダイエット",
                  child: Text("ダイエット"),
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

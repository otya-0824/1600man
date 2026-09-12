import 'package:flutter/material.dart';
import 'home.dart';
import 'meal_storage_service.dart';

class FirstTimeProfilePage extends StatefulWidget {
  const FirstTimeProfilePage({super.key});

  @override
  State<FirstTimeProfilePage> createState() => _FirstTimeProfilePageState();
}

class _FirstTimeProfilePageState extends State<FirstTimeProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  
  String _gender = '男性';

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _saveInitialProfile() async {
    if (_formKey.currentState!.validate()) {
      // プロフィール情報の初期保存処理をここに記述
      // 例: await MealStorageService.saveUserProfile(...);

      // 初回登録完了フラグをオンにする
      await MealStorageService.setProfileSaved(true);

      if (mounted) {
        // ホーム画面へ遷移（戻るボタンで戻れないように全消去）
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
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
          "初期プロフィール設定",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ようこそ！\nあなたの目標に合わせた設定を行います。",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "ニックネーム",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "入力してください" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: "性別",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '男性', child: Text('男性')),
                  DropdownMenuItem(value: '女性', child: Text('女性')),
                  DropdownMenuItem(value: 'その他', child: Text('その他')),
                ],
                onChanged: (val) => setState(() => _gender = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "身長 (cm)",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "入力してください" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "現在の体重 (kg)",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "入力してください" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetWeightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "目標体重 (kg)",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "入力してください" : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveInitialProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "登録してはじめる",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
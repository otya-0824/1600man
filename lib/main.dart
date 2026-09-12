import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'meal_storage_service.dart';
import 'first_time_profile.dart';
import 'home.dart';

Future<void> main() async {
  // Firebaseの初期化（Firestore等のアクセスに必要な設定）
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 日本語フォントを同梱して既定に設定（Web等での文字化け・豆腐表示を防止）
      theme: ThemeData(
        fontFamily: 'NotoSansJP',
        primaryColor: const Color(0xFF66BB6A),
        useMaterial3: true,
      ),
      // 起動時にプロフィールが登録済みか判定して画面を振り分ける
      home: const InitialRouter(),
    );
  }
}

class InitialRouter extends StatefulWidget {
  const InitialRouter({super.key});

  @override
  State<InitialRouter> createState() => _InitialRouterState();
}

class _InitialRouterState extends State<InitialRouter> {
  @override
  void initState() {
    super.initState();
    _checkProfileStatus();
  }

  // プロフィール登録状態を確認して自動遷移
  Future<void> _checkProfileStatus() async {
    bool isSaved = await MealStorageService.isProfileSaved();

    if (!mounted) return;

    if (isSaved) {
      // 登録済みなら ホーム画面 へ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      // 未登録なら 初回用プロフィール設定画面 へ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FirstTimeProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 判定中のローディング画面
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF66BB6A),
        ),
      ),
    );
  }
}
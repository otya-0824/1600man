import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'roudo.dart';

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
      // 起動時はスプラッシュ(roudo)を表示し、その中でプロフィール登録状態に
      // 応じて初回設定画面 or ホームへ振り分ける。
      home: const RoudoScreen(),
    );
  }
}
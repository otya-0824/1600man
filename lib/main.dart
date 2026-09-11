import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'roudo.dart';

Future<void> main() async {
  // Firestore(プロフィール・食事記録)を使うため、起動時にFirebaseを初期化する。
  // これが無いと profile_service / record_service のFirestoreアクセスが失敗する。
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
      // 日本語フォントを同梱して既定に設定（Web で CDN 取得漏れによる豆腐表示を防ぐ）
      theme: ThemeData(fontFamily: 'NotoSansJP'),
      home: const RoudoScreen(),
    );
  }
}

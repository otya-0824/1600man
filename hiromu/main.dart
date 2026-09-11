import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // 【編集箇所】Firebaseを使うために追加
import 'firebase_options.dart';  // 【編集箇所】Firebaseの設定情報を読み込む
import 'roudo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 【編集箇所】アプリ起動時にFirebaseを初期化
  // Firebaseを使う処理を実行する前に必要
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
      home: const RoudoScreen(),
    );
  }
}
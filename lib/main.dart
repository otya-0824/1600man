import 'package:flutter/material.dart';
import 'roudo.dart';

void main() {
  runApp(const MyApp());
}

// 1. App全体でダークモードの状態を管理できるようにStatefulWidgetにする
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // どこからでもダークモードの切り替えを呼び出せるようにするための静的メソッド
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false; // アプリ全体のダークモード状態

  // 状態を切り替える関数
  void toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  bool get isDarkMode => _isDarkMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // ライトモードのテーマ
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.green,
      ),
      // ダークモードのテーマ
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primarySwatch: Colors.green,
      ),
      // 現在の状態に応じてテーマを切り替え
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const RoudoScreen(),
    );
  }
}
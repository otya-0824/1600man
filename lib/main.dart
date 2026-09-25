import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'roudo.dart';

/// ダークモード設定の保存キー
const String _kDarkModeKey = 'dark_mode';

Future<void> main() async {
  // Firebaseの初期化（Firestore等のアクセスに必要な設定）
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // 起動時にダークモード設定を読み込み、初期テーマを決定（起動時のちらつき防止）
  final prefs = await SharedPreferences.getInstance();
  final initialDarkMode = prefs.getBool(_kDarkModeKey) ?? false;
  runApp(MyApp(initialDarkMode: initialDarkMode));
}

// アプリ全体でダークモードの状態を管理できるように StatefulWidget にする
class MyApp extends StatefulWidget {
  final bool initialDarkMode;

  const MyApp({super.key, this.initialDarkMode = false});

  @override
  State<MyApp> createState() => _MyAppState();

  // どこからでもダークモードの切り替えを呼び出せるようにするための静的メソッド
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode = widget.initialDarkMode; // アプリ全体のダークモード状態

  bool get isDarkMode => _isDarkMode;

  // 状態を切り替え、設定を永続化する
  Future<void> toggleTheme(bool isDark) async {
    setState(() {
      _isDarkMode = isDark;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkModeKey, isDark);
  }

  // アプリのブランドカラー（緑）
  static const Color _green = Color(0xFF66BB6A);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // ライトモードのテーマ
      // 日本語フォントを同梱して既定に設定（Web等での文字化け・豆腐表示を防止）
      theme: ThemeData(
        fontFamily: 'NotoSansJP',
        brightness: Brightness.light,
        primaryColor: _green,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _green,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      // ダークモードのテーマ
      darkTheme: ThemeData(
        fontFamily: 'NotoSansJP',
        brightness: Brightness.dark,
        primaryColor: _green,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _green,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
        ),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      // 現在の状態に応じてテーマを切り替え
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // 起動時はスプラッシュ(roudo)を表示し、その中でプロフィール登録状態に
      // 応じて初回設定画面 or ホームへ振り分ける。
      home: const RoudoScreen(),
    );
  }
}

import 'package:flutter/material.dart';

import 'main.dart';
import 'meal_storage_service.dart';
import 'roudo.dart';
import 'services/auth_service.dart';

// =====================================================================
// 設定画面
// アプリ情報の表示と、データ初期化（全記録・プロフィールの削除）を行う。
// =====================================================================
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color _green = Color(0xFF66BB6A);

  @override
  Widget build(BuildContext context) {
    // アプリ全体のダークモード状態を取得（設定の初期値・スイッチ表示に使用）
    final isDarkMode = MyApp.of(context)?.isDarkMode ?? false;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('設定',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _section('表示'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined, color: _green),
            title: const Text('ダークモード'),
            value: isDarkMode,
            activeThumbColor: _green,
            onChanged: (value) {
              // アプリ全体のテーマを切り替え、設定を永続化する
              MyApp.of(context)?.toggleTheme(value);
              setState(() {});
            },
          ),
          const Divider(height: 24),
          _section('アプリ情報'),
          const ListTile(
            leading: Icon(Icons.info_outline, color: _green),
            title: Text('バージョン'),
            trailing: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.eco, color: _green),
            title: Text('アプリ名'),
            trailing: Text('もぐバランス'),
          ),
          const Divider(height: 24),
          _section('データ'),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('データを初期化',
                style: TextStyle(color: Colors.red)),
            subtitle: const Text('プロフィールと全ての記録を削除します'),
            onTap: () => _confirmReset(context),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(title,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      );

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データを初期化しますか？'),
        content: const Text('プロフィール・食事記録・体重記録がすべて削除されます。'
            'この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('初期化する', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok != true) return;
    await AuthService().signOut(); // 匿名アカウントからサインアウト（次回は新規uid）
    await MealStorageService.clearAll();
    if (!context.mounted) return;
    // 初回スプラッシュ→初回登録画面へ戻す（スタックをクリア）。
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoudoScreen()),
      (route) => false,
    );
  }
}

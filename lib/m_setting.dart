import 'package:flutter/material.dart';
import 'main.dart'; // ← MyApp.of(context) を使うためにインポートを追加

class MSettingScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const MSettingScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MSettingScreen> createState() => _MSettingScreenState();
}

class _MSettingScreenState extends State<MSettingScreen> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '設定',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('ダークモード'),
            value: _isDarkMode,
            activeColor: const Color(0xFF66BB6A),
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value;
              });
              // マイページへ状態を通知
              widget.onThemeChanged(value);
              
              // ★ここを追加：アプリ全体（main.dart）のテーマを切り替える
              MyApp.of(context)?.toggleTheme(value);
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('通知設定'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('利用規約'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('プライバシーポリシー'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          const ListTile(
            title: Text('アプリバージョン', style: TextStyle(color: Colors.black54)),
            trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
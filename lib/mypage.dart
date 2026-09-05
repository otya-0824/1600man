import 'package:flutter/material.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  // アイコンを変更できるように状態（State）として保持
  bool _hasCustomImage = false; 

  // アイコンがタップされたときの処理
  void _changeProfileImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プロフィール画像'),
        content: const Text('プロフィール画像を変更しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _hasCustomImage = !_hasCustomImage;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('プロフィール画像を変更しました！')),
              );
            },
            child: const Text('変更する'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF66BB6A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. 上部のプロフィールエリア（緑色の背景）
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60.0, bottom: 30.0),
            color: primaryGreen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // プロフィールアイコン
                GestureDetector(
                  onTap: _changeProfileImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: _hasCustomImage ? primaryGreen : Colors.grey,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // ユーザー名
                const Text(
                  'カロミル 太郎',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                // プロフィール編集ボタン
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: const Text(
                    'プロフィール編集',
                    style: TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. メニューリスト
          Expanded(
            child: ListView(
              children: const [
                _MenuItem(title: '目標設定'),
                _MenuItem(title: '体重の記録'),
                _MenuItem(title: 'よくある質問'),
                _MenuItem(title: '設定'),
                _MenuItem(title: 'ログアウト', isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// メニューの各項目を作る部品
class _MenuItem extends StatelessWidget {
  final String title;
  final bool isLogout;

  const _MenuItem({required this.title, this.isLogout = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: isLogout ? Colors.red : Colors.black87,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
          onTap: () {},
        ),
        const Divider(height: 1, thickness: 1, color: Colors.black12),
      ],
    );
  }
}
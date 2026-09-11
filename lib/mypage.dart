import 'package:flutter/material.dart';
import 'meal.dart';
import 'gurahu.dart';
import 'calendar.dart';
import 'home.dart';
import 'profile.dart'; // 上記のProfilePageをインポート
import 'backend/user_service.dart';   // 【編集箇所】Firebaseへのデータ取得・保存処理を行うUserServiceを追加

// 【編集箇所】ここから22行目まで
class MypageScreen extends StatefulWidget {

  // 【編集箇所】Firebaseから取得するユーザーIDを受け取る
  final String? userId;

  const MypageScreen({
    super.key,
    this.userId,
  });

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  bool _hasCustomImage = false;

  final UserService userService = UserService();  // 【編集箇所】Firebaseのプロフィール情報を扱うUserService

  Map<String, dynamic>? profileData;              // 【編集箇所】Firebaseから取得したプロフィール情報を保存する変数

  // 【編集箇所】ここから51行目まで
  @override
  void initState() {
    super.initState();

    // 【編集箇所】画面を開いたときにFirebaseからプロフィール情報を取得
    loadProfile();
  }

  // 【編集箇所】Firebaseからプロフィール情報を取得する処理
  Future<void> loadProfile() async {
    // userId が渡されていなければ固定ドキュメント(current)を読む。
    // これによりボトムナビ経由（userId なし）でもプロフィールを取得できる。
    final id = widget.userId ?? UserService.currentUserId;

    // UserServiceを使ってFirebaseからプロフィールを取得
    profileData = await userService.getProfile(id);
    if (!mounted) return;
    setState(() {});
  }

  void _changeProfileImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プロフィール画像'),
        content: const Text('プロフィール画像を修正しますか？'),
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
                const SnackBar(content: Text('プロフィール画像を修正しました')),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60.0, bottom: 30.0),
            color: primaryGreen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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

                // 【編集箇所】表示をプロフィールに変更
                const Text(
                  'プロフィール',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
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
          Expanded(
            child: ListView(
              children: [
                _MenuItem(
                  title: 'プロフィール・目標設定',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                ),
                _MenuItem(title: '体重の記録', onTap: () {}),
                _MenuItem(title: 'よくある質問', onTap: () {}),
                _MenuItem(title: '設定', onTap: () {}),
                _MenuItem(title: 'ログアウト', isLogout: true, onTap: () {}),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 4) return;
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MealPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const GraphScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: '記録'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'グラフ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final bool isLogout;
  final VoidCallback onTap;

  const _MenuItem({
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });

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
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1, color: Colors.black12),
      ],
    );
  }
}

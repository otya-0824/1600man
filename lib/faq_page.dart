import 'package:flutter/material.dart';

// =====================================================================
// よくある質問（FAQ）
// アプリの使い方・目標計算の考え方などを静的に説明する。
// =====================================================================
class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const List<List<String>> _qa = [
    [
      '目標カロリーはどう決まりますか？',
      '身長・体重・年齢・性別・活動量から消費カロリー(TDEE)を計算し、'
          '目標(減量/維持/増量/筋トレ)に応じて増減させた値を目標にしています。'
          'プロフィールを編集すると自動で再計算されます。',
    ],
    [
      '栄養バランスの五角形の見方は？',
      '赤い線が目標(達成率100%)です。緑のポリゴンが今日の実績で、'
          '赤い線に届いていれば十分、届いていなければ不足を表します。',
    ],
    [
      'ビタミン・ミネラルが増えません',
      '微量栄養素は「栄養データベースから記録した食品」にのみ内訳が付きます。'
          '手動入力やよく食べるメニューでは加算されない場合があります。',
    ],
    [
      '記録したデータはどこに保存されますか？',
      '食事・体重の記録は端末内に保存されます。プロフィールは端末に加えて'
          'クラウドにも控えを保存します。',
    ],
    [
      '目標や体重を変えたい',
      'マイページ →「プロフィール・目標設定」から、いつでも変更できます。',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('よくある質問',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final qa in _qa)
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                shape: const Border(),
                leading: const Icon(Icons.help_outline, color: Color(0xFF66BB6A)),
                title: Text(qa[0],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                childrenPadding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(qa[1],
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87, height: 1.5)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

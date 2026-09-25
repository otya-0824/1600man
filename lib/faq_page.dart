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
      '目標値の計算根拠は？',
      'カロリーの計算は次の流れです。\n'
          '① 基礎代謝(BMR)を Mifflin-St Jeor 式で算出\n'
          '② 総消費カロリー(TDEE) = BMR × 活動係数\n'
          '③ 目標カロリー = TDEE ± 目標(減量/維持/増量/筋トレ)による増減\n'
          '④ PFC(たんぱく質・脂質・炭水化物)を配分\n\n'
          'ビタミン・ミネラル・食物繊維・食塩などの目標量は、'
          '厚生労働省「日本人の食事摂取基準(2025年版)」の推奨量・目安量・目標量を、'
          'あなたの年齢・性別に当てはめて設定しています。\n\n'
          '※鉄は本来「月経の有無」で大きく変わりますが、本アプリでは入力しないため、'
          '50歳未満の女性は月経あり・50歳以上は月経なしとして近似しています。'
          'コレステロールは明確な推奨量がないため、参考値として200mg/日を用いています。',
    ],
    [
      'この目標値は医療的なアドバイスですか？',
      'いいえ。表示される目標値はあくまで一般的な目安であり、医療的な指導・診断に'
          '代わるものではありません。持病がある場合や大幅な体重の増減を行う場合は、'
          '医師・管理栄養士にご相談ください。',
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text('よくある質問',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                            height: 1.5)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

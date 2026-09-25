import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 背景色を固定せず、テーマ（ダーク/ライト）に自動追従させる
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'よくある質問',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ExpansionTile(
            title: Text(
              '食事の記録はどのように行いますか？',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('下部メニューの「記録」タブから、食べた食事を選択または追加することができます。'),
              ),
            ],
          ),
          Divider(),
          ExpansionTile(
            title: Text(
              '目標カロリーを変更したいです。',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('「マイページ」の設定画面から、ご自身の目標値を変更することが可能です。'),
              ),
            ],
          ),
          Divider(),
          ExpansionTile(
            title: Text(
              'データのバックアップはできますか？',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('アカウントにログインしている場合、自動的にクラウドにデータが保存されます。'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
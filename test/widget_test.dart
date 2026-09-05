import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart'; // プロジェクト名

void main() {
  testWidgets('App start test', (WidgetTester tester) async {
    // アプリを起動
    await tester.pumpWidget(const MyApp());

    // アプリのルート（MaterialApp）が正常に表示されているか確認
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
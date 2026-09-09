# 作業メモ（2026-08-30）

## 今日やったこと：アプリにFirebaseを組み込んだ

友達が作ってくれたFirebaseプロジェクト（`hakkason-b9738`）を、このFlutterアプリ（1600man）から使えるようにした。

### やった手順

1. **ツールの用意**
   - Firebase CLI と FlutterFire CLI をインストール
   - iOSの設定書き込みに `xcodeproj`（Ruby）が必要だったので、Homebrewの新しいRubyで入れた

2. **Firebaseにログイン**
   - `firebase login` を実行
   - 友達に招待されたアカウント（jyo14001234@gmail.com）で認証
   - `firebase projects:list` で `hakkason` プロジェクトが見えることを確認

3. **設定ファイルの自動生成**
   - `flutterfire configure --project=hakkason-b9738 --platforms=android,ios`
   - 生成されたもの：
     - `lib/firebase_options.dart`
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`
     - `firebase.json`

4. **アプリ側のコード**
   - `firebase_core` を追加
   - `main()` で起動時に `Firebase.initializeApp()` するようにした
   - `flutter analyze` でエラーなしを確認

5. **GitHubに反映**
   - コミットしてpush
   - 友達がその間に `main.dart` を更新していて競合したので、
     友達の画面（ProfilePage）とFirebase初期化の両方を残す形で解決してpush

### メモ・気づき
- `google-services.json` などはモバイル用のクライアント設定なので、チームで共有する前提。隠さずコミットでOK。
- FlutterFire CLI は `~/.pub-cache/bin` に入る（PATHが通ってないのでフルパス注意）。
- iOSの `xcodeproj` はmacOS標準のRuby2.6では入らなかった。Homebrewのrubyを使うのが正解だった。

### 次にやること（TODO）
- 実機 or シミュレータで実際にFirebaseに繋がるか動作確認
- 使いたい機能（Firestore / Authなど）のパッケージを追加していく

# 作業メモ（2026/08/13）

友達からリポジトリ `otya-0824/1600man` に招待してもらったので、環境構築した。

## やったこと

- リポジトリを `~/Desktop/1600man` にclone
  - 中身は `.gitignore` だけの初期状態だったので、ここからFlutterプロジェクトの土台を自分で作ることにした
- `flutter doctor` で環境確認 → Android SDK / Xcode ともに問題なし（iPhone実機だけデベロッパーモード未設定で認識されなかった）
- `flutter create --platforms=ios,android --org com.otya0824 --project-name man1600 .` でiOS/Android両対応の土台を作成
- `flutter pub get` で依存パッケージ取得済み
- READMEにクローン手順・Flutterのインストール方法・ファイル構成の説明を追記

## 次にやること

- iPhone側でデベロッパーモードをONにして実機確認
- Androidエミュレーター or 実機で動作確認
- `lib/main.dart` から実際の画面を作り始める

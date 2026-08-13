# man1600

iPhone / Android 両対応のFlutterアプリです。

## 0. Gitのインストール（Windowsでコマンドプロンプトを使う場合）

Windowsに標準ではGitが入っていないため、`git`コマンドが使えない場合は以下の方法でインストールしてください。

**方法A: winget（Windows 10/11標準）を使う**

コマンドプロンプトを開いて以下を実行します。

```cmd
winget install --id Git.Git -e --source winget
```

インストール後、コマンドプロンプトを開き直して確認します。

```cmd
git --version
```

**方法B: インストーラーを使う**

1. [Git for Windows](https://gitforwindows.org/)にアクセスし、`Download`からインストーラー（.exe）をダウンロード
2. インストーラーを実行し、基本的にデフォルト設定のまま「Next」で進めてインストール
3. インストール完了後、コマンドプロンプトを開き直し `git --version` で確認

## 1. リポジトリのクローン

```bash
git clone https://github.com/otya-0824/1600man.git
cd 1600man
```

## 2. Flutterのインストール（未導入の場合）

### macOS

Homebrewでのインストールが簡単です。

```bash
brew install --cask flutter
```

### Windows

1. [Flutter公式サイト](https://docs.flutter.dev/get-started/install/windows)からFlutter SDKのzipをダウンロードし、`C:\src\flutter` など好きな場所に展開する（パスに空白や日本語を含めない）
2. 環境変数 `Path` に `C:\src\flutter\bin` を追加する
   - 「システム環境変数の編集」→「環境変数」→ ユーザー環境変数の `Path` に追記
3. PowerShellまたはコマンドプロンプトを開き直して確認

   ```powershell
   flutter --version
   ```

   Windows版はiOS開発ができないため、このプロジェクトではAndroid向けの動作確認のみ行えます。

インストール後、以下のコマンドで環境が正しく整っているか確認してください（Android SDK、Xcodeなどの状態が表示されます）。

```bash
flutter doctor
```

`flutter doctor` で指摘された不足項目があれば、表示される指示に従って対応してください。

- iOS開発（macOSのみ）には Xcode（App Store からインストール）と CocoaPods が必要です
  ```bash
  sudo gem install cocoapods
  ```
- Android開発（macOS / Windows共通）には Android Studio と Android SDK が必要です
  - Windowsの場合、Android Studioのインストーラーで「Android SDK」「Android Virtual Device」にチェックを入れてインストールする
  - `flutter doctor --android-licenses` を実行してAndroidライセンスに同意しておく

## 3. 依存パッケージの取得

```bash
flutter pub get
```

## 4. アプリの実行

接続した実機・起動中のシミュレーター/エミュレーターに対して実行します。

```bash
flutter devices   # 認識されているデバイス一覧を確認
flutter run       # デフォルトデバイスで実行
```

- iOSシミュレーターで実行する場合は事前に `open -a Simulator` でシミュレーターを起動してください
- Androidエミュレーターの場合は Android Studio の Device Manager から起動するか `flutter emulators --launch <emulator_id>` を実行してください
- 実機のiPhoneで実行する場合は、iPhone側で「デベロッパーモード」を有効にし、Macとケーブル接続（またはWi-Fi経由でペアリング）してください

## ディレクトリ・ファイル構成

| パス | 説明 |
| --- | --- |
| `lib/main.dart` | アプリのエントリーポイント。ここにDartのアプリコードを書いていく |
| `pubspec.yaml` | パッケージ名・バージョン・依存ライブラリなどを定義する設定ファイル |
| `pubspec.lock` | 依存ライブラリの実際に解決されたバージョンを固定するファイル（`flutter pub get`で自動生成） |
| `analysis_options.yaml` | Dartの静的解析（Lint）ルールの設定ファイル |
| `test/` | ウィジェットテスト・単体テストを置くディレクトリ |
| `android/` | Androidアプリ向けのネイティブプロジェクト一式（Gradle設定、AndroidManifest.xmlなど） |
| `ios/` | iOSアプリ向けのネイティブプロジェクト一式（Xcodeプロジェクト、Info.plistなど） |
| `.gitignore` | Gitの管理対象外にするファイル・フォルダの指定 |
| `.metadata` | FlutterツールがプロジェクトのFlutter/Dartバージョンなどを管理するための内部ファイル（手動編集不要） |

## GitHub（Git）の使い方一覧

チームで開発する際によく使うコマンドをまとめます。

### 最新の変更を取得する

```bash
git pull origin main
```

作業を始める前に必ず実行し、他の人の変更を取り込んでから作業しましょう。

### 変更用のブランチを作る

```bash
git checkout -b feature/画面名など
```

`main`ブランチに直接コミットせず、機能ごとにブランチを分けるのがおすすめです。

### 変更内容を確認する

```bash
git status   # 変更されたファイル一覧
git diff     # 変更の中身（差分）
```

### 変更をコミットする

```bash
git add .                     # 変更したファイルをすべてステージに追加
git add ファイルパス           # 特定のファイルだけ追加したい場合
git commit -m "コミットメッセージ"
```

### GitHubにpushする

```bash
git push origin ブランチ名
```

初回pushで「upstreamが設定されていません」と言われた場合は以下を使います。

```bash
git push -u origin ブランチ名
```

### プルリクエスト（PR）を作る

1. GitHubのリポジトリページを開く
2. push後に表示される「Compare & pull request」ボタンを押す
3. タイトル・説明を書いて「Create pull request」

### ブランチを切り替える

```bash
git checkout main            # mainブランチに戻る
git checkout ブランチ名       # 他のブランチに切り替え
```

### コミット履歴を見る

```bash
git log --oneline
```

### よくあるトラブル

| 状況 | 対処 |
| --- | --- |
| `git pull`で「ローカルの変更で上書きされる」と怒られる | `git stash` で一旦変更を退避 → `git pull` → `git stash pop` で変更を戻す |
| コミットメッセージを間違えた（直前のコミットのみ） | `git commit --amend -m "正しいメッセージ"`（ただしpush前のみ） |
| pushしたら他の人の変更と衝突（コンフリクト） | 該当ファイルを開き `<<<<<<<` `=======` `>>>>>>>` の部分を手動で修正 → `git add` → `git commit` |

## 参考

- [Flutter公式ドキュメント](https://docs.flutter.dev/)
- [Flutter入門（初めてのアプリ作成）](https://docs.flutter.dev/get-started/codelab)
- [GitHub公式ドキュメント](https://docs.github.com/ja)

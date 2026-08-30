# 作業メモ（okabeブランチ）

担当：データ永続化まわり（アプリを開き直してもデータが残る仕組み）
- ひろむ：ログイン（Auth）
- せな：食品情報・カロリー/PFC計算
- 他：エラー処理
- 自分：上記以外（Firestoreのデータ保存・読み込み、DB設計）

## ブランチ
- `main` から `okabe` ブランチを切って作業中

## 設計方針：開き直してもデータを保持する
1. **uid（誰か）**：Firebase Authの匿名ログインでuidを発行。端末に自動保存されるので再起動しても同じuidが復元される（ひろむ担当と接続）
2. **Firestore（保存先）**：データをクラウドに保存。モバイルはオフライン永続化がデフォルトONなので電波なしでもキャッシュ表示される
3. 「登録＝書き込み」「起動＝読み込み」をセットで作る

### Firestore構造（設計図）
```
users/{uid}
  ├─ gender, birthDate, height, weight, goal, goalWeight
  ├─ targetCalorie, targetP/F/C（せなの計算結果）
  └─ records/{日付}/meals/{自動ID}
        name, calorie, p, f, c, time
```

## やったこと（ここに追記していく）

### 2026-08-30 プロフィールの永続化を実装
1. **パッケージ追加**：`cloud_firestore 6.9.0`、`firebase_auth 6.6.1`（`flutter pub add`）
2. **データモデル作成**：`lib/models/user_profile.dart`
   - `UserProfile`クラス。`toMap()`（保存用）と`fromMap()`（読込用）でFirestoreと変換
3. **サービス作成**：`lib/services/profile_service.dart`
   - `_ensureUid()`：匿名ログインでuidを確保（ひろむのログインが入るまでの土台）
   - `saveProfile()`：`users/{uid}`に`set(merge:true)`で書き込み
   - `loadProfile()`：`users/{uid}`を読み込み（無ければnull）
4. **profile.dart改修**：
   - `registerProfile()`を`print`→Firestore保存（async化）に変更
   - `initState`で`loadSavedProfile()`を呼び、前回の登録内容を入力欄へ反映
   - 登録ボタンに保存中のローディング表示＋二重押し防止（`isSaving`）
   - 年齢欄に`ValueKey(age)`を付けて読込後も表示更新されるように
5. `flutter analyze` → 今回追加分はエラーなし（既存のDropdownの非推奨warningのみ残存）

### 動作の考え方
- 登録 → `users/{uid}` に書き込み
- 開き直し → 同じuidが復元 → `users/{uid}`を読み込み → 入力欄に復元（＝データが残る）

### 2026-08-30 食事記録のデータ層＋ホーム画面連携（フロントに合わせる）
フロントが作った `home.dart`（今日の栄養サマリー画面）の `---` プレースホルダーを実データで埋める方針。

1. **uid共通化**：`lib/services/auth_service.dart`（新規）に`ensureUid()`を切り出し
   - `profile_service.dart`もこれを使うようリファクタ（重複排除）
   - ひろむのログインができたら、この`ensureUid()`の中身だけ差し替えれば全機能が繋がる
2. **食事モデル作成**：`lib/models/meal.dart`（新規）
   - `Meal`（食品名/カロリー/P/F/C/時刻、toMap・fromMap）
   - `DailySummary`（その日の合計。`fromMeals()`で食事リストから集計）
3. **記録サービス作成**：`lib/services/record_service.dart`（新規）
   - 保存先：`users/{uid}/records/{日付}/meals/{自動ID}`
   - `addMeal()` / `deleteMeal()` / `fetchMeals()` / `watchMeals()`
   - `watchDailySummary()`：その日の合計をリアルタイムに流す（ホーム用）
4. **home.dart連携**：デザインはそのまま、カロリー円グラフとPFC行を
   `StreamBuilder<DailySummary>`で包んで実データ表示に
   - カロリー中央の数字＝その日の合計、PFCも実グラム
   - 分母の「/ --- kcal」（目標カロリー）はせなの計算結果が入るまで "---" のまま
5. `flutter analyze` → 追加分エラーなし（既存のwithOpacity warningのみ）

## 役割の接続メモ
- せな：食品ごとのカロリー/PFCを計算 → その結果を`Meal`にして`recordService.addMeal()`で保存
- ひろむ：ログイン → `auth_service.dart`の`ensureUid()`を差し替え
- フロント：`home.dart`の見た目（そのまま活かしてる）
- 目標カロリー(分母)：せなの計算結果を`users/{uid}`のtargetCalorie等に入れて表示予定

## 次にやること
- 「記録」タブの画面 → 食事追加UIができたら`addMeal()`に繋ぐ
- 目標カロリー/PFC（せなの計算）をプロフィールに保存し、ホームの分母・達成率に反映
- Firestoreセキュリティルール（本人のuidだけ読み書き可）
- 実機/シミュレータで通し動作確認（登録→再起動→復元、食事追加→ホーム反映）

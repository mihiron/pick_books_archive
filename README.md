# pick_books

お気に入りの本の情報をストックするアプリ

### 環境
Flutter Stable 3.0.5

| カテゴリ         | 説明                          |
| ---------------- | ----------------------------- |
| 状態管理と DI    | flutter_hooks, hooks_riverpod |
| データモデル     | freezed                       |
| クラウド DB      | cloud_firestore               |
| ローカル DB      | shared_preferences            |
| API クライアント | retrofit                      |

### 機能

- Splash画面
- FirebaseAuthでの認証（メール/パスワード）
  - sign up
  - sign in
- Cloud Firestoreを用いたBookデータ一覧とCRUD
  - データの追加、更新、削除
  - データ一覧の Pull-to-refresh
  - データ一覧の Infinite Scroll Pagination
- Cloud Storageの利用
  - 画像ファイルの圧縮とCRUD
- Cloud Functionsの利用
  - Cloud Firestoreのnumber型フィールドのインクリメントとデクリメント

#### Firebaseファイルの設置場所

- Android

  ```
  # 開発環境
  android/app/src/dev/google-services.json
  # 本番環境
  android/app/src/prod/google-services.json
  ```

- iOS

  ```
  # 開発環境
  ios/dev/GoogleService-Info.plist
  # 本番環境
  ios/prod/GoogleService-Info.plist
  ```

#### 実行コマンド

- 開発

  ```sh
  flutter run --debug --dart-define=FLAVOR=dev
  ```

- 本番

  ```sh
  flutter run --debug --dart-define=FLAVOR=prod
  ```
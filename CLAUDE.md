# Oshi-Suta BATTLE - Claude Code Project Context

## プロジェクト概要

Jリーグサポーター向けフィットネス×ゲーミフィケーションアプリ。
日常の歩数をクラブの応援ポイントに変換し、クラブ間で競い合う。

## 技術スタック

### バックエンド
- **言語**: Python 3.11
- **フレームワーク**: FastAPI
- **データベース**: Firebase Firestore
- **キャッシュ**: Redis
- **認証**: Firebase Auth
- **デプロイ**: Docker + Docker Compose

### モバイルアプリ
- **フレームワーク**: Flutter
- **状態管理**: BLoC パターン
- **HTTP通信**: http package
- **認証**: Firebase Auth

## プロジェクト構造

```
oshi-suta-battle/
├── backend/          # FastAPI バックエンド
│   ├── app/
│   │   ├── api/v1/   # APIエンドポイント
│   │   ├── models/   # データモデル
│   │   ├── services/ # ビジネスロジック
│   │   ├── repositories/ # データアクセス層
│   │   └── utils/    # ユーティリティ
│   └── tests/        # テストコード
└── mobile_app/       # Flutter モバイルアプリ
    └── lib/
        ├── features/ # 機能別ディレクトリ
        ├── core/     # 共通コード
        └── shared/   # 共有ウィジェット
```

## 重要な開発方針

### ⚠️ コード品質の最優先事項

**既存のコードを最大限流用し、不要な処理や関数は積極的に削除すること**

- 新規実装時は、必ず既存の類似コードを探して流用する
- 重複コードは共通化する
- 使われていない関数・変数・importは削除する
- 過剰な抽象化は避ける
- シンプルで保守しやすいコードを心がける

## コーディング規約

### Python (Backend)

- **スタイル**: PEP 8準拠
- **フォーマッター**: Black
- **import整理**: isort
- **リンター**: flake8
- **型ヒント**: 必須（Python 3.11+の型ヒント活用）
- **docstring**: 公開API・複雑な関数には必須

### Flutter (Mobile)

- **スタイル**: Effective Dart準拠
- **状態管理**: BLoC パターン統一
- **フォルダ構造**: feature-first
- **命名規則**:
  - クラス: PascalCase
  - 変数・関数: camelCase
  - 定数: UPPER_SNAKE_CASE
  - プライベート: 先頭に `_`

### エラーハンドリング

- **統一されたエラーハンドリング**: 最近実装済み（DONE参照）
- すべてのAPI呼び出しで適切なエラーハンドリングを実装
- ユーザーフレンドリーなエラーメッセージ
- ログに十分なコンテキスト情報を含める

## 進行中のリファクタリング

現在、以下のリファクタリングタスクが進行中（TODOディレクトリ参照）：

1. **HIGH**: リポジトリAPI呼び出しの共通化
2. **MEDIUM**: バリデーション関数の共通化
3. **MEDIUM**: BLoCパターンの標準化
4. **MEDIUM**: モデルコード生成の改善
5. **LOW**: レスポンス構築ヘルパー
6. **LOW**: フォーム管理の共通化

## 開発時の注意事項

### API開発

- エンドポイントは必ず `/api/v1/` プレフィックスを使用
- レスポンスは必ずステータスコードとメッセージを含める
- 認証が必要なエンドポイントは依存性注入で実装
- Firestoreクエリは必ずリポジトリ層で実行

### Flutter開発

- 新しいフィーチャーは `lib/features/` 以下に配置
- API呼び出しは必ずリポジトリ経由で実行（直接http呼び出し禁止）
- 画面固有のウィジェットは同じディレクトリに配置
- 再利用可能なウィジェットは `lib/shared/` に配置
- BLoCは各フィーチャーごとに作成

### セキュリティ

- 環境変数に機密情報を保存（コミット禁止）
- `.env`, `firebase-credentials.json` は `.gitignore` 必須
- ユーザー入力は必ずバリデーション
- SQLインジェクション・XSS対策を意識

### テスト

- 新機能追加時は必ずテストを書く
- バックエンド: pytest使用
- カバレッジ: 最低70%を目標

## よく使うコマンド

### バックエンド

```bash
# Docker環境起動
docker-compose up --build

# テスト実行
cd backend && pytest

# コードフォーマット
cd backend && black app/ && isort app/
```

### Flutter

```bash
# 依存関係インストール
flutter pub get

# ビルド
flutter build apk  # Android
flutter build ios  # iOS

# 解析
flutter analyze
```

## Git運用

- **メインブランチ**: `main`
- コミットメッセージは日本語OK
- 機能単位でコミット
- TODOタスク完了時は対応ファイルをDONEディレクトリに移動

## 問題が発生したら

1. ログを確認: `docker-compose logs`
2. ヘルスチェック: `curl http://localhost:8000/api/v1/health`
3. TODOディレクトリのREADME.mdを確認
4. 既存の類似実装を探す

## その他

- Phase 1実装中（基本機能のみ）
- 対応クラブ: J1リーグの主要12クラブ
- ポイント計算: 1,000歩 = 1ポイント

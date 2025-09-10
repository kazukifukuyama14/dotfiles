# Package Backup System

自端末にインストールされているパッケージ管理ツールのバックアップを GitHub 上で管理するシステムです。

## 対応パッケージ管理ツール

- **Homebrew**: macOS 用パッケージマネージャー
- **npm**: Node.js パッケージマネージャー
- **pip**: Python パッケージマネージャー
- **gem**: Ruby パッケージマネージャー

## ディレクトリ構造

```bash
package-backup/
├── README.md                 # このファイル
├── homebrew/                 # Homebrewバックアップファイル
├── npm/                     # npmバックアップファイル
├── pip/                     # pipバックアップファイル
├── gem/                     # gemバックアップファイル
└── scripts/                 # バックアップ・復元スクリプト
    ├── backup-all.sh        # 全ツール一括バックアップ
    ├── restore-all.sh        # 全ツール一括復元
    ├── backup-homebrew.sh   # Homebrewバックアップ
    ├── backup-npm.sh        # npmバックアップ
    ├── backup-pip.sh        # pipバックアップ
    └── backup-gem.sh        # gemバックアップ
```

## 使用方法

### 手動バックアップ

```bash
# 全パッケージ管理ツールのバックアップを実行
./package-backup/scripts/backup-all.sh

# 個別のバックアップ
./package-backup/scripts/backup-homebrew.sh
./package-backup/scripts/backup-npm.sh
./package-backup/scripts/backup-pip.sh
./package-backup/scripts/backup-gem.sh
```

### 復元

```bash
# 全パッケージ管理ツールの復元
./package-backup/scripts/restore-all.sh
```

### GitHub Actions 自動バックアップ

このリポジトリには GitHub Actions が設定されており、以下のタイミングで自動バックアップが実行されます：

- **定期実行**: 毎週日曜日の午前 2 時（JST）
- **手動実行**: GitHub Actions の「Run workflow」から実行可能
- **プッシュ時**: `package-backup/`ディレクトリに変更があった場合

## バックアップ内容

### Homebrew

- インストール済みパッケージリスト（formula）
- インストール済み Cask リスト
- 依存関係情報
- Brewfile（復元用）
- Homebrew バージョン情報

### npm

- グローバルパッケージリスト
- パッケージ詳細情報（JSON 形式）
- 復元用 package.json
- npm 設定情報
- Node.js・npm バージョン情報

### pip

- インストール済みパッケージリスト
- requirements.txt（復元用）
- パッケージ詳細情報（JSON 形式）
- pip 設定情報
- Python・pip バージョン情報

### gem

- インストール済み gem リスト
- gem 詳細情報
- Gemfile（復元用）
- gem 環境情報
- Ruby・gem バージョン情報

## 復元手順

### 新しい環境での復元

1. このリポジトリをクローン
2. 必要なパッケージ管理ツールをインストール
3. 復元スクリプトを実行

```bash
git clone <このリポジトリのURL>
cd dotfiles
./package-backup/scripts/restore-all.sh
```

### 個別復元

各ツールの`*_latest.*`ファイルを使用して手動で復元することも可能です：

```bash
# Homebrew
brew bundle --file=package-backup/homebrew/Brewfile_latest

# npm
npm install -g --package-lock=false < package-backup/npm/global_packages_restore_latest.json

# pip
pip3 install -r package-backup/pip/requirements_latest.txt

# gem
gem install --file=package-backup/gem/Gemfile_latest
```

## 設定

### バックアップファイルの保持期間

各スクリプトは 30 日以上古いバックアップファイルを自動削除します。この期間を変更したい場合は、各スクリプトの`find`コマンドの`-mtime +30`部分を修正してください。

### ログファイル

各バックアップ実行時にログファイルが生成されます：

- `backup_YYYYMMDD_HHMMSS.log`: 個別ツールのログ
- `backup_all_YYYYMMDD_HHMMSS.log`: 一括バックアップのログ

## トラブルシューティング

### よくある問題

1. **権限エラー**

   ```bash
   chmod +x package-backup/scripts/*.sh
   ```

2. **ツールが見つからない**

   - 各パッケージ管理ツールが正しくインストールされているか確認
   - PATH が正しく設定されているか確認

3. **バックアップファイルが生成されない**
   - ログファイルを確認してエラーの詳細を確認
   - 各ツールのバージョン情報を確認

### ログの確認

```bash
# 最新のログファイルを確認
ls -la package-backup/*/backup_*.log | tail -5

# ログの内容を確認
tail -f package-backup/homebrew/backup_*.log
```

## 注意事項

- バックアップは**パッケージリストのみ**を保存します
- 実際のパッケージファイルは保存されません
- 復元時はインターネット接続が必要です
- 一部のパッケージは環境依存のため、完全な復元ができない場合があります

## 貢献

バグ報告や機能追加の提案は、GitHub の Issue または Pull Request でお願いします。

## ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。

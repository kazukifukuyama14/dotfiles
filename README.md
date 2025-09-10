# Dotfiles

個人用の設定ファイルとパッケージバックアップシステムを管理するリポジトリです。

## パッケージバックアップシステム

このリポジトリには、自端末にインストールされているパッケージ管理ツールのバックアップシステムが含まれています。

### 対応パッケージ管理ツール

- Homebrew (macOS 用パッケージマネージャー)
- npm (Node.js パッケージマネージャー)
- pip (Python パッケージマネージャー)
- gem (Ruby パッケージマネージャー)

### 設定ファイルバックアップ

以下の設定ファイルも自動的にバックアップされます：

- Shell 設定: `.zshrc`, `.zprofile`, `.bashrc`, `.bash_profile`
- Git 設定: `.gitconfig`, `.gitignore`, `.gitignore_global`
- アプリケーション設定: `.yarnrc`, `.stCommitMsg`, `.claude.json`
- 設定ディレクトリ: `.config`, `.cursor`, `.continue`, `.claude`
- 特定設定: `starship.toml`, VS Code 設定, SSH 設定

## バックアップの取り方

### 手動バックアップ

```bash
# 全パッケージ管理ツールと設定ファイルのバックアップを実行
./package-backup/scripts/backup-all.sh

# 個別のバックアップ
./package-backup/scripts/backup-homebrew.sh
./package-backup/scripts/backup-npm.sh
./package-backup/scripts/backup-pip.sh
./package-backup/scripts/backup-gem.sh
./package-backup/scripts/backup-configs.sh
```

### 自動バックアップ

GitHub Actions により以下のタイミングで自動バックアップが実行されます：

- 定期実行: 毎週日曜日の午前 2 時（JST）
- 手動実行: GitHub Actions の「Run workflow」から実行可能
- プッシュ時: `package-backup/` ディレクトリに変更があった場合

## 新しい端末での設定導入

### 1. リポジトリのクローン

```bash
git clone <このリポジトリのURL>
cd dotfiles
```

### 2. パッケージ管理ツールのインストール

必要なパッケージ管理ツールをインストール：

```bash
# Homebrew (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Node.js (nvm を使用)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install node
nvm use node

# Python (Homebrew でインストール)
brew install python

# Ruby (Homebrew でインストール)
brew install ruby
```

### 3. パッケージの復元

```bash
# 全パッケージ管理ツールと設定ファイルの復元
./package-backup/scripts/restore-all.sh
```

### 4. 個別復元（必要に応じて）

```bash
# Homebrew
brew bundle --file=package-backup/homebrew/Brewfile_latest

# npm
npm install -g --package-lock=false < package-backup/npm/global_packages_restore_latest.json

# pip
pip3 install -r package-backup/pip/requirements_latest.txt

# gem
gem install --file=package-backup/gem/Gemfile_latest

# 設定ファイル
./package-backup/scripts/restore-configs.sh
```

## バックアップ内容

各ツールごとに以下の情報をバックアップ：

- インストール済みパッケージリスト
- パッケージ詳細情報
- 復元用ファイル（Brewfile、requirements.txt、Gemfile 等）
- 設定情報
- バージョン情報

設定ファイルについては：

- 個別設定ファイル（.zshrc、.gitconfig 等）
- 設定ディレクトリ（.config、.cursor 等）
- システム情報と環境変数

## 注意事項

- バックアップはパッケージリストと設定ファイルのみを保存します
- 実際のパッケージファイルは保存されません
- 復元時はインターネット接続が必要です
- 一部のパッケージは環境依存のため、完全な復元ができない場合があります
- 設定ファイルの復元時は既存ファイルのバックアップが作成されます

## 詳細情報

より詳細な使用方法やトラブルシューティングについては、[package-backup/README.md](package-backup/README.md) を参照してください。
# Test update

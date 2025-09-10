#!/bin/bash

# gemパッケージバックアップスクリプト
# 作成日: $(date +%Y-%m-%d)
# 説明: gemでインストールされたパッケージのリストをバックアップ

set -euo pipefail

# 設定
BACKUP_DIR="$(dirname "$0")/../gem"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.log"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# バックアップディレクトリの作成
mkdir -p "$BACKUP_DIR"

log "gemバックアップを開始します..."

# Rubyとgemのバージョン情報を保存
log "Rubyとgemバージョン情報を保存中..."
{
    echo "Ruby version:"
    ruby --version
    echo ""
    echo "gem version:"
    gem --version
    echo ""
    echo "Ruby path:"
    which ruby
    echo ""
    echo "gem path:"
    which gem
} > "${BACKUP_DIR}/ruby_gem_version_${TIMESTAMP}.txt"

# インストール済みgemのリストを保存
log "インストール済みgemリストを保存中..."
gem list > "${BACKUP_DIR}/gem_packages_${TIMESTAMP}.txt" 2>/dev/null || log "gemリストの取得に失敗しました"

# インストール済みgemの詳細情報を保存
log "インストール済みgem詳細情報を保存中..."
gem list --details > "${BACKUP_DIR}/gem_packages_details_${TIMESTAMP}.txt" 2>/dev/null || log "gem詳細情報の取得に失敗しました"

# インストール済みgemの名前のみのリストを保存
log "インストール済みgem名リストを保存中..."
gem list --no-versions > "${BACKUP_DIR}/gem_package_names_${TIMESTAMP}.txt" 2>/dev/null || log "gem名リストの取得に失敗しました"

# Gemfileを生成（グローバルgemの復元用）
log "Gemfileを生成中..."
{
    echo "# Global gems backup"
    echo "# Generated on $(date)"
    echo ""
    echo "source 'https://rubygems.org'"
    echo ""
    echo "# Global gems"

    # インストール済みgemの名前とバージョンを取得してGemfile形式で出力
    gem list --no-versions | while read -r gem_name; do
        if [ -n "$gem_name" ]; then
            version=$(gem list "$gem_name" --no-versions --exact 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
            if [ -n "$version" ]; then
                echo "gem '$gem_name', '~> $version'"
            else
                echo "gem '$gem_name'"
            fi
        fi
    done
} > "${BACKUP_DIR}/Gemfile_${TIMESTAMP}" 2>/dev/null || log "Gemfileの生成に失敗しました"

# gem設定情報を保存
log "gem設定情報を保存中..."
gem env > "${BACKUP_DIR}/gem_env_${TIMESTAMP}.txt" 2>/dev/null || log "gem環境情報の取得に失敗しました"

# gemのパス情報を保存
log "gemパス情報を保存中..."
gem which --all > "${BACKUP_DIR}/gem_paths_${TIMESTAMP}.txt" 2>/dev/null || log "gemパス情報の取得に失敗しました"

# 最新のバックアップファイルをシンボリックリンクで管理
log "最新バックアップファイルのシンボリックリンクを作成中..."
ln -sf "ruby_gem_version_${TIMESTAMP}.txt" "${BACKUP_DIR}/ruby_gem_version_latest.txt"
ln -sf "gem_packages_${TIMESTAMP}.txt" "${BACKUP_DIR}/gem_packages_latest.txt"
ln -sf "gem_packages_details_${TIMESTAMP}.txt" "${BACKUP_DIR}/gem_packages_details_latest.txt"
ln -sf "gem_package_names_${TIMESTAMP}.txt" "${BACKUP_DIR}/gem_package_names_latest.txt"
ln -sf "Gemfile_${TIMESTAMP}" "${BACKUP_DIR}/Gemfile_latest"
ln -sf "gem_env_${TIMESTAMP}.txt" "${BACKUP_DIR}/gem_env_latest.txt"
ln -sf "gem_paths_${TIMESTAMP}.txt" "${BACKUP_DIR}/gem_paths_latest.txt"

# 古いバックアップファイルの削除（30日以上古いもの）
log "古いバックアップファイルを削除中..."
find "$BACKUP_DIR" -name "*.txt" -mtime +30 -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "Gemfile_*" -mtime +30 -delete 2>/dev/null || true

# バックアップ完了
log "gemバックアップが完了しました"
log "バックアップファイル: ${BACKUP_DIR}"
log "ログファイル: ${LOG_FILE}"

# バックアップファイルの一覧を表示
echo ""
echo "=== バックアップファイル一覧 ==="
ls -la "$BACKUP_DIR" | grep -E "(latest|${TIMESTAMP})"

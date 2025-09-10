#!/bin/bash

# Homebrewパッケージバックアップスクリプト
# 作成日: $(date +%Y-%m-%d)
# 説明: HomebrewでインストールされたパッケージとCaskのリストをバックアップ

set -euo pipefail

# 設定
BACKUP_DIR="$(dirname "$0")/../homebrew"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.log"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# バックアップディレクトリの作成
mkdir -p "$BACKUP_DIR"

log "Homebrewバックアップを開始します..."

# Homebrewのバージョン情報を保存
log "Homebrewバージョン情報を保存中..."
brew --version > "${BACKUP_DIR}/homebrew_version_${TIMESTAMP}.txt"

# インストール済みパッケージのリストを保存
log "インストール済みパッケージリストを保存中..."
brew list --formula > "${BACKUP_DIR}/brew_formulas_${TIMESTAMP}.txt"

# インストール済みCaskのリストを保存
log "インストール済みCaskリストを保存中..."
brew list --cask > "${BACKUP_DIR}/brew_casks_${TIMESTAMP}.txt"

# 依存関係情報も保存
log "依存関係情報を保存中..."
brew deps --installed --formula > "${BACKUP_DIR}/brew_deps_${TIMESTAMP}.txt"

# brew-fileが使用されている場合のBrewfileも保存
if command -v brew-file >/dev/null 2>&1; then
    log "brew-fileのBrewfileを保存中..."
    brew-file cat > "${BACKUP_DIR}/Brewfile_${TIMESTAMP}" 2>/dev/null || log "Brewfileの取得に失敗しました"
fi

# 手動でBrewfileを生成（brew-fileがない場合のフォールバック）
log "Brewfileを生成中..."
brew bundle dump --file="${BACKUP_DIR}/Brewfile_generated_${TIMESTAMP}" --force

# 最新のバックアップファイルをシンボリックリンクで管理
log "最新バックアップファイルのシンボリックリンクを作成中..."
ln -sf "homebrew_version_${TIMESTAMP}.txt" "${BACKUP_DIR}/homebrew_version_latest.txt"
ln -sf "brew_formulas_${TIMESTAMP}.txt" "${BACKUP_DIR}/brew_formulas_latest.txt"
ln -sf "brew_casks_${TIMESTAMP}.txt" "${BACKUP_DIR}/brew_casks_latest.txt"
ln -sf "brew_deps_${TIMESTAMP}.txt" "${BACKUP_DIR}/brew_deps_latest.txt"
ln -sf "Brewfile_generated_${TIMESTAMP}" "${BACKUP_DIR}/Brewfile_latest"

# 古いバックアップファイルの削除（30日以上古いもの）
log "古いバックアップファイルを削除中..."
find "$BACKUP_DIR" -name "*.txt" -mtime +30 -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "Brewfile_*" -mtime +30 -delete 2>/dev/null || true

# バックアップ完了
log "Homebrewバックアップが完了しました"
log "バックアップファイル: ${BACKUP_DIR}"
log "ログファイル: ${LOG_FILE}"

# バックアップファイルの一覧を表示
echo ""
echo "=== バックアップファイル一覧 ==="
ls -la "$BACKUP_DIR" | grep -E "(latest|${TIMESTAMP})"

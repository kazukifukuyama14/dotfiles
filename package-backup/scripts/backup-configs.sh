#!/bin/bash

# 設定ファイルバックアップスクリプト
# 作成日: $(date +%Y-%m-%d)
# 説明: ホームディレクトリの重要な設定ファイルをバックアップ

set -euo pipefail

# 設定
BACKUP_DIR="$(dirname "$0")/../configs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.log"
HOME_DIR="$HOME"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# エラー関数
error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

# バックアップディレクトリの作成
mkdir -p "$BACKUP_DIR"

log "設定ファイルバックアップを開始します..."
log "ホームディレクトリ: ${HOME_DIR}"
log "バックアップディレクトリ: ${BACKUP_DIR}"

# バックアップ対象の設定ファイルリスト
declare -a CONFIG_FILES=(
    # Shell設定
    ".zshrc"
    ".zprofile"
    ".bashrc"
    ".bash_profile"
    ".profile"

    # Git設定
    ".gitconfig"
    ".gitignore"
    ".gitignore_global"

    # その他の設定ファイル
    ".yarnrc"
    ".stCommitMsg"
    ".hgignore_global"
    ".lesshst"
    ".Brewfile"

    # アプリケーション設定
    ".claude.json"
)

# バックアップ対象の設定ディレクトリリスト
declare -a CONFIG_DIRS=(
    ".config"
    ".cursor"
    ".continue"
    ".claude"
)

# 個別ファイルのバックアップ
log "個別設定ファイルをバックアップ中..."
for file in "${CONFIG_FILES[@]}"; do
    source_file="${HOME_DIR}/${file}"
    if [ -f "$source_file" ]; then
        log "バックアップ中: ${file}"
        cp "$source_file" "${BACKUP_DIR}/${file}_${TIMESTAMP}"
        ln -sf "${file}_${TIMESTAMP}" "${BACKUP_DIR}/${file}_latest"
    else
        log "ファイルが見つかりません: ${file}"
    fi
done

# 設定ディレクトリのバックアップ
log "設定ディレクトリをバックアップ中..."
for dir in "${CONFIG_DIRS[@]}"; do
    source_dir="${HOME_DIR}/${dir}"
    if [ -d "$source_dir" ]; then
        log "バックアップ中: ${dir}/"
        tar -czf "${BACKUP_DIR}/${dir}_${TIMESTAMP}.tar.gz" -C "$HOME_DIR" "$dir"
        ln -sf "${dir}_${TIMESTAMP}.tar.gz" "${BACKUP_DIR}/${dir}_latest.tar.gz"
    else
        log "ディレクトリが見つかりません: ${dir}/"
    fi
done

# 特定の設定ファイルの個別バックアップ
log "特定の設定ファイルを個別バックアップ中..."

# starship.toml
if [ -f "${HOME_DIR}/.config/starship.toml" ]; then
    log "starship.tomlをバックアップ中..."
    cp "${HOME_DIR}/.config/starship.toml" "${BACKUP_DIR}/starship.toml_${TIMESTAMP}"
    ln -sf "starship.toml_${TIMESTAMP}" "${BACKUP_DIR}/starship.toml_latest"
fi

# VS Code設定（もしあれば）
if [ -d "${HOME_DIR}/.vscode" ]; then
    log "VS Code設定をバックアップ中..."
    tar -czf "${BACKUP_DIR}/vscode_${TIMESTAMP}.tar.gz" -C "$HOME_DIR" ".vscode"
    ln -sf "vscode_${TIMESTAMP}.tar.gz" "${BACKUP_DIR}/vscode_latest.tar.gz"
fi

# SSH設定（もしあれば）
if [ -d "${HOME_DIR}/.ssh" ]; then
    log "SSH設定をバックアップ中..."
    tar -czf "${BACKUP_DIR}/ssh_${TIMESTAMP}.tar.gz" -C "$HOME_DIR" ".ssh"
    ln -sf "ssh_${TIMESTAMP}.tar.gz" "${BACKUP_DIR}/ssh_latest.tar.gz"
fi

# システム情報の保存
log "システム情報を保存中..."
{
    echo "=== システム情報 ==="
    echo "OS: $(uname -s)"
    echo "Architecture: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "Home Directory: $HOME"
    echo "Shell: $SHELL"
    echo "Date: $(date)"
    echo ""
    echo "=== 環境変数 ==="
    env | sort
} > "${BACKUP_DIR}/system_info_${TIMESTAMP}.txt"
ln -sf "system_info_${TIMESTAMP}.txt" "${BACKUP_DIR}/system_info_latest.txt"

# 古いバックアップファイルの削除（30日以上古いもの）
log "古いバックアップファイルを削除中..."
find "$BACKUP_DIR" -name "*_${TIMESTAMP:0:8}*" -mtime +30 -delete 2>/dev/null || true

# バックアップ完了
log "設定ファイルバックアップが完了しました"
log "バックアップファイル: ${BACKUP_DIR}"
log "ログファイル: ${LOG_FILE}"

# バックアップファイルの一覧を表示
echo ""
echo "=== バックアップファイル一覧 ==="
ls -la "$BACKUP_DIR" | grep -E "(latest|${TIMESTAMP})"

# バックアップサマリー
echo ""
echo "=== バックアップサマリー ==="
echo "個別ファイル: $(find "$BACKUP_DIR" -name "*_latest" -type f | wc -l)"
echo "アーカイブファイル: $(find "$BACKUP_DIR" -name "*_latest.tar.gz" -type f | wc -l)"
echo "合計: $(find "$BACKUP_DIR" -name "*_latest*" -type f | wc -l)"

#!/bin/bash

# 軽量設定ファイルバックアップスクリプト（GitHub用）
# 作成日: $(date +%Y-%m-%d)
# 説明: GitHubにプッシュするための軽量な設定ファイルバックアップ

set -euo pipefail

# 設定
BACKUP_DIR="$(dirname "$0")/../configs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${BACKUP_DIR}/backup_light_${TIMESTAMP}.log"
HOME_DIR="$HOME"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# バックアップディレクトリの作成
mkdir -p "$BACKUP_DIR"

log "軽量設定ファイルバックアップを開始します..."

# バックアップ対象の設定ファイルリスト（軽量版）
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

# 特定の設定ファイルの個別バックアップ
log "特定の設定ファイルを個別バックアップ中..."

# starship.toml
if [ -f "${HOME_DIR}/.config/starship.toml" ]; then
    log "starship.tomlをバックアップ中..."
    cp "${HOME_DIR}/.config/starship.toml" "${BACKUP_DIR}/starship.toml_${TIMESTAMP}"
    ln -sf "starship.toml_${TIMESTAMP}" "${BACKUP_DIR}/starship.toml_latest"
fi

# 重要な設定ファイルのみを個別にバックアップ
log "重要な設定ファイルを個別バックアップ中..."

# .configディレクトリから重要なファイルのみをコピー
if [ -d "${HOME_DIR}/.config" ]; then
    mkdir -p "${BACKUP_DIR}/config_files_${TIMESTAMP}"

    # 重要な設定ファイルのみをコピー
    for config_file in "starship.toml" "git/config" "nvim/init.lua" "nvim/init.vim"; do
        if [ -f "${HOME_DIR}/.config/${config_file}" ]; then
            mkdir -p "${BACKUP_DIR}/config_files_${TIMESTAMP}/$(dirname "$config_file")"
            cp "${HOME_DIR}/.config/${config_file}" "${BACKUP_DIR}/config_files_${TIMESTAMP}/${config_file}"
            log "設定ファイルをバックアップ: ${config_file}"
        fi
    done

    # ディレクトリが空でない場合のみアーカイブ
    if [ "$(find "${BACKUP_DIR}/config_files_${TIMESTAMP}" -type f | wc -l)" -gt 0 ]; then
        tar -czf "${BACKUP_DIR}/config_files_${TIMESTAMP}.tar.gz" -C "${BACKUP_DIR}" "config_files_${TIMESTAMP}"
        rm -rf "${BACKUP_DIR}/config_files_${TIMESTAMP}"
        ln -sf "config_files_${TIMESTAMP}.tar.gz" "${BACKUP_DIR}/config_files_latest.tar.gz"
    fi
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

# バックアップ完了
log "軽量設定ファイルバックアップが完了しました"
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
echo "総サイズ: $(du -sh "$BACKUP_DIR" | cut -f1)"

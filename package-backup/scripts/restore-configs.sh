#!/bin/bash

# 設定ファイル復元スクリプト
# 作成日: $(date +%Y-%m-%d)
# 説明: バックアップから設定ファイルを復元

set -euo pipefail

# 設定
SCRIPT_DIR="$(dirname "$0")"
BACKUP_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_BACKUP_DIR="${BACKUP_ROOT}/configs"
HOME_DIR="$HOME"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# エラー関数
error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"
}

# 確認関数
confirm() {
    local message="$1"
    echo -n "$message (y/N): "
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# バックアップファイルの存在確認
check_backup_file() {
    local file="$1"
    if [ -f "${CONFIG_BACKUP_DIR}/${file}_latest" ]; then
        return 0
    else
        error "バックアップファイルが見つかりません: ${file}_latest"
        return 1
    fi
}

# 個別ファイルの復元
restore_file() {
    local file="$1"
    local backup_file="${CONFIG_BACKUP_DIR}/${file}_latest"
    local target_file="${HOME_DIR}/${file}"

    if check_backup_file "$file"; then
        log "復元中: ${file}"

        # 既存ファイルのバックアップ
        if [ -f "$target_file" ]; then
            if confirm "既存の ${file} をバックアップして上書きしますか？"; then
                cp "$target_file" "${target_file}.backup.$(date +%Y%m%d_%H%M%S)"
                cp "$backup_file" "$target_file"
                log "${file} を復元しました"
            else
                log "${file} の復元をスキップしました"
            fi
        else
            cp "$backup_file" "$target_file"
            log "${file} を復元しました"
        fi
    fi
}

# アーカイブファイルの復元
restore_archive() {
    local archive_name="$1"
    local backup_file="${CONFIG_BACKUP_DIR}/${archive_name}_latest.tar.gz"
    local target_dir="${HOME_DIR}/${archive_name}"

    if [ -f "$backup_file" ]; then
        log "復元中: ${archive_name}/"

        # 既存ディレクトリのバックアップ
        if [ -d "$target_dir" ]; then
            if confirm "既存の ${archive_name}/ をバックアップして上書きしますか？"; then
                mv "$target_dir" "${target_dir}.backup.$(date +%Y%m%d_%H%M%S)"
                tar -xzf "$backup_file" -C "$HOME_DIR"
                log "${archive_name}/ を復元しました"
            else
                log "${archive_name}/ の復元をスキップしました"
            fi
        else
            tar -xzf "$backup_file" -C "$HOME_DIR"
            log "${archive_name}/ を復元しました"
        fi
    else
        error "バックアップファイルが見つかりません: ${archive_name}_latest.tar.gz"
    fi
}

# メイン処理開始
log "設定ファイル復元を開始します..."
log "バックアップディレクトリ: ${CONFIG_BACKUP_DIR}"
log "ホームディレクトリ: ${HOME_DIR}"

# バックアップディレクトリの存在確認
if [ ! -d "$CONFIG_BACKUP_DIR" ]; then
    error "バックアップディレクトリが見つかりません: ${CONFIG_BACKUP_DIR}"
    exit 1
fi

# 復元対象の設定ファイルリスト
declare -a CONFIG_FILES=(
    ".zshrc"
    ".zprofile"
    ".bashrc"
    ".bash_profile"
    ".profile"
    ".gitconfig"
    ".gitignore"
    ".gitignore_global"
    ".yarnrc"
    ".stCommitMsg"
    ".hgignore_global"
    ".lesshst"
    ".Brewfile"
    ".claude.json"
)

# 復元対象の設定ディレクトリリスト
declare -a CONFIG_DIRS=(
    ".config"
    ".cursor"
    ".continue"
    ".claude"
    ".vscode"
    ".ssh"
)

# 復元実行カウンター
success_count=0
total_count=0

# 個別ファイルの復元
log "=== 個別設定ファイルの復元 ==="
for file in "${CONFIG_FILES[@]}"; do
    total_count=$((total_count + 1))
    if restore_file "$file"; then
        success_count=$((success_count + 1))
    fi
done

# アーカイブファイルの復元
log "=== 設定ディレクトリの復元 ==="
for dir in "${CONFIG_DIRS[@]}"; do
    total_count=$((total_count + 1))
    if restore_archive "$dir"; then
        success_count=$((success_count + 1))
    fi
done

# starship.tomlの個別復元
if [ -f "${CONFIG_BACKUP_DIR}/starship.toml_latest" ]; then
    total_count=$((total_count + 1))
    log "starship.tomlを復元中..."
    if confirm "starship.tomlを復元しますか？"; then
        mkdir -p "${HOME_DIR}/.config"
        cp "${CONFIG_BACKUP_DIR}/starship.toml_latest" "${HOME_DIR}/.config/starship.toml"
        log "starship.tomlを復元しました"
        success_count=$((success_count + 1))
    else
        log "starship.tomlの復元をスキップしました"
    fi
fi

# 復元結果のサマリー
log "=== 復元完了サマリー ==="
log "成功: ${success_count}/${total_count}"
log "失敗: $((total_count - success_count))/${total_count}"

if [ $success_count -eq $total_count ]; then
    log "すべての設定ファイルの復元が正常に完了しました！"
    log "新しいターミナルを開いて設定を反映してください。"
    exit 0
else
    error "一部の設定ファイルの復元が失敗しました。ログを確認してください。"
    exit 1
fi

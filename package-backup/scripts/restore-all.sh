#!/bin/bash

# 全パッケージ管理ツール復元スクリプト
# 作成日: $(date +%Y-%m-%d)
# 説明: バックアップからパッケージ管理ツールの環境を復元

set -euo pipefail

# 設定
SCRIPT_DIR="$(dirname "$0")"
BACKUP_ROOT="$(dirname "$SCRIPT_DIR")"

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

# Homebrew復元
restore_homebrew() {
    log "=== Homebrew復元 ==="

    local brewfile="${BACKUP_ROOT}/homebrew/Brewfile_latest"
    if [ -f "$brewfile" ]; then
        log "Brewfileが見つかりました: $brewfile"
        if confirm "Homebrewパッケージを復元しますか？"; then
            log "Homebrewパッケージを復元中..."
            brew bundle --file="$brewfile"
            log "Homebrew復元が完了しました"
        else
            log "Homebrew復元をスキップしました"
        fi
    else
        error "Brewfileが見つかりません: $brewfile"
    fi
}

# npm復元
restore_npm() {
    log "=== npm復元 ==="

    local package_json="${BACKUP_ROOT}/npm/global_packages_restore_latest.json"
    if [ -f "$package_json" ]; then
        log "グローバルパッケージ復元用package.jsonが見つかりました: $package_json"
        if confirm "npmグローバルパッケージを復元しますか？"; then
            log "npmグローバルパッケージを復元中..."
            # package.jsonから依存関係を読み取ってインストール
            npm install -g --package-lock=false < "$package_json"
            log "npm復元が完了しました"
        else
            log "npm復元をスキップしました"
        fi
    else
        error "グローバルパッケージ復元用package.jsonが見つかりません: $package_json"
    fi
}

# pip復元
restore_pip() {
    log "=== pip復元 ==="

    local requirements="${BACKUP_ROOT}/pip/requirements_latest.txt"
    if [ -f "$requirements" ]; then
        log "requirements.txtが見つかりました: $requirements"
        if confirm "pipパッケージを復元しますか？"; then
            log "pipパッケージを復元中..."
            pip3 install -r "$requirements"
            log "pip復元が完了しました"
        else
            log "pip復元をスキップしました"
        fi
    else
        error "requirements.txtが見つかりません: $requirements"
    fi
}

# gem復元
restore_gem() {
    log "=== gem復元 ==="

    local gemfile="${BACKUP_ROOT}/gem/Gemfile_latest"
    if [ -f "$gemfile" ]; then
        log "Gemfileが見つかりました: $gemfile"
        if confirm "gemパッケージを復元しますか？"; then
            log "gemパッケージを復元中..."
            gem install --file="$gemfile"
            log "gem復元が完了しました"
        else
            log "gem復元をスキップしました"
        fi
    else
        error "Gemfileが見つかりません: $gemfile"
    fi
}

# 設定ファイル復元
restore_configs() {
    log "=== 設定ファイル復元 ==="

    local config_script="${SCRIPT_DIR}/restore-configs.sh"
    if [ -f "$config_script" ]; then
        log "設定ファイル復元スクリプトが見つかりました: $config_script"
        if confirm "設定ファイルを復元しますか？"; then
            log "設定ファイルを復元中..."
            "$config_script"
            log "設定ファイル復元が完了しました"
        else
            log "設定ファイル復元をスキップしました"
        fi
    else
        error "設定ファイル復元スクリプトが見つかりません: $config_script"
    fi
}

# メイン処理開始
log "パッケージ管理ツールの復元を開始します..."
log "バックアップルート: ${BACKUP_ROOT}"

# 復元実行カウンター
success_count=0
total_count=0

# Homebrew復元
total_count=$((total_count + 1))
if restore_homebrew; then
    success_count=$((success_count + 1))
fi

# npm復元
total_count=$((total_count + 1))
if restore_npm; then
    success_count=$((success_count + 1))
fi

# pip復元
total_count=$((total_count + 1))
if restore_pip; then
    success_count=$((success_count + 1))
fi

# gem復元
total_count=$((total_count + 1))
if restore_gem; then
    success_count=$((success_count + 1))
fi

# 設定ファイル復元
total_count=$((total_count + 1))
if restore_configs; then
    success_count=$((success_count + 1))
fi

# 復元結果のサマリー
log "=== 復元完了サマリー ==="
log "成功: ${success_count}/${total_count}"
log "失敗: $((total_count - success_count))/${total_count}"

if [ $success_count -eq $total_count ]; then
    log "すべての復元が正常に完了しました！"
    exit 0
else
    error "一部の復元が失敗しました。ログを確認してください。"
    exit 1
fi

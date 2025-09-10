#!/bin/bash

# 全パッケージ管理ツールバックアップスクリプト
# 作成日: $(date +%Y-%m-%d)
# 説明: すべてのパッケージ管理ツールのバックアップを一括実行

set -euo pipefail

# 設定
SCRIPT_DIR="$(dirname "$0")"
BACKUP_ROOT="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${BACKUP_ROOT}/backup_all_${TIMESTAMP}.log"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# エラー関数
error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

# バックアップ実行関数
run_backup() {
    local script_name="$1"
    local tool_name="$2"

    log "=== ${tool_name}バックアップを開始 ==="

    if [ -f "${SCRIPT_DIR}/${script_name}" ]; then
        if "${SCRIPT_DIR}/${script_name}"; then
            log "=== ${tool_name}バックアップが完了 ==="
            return 0
        else
            error "=== ${tool_name}バックアップが失敗 ==="
            return 1
        fi
    else
        error "バックアップスクリプトが見つかりません: ${script_name}"
        return 1
    fi
}

# メイン処理開始
log "全パッケージ管理ツールのバックアップを開始します..."
log "バックアップルート: ${BACKUP_ROOT}"
log "ログファイル: ${LOG_FILE}"

# バックアップ実行カウンター
success_count=0
total_count=0

# Homebrewバックアップ
total_count=$((total_count + 1))
if run_backup "backup-homebrew.sh" "Homebrew"; then
    success_count=$((success_count + 1))
fi

# npmバックアップ
total_count=$((total_count + 1))
if run_backup "backup-npm.sh" "npm"; then
    success_count=$((success_count + 1))
fi

# pipバックアップ
total_count=$((total_count + 1))
if run_backup "backup-pip.sh" "pip"; then
    success_count=$((success_count + 1))
fi

# gemバックアップ
total_count=$((total_count + 1))
if run_backup "backup-gem.sh" "gem"; then
    success_count=$((success_count + 1))
fi

# 設定ファイルバックアップ
total_count=$((total_count + 1))
if run_backup "backup-configs.sh" "設定ファイル"; then
    success_count=$((success_count + 1))
fi

# バックアップ結果のサマリー
log "=== バックアップ完了サマリー ==="
log "成功: ${success_count}/${total_count}"
log "失敗: $((total_count - success_count))/${total_count}"

if [ $success_count -eq $total_count ]; then
    log "すべてのバックアップが正常に完了しました！"
    exit 0
else
    error "一部のバックアップが失敗しました。ログを確認してください。"
    exit 1
fi

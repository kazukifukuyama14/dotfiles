#!/bin/bash

# pipパッケージバックアップスクリプト
# 作成日: $(date +%Y-%m-%d)
# 説明: pipでインストールされたパッケージのリストをバックアップ

set -euo pipefail

# 設定
BACKUP_DIR="$(dirname "$0")/../pip"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.log"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# バックアップディレクトリの作成
mkdir -p "$BACKUP_DIR"

log "pipバックアップを開始します..."

# Pythonとpipのバージョン情報を保存
log "Pythonとpipバージョン情報を保存中..."
{
    echo "Python version:"
    python3 --version
    echo ""
    echo "pip version:"
    pip3 --version
    echo ""
    echo "Python path:"
    which python3
    echo ""
    echo "pip path:"
    which pip3
} > "${BACKUP_DIR}/python_pip_version_${TIMESTAMP}.txt"

# インストール済みパッケージのリストを保存
log "インストール済みパッケージリストを保存中..."
pip3 list > "${BACKUP_DIR}/pip_packages_${TIMESTAMP}.txt" 2>/dev/null || log "パッケージリストの取得に失敗しました"

# インストール済みパッケージの詳細情報を保存（JSON形式）
log "インストール済みパッケージ詳細情報を保存中..."
pip3 list --format=json > "${BACKUP_DIR}/pip_packages_json_${TIMESTAMP}.json" 2>/dev/null || log "パッケージ詳細情報の取得に失敗しました"

# インストール済みパッケージの名前のみのリストを保存
log "インストール済みパッケージ名リストを保存中..."
pip3 list --format=freeze > "${BACKUP_DIR}/pip_packages_freeze_${TIMESTAMP}.txt" 2>/dev/null || log "パッケージ名リストの取得に失敗しました"

# requirements.txtを生成
log "requirements.txtを生成中..."
pip3 freeze > "${BACKUP_DIR}/requirements_${TIMESTAMP}.txt" 2>/dev/null || log "requirements.txtの生成に失敗しました"

# pip設定情報を保存
log "pip設定情報を保存中..."
pip3 config list > "${BACKUP_DIR}/pip_config_${TIMESTAMP}.txt" 2>/dev/null || log "pip設定情報の取得に失敗しました"

# pipキャッシュ情報を保存
log "pipキャッシュ情報を保存中..."
pip3 cache info > "${BACKUP_DIR}/pip_cache_info_${TIMESTAMP}.txt" 2>/dev/null || log "pipキャッシュ情報の取得に失敗しました"

# 仮想環境の情報を保存（もしあれば）
if [ -n "${VIRTUAL_ENV:-}" ]; then
    log "仮想環境情報を保存中..."
    {
        echo "Virtual environment: $VIRTUAL_ENV"
        echo "Virtual environment Python: $(which python)"
        echo "Virtual environment pip: $(which pip)"
    } > "${BACKUP_DIR}/virtual_env_info_${TIMESTAMP}.txt"
fi

# 最新のバックアップファイルをシンボリックリンクで管理
log "最新バックアップファイルのシンボリックリンクを作成中..."
ln -sf "python_pip_version_${TIMESTAMP}.txt" "${BACKUP_DIR}/python_pip_version_latest.txt"
ln -sf "pip_packages_${TIMESTAMP}.txt" "${BACKUP_DIR}/pip_packages_latest.txt"
ln -sf "pip_packages_json_${TIMESTAMP}.json" "${BACKUP_DIR}/pip_packages_json_latest.json"
ln -sf "pip_packages_freeze_${TIMESTAMP}.txt" "${BACKUP_DIR}/pip_packages_freeze_latest.txt"
ln -sf "requirements_${TIMESTAMP}.txt" "${BACKUP_DIR}/requirements_latest.txt"
ln -sf "pip_config_${TIMESTAMP}.txt" "${BACKUP_DIR}/pip_config_latest.txt"
ln -sf "pip_cache_info_${TIMESTAMP}.txt" "${BACKUP_DIR}/pip_cache_info_latest.txt"

# 古いバックアップファイルの削除（30日以上古いもの）
log "古いバックアップファイルを削除中..."
find "$BACKUP_DIR" -name "*.txt" -mtime +30 -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "*.json" -mtime +30 -delete 2>/dev/null || true

# バックアップ完了
log "pipバックアップが完了しました"
log "バックアップファイル: ${BACKUP_DIR}"
log "ログファイル: ${LOG_FILE}"

# バックアップファイルの一覧を表示
echo ""
echo "=== バックアップファイル一覧 ==="
ls -la "$BACKUP_DIR" | grep -E "(latest|${TIMESTAMP})"

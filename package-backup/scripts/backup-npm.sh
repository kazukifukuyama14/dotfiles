#!/bin/bash

# npmパッケージバックアップスクリプト
# 作成日: $(date +%Y-%m-%d)
# 説明: npmでインストールされたパッケージのリストをバックアップ

set -euo pipefail

# 設定
BACKUP_DIR="$(dirname "$0")/../npm"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.log"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# バックアップディレクトリの作成
mkdir -p "$BACKUP_DIR"

log "npmバックアップを開始します..."

# Node.jsとnpmのバージョン情報を保存
log "Node.jsとnpmバージョン情報を保存中..."
{
    echo "Node.js version:"
    node --version
    echo ""
    echo "npm version:"
    npm --version
    echo ""
    echo "npx version:"
    npx --version
} > "${BACKUP_DIR}/node_npm_version_${TIMESTAMP}.txt"

# グローバルにインストールされたパッケージのリストを保存
log "グローバルパッケージリストを保存中..."
npm list -g --depth=0 > "${BACKUP_DIR}/npm_global_packages_${TIMESTAMP}.txt" 2>/dev/null || log "グローバルパッケージリストの取得に失敗しました"

# グローバルパッケージの詳細情報を保存
log "グローバルパッケージ詳細情報を保存中..."
npm list -g --depth=0 --json > "${BACKUP_DIR}/npm_global_packages_json_${TIMESTAMP}.json" 2>/dev/null || log "グローバルパッケージ詳細情報の取得に失敗しました"

# グローバルパッケージの名前のみのリストを保存
log "グローバルパッケージ名リストを保存中..."
npm list -g --depth=0 --parseable --long | cut -d: -f2 | sed 's/.*\///' > "${BACKUP_DIR}/npm_global_package_names_${TIMESTAMP}.txt" 2>/dev/null || log "グローバルパッケージ名リストの取得に失敗しました"

# 現在のディレクトリのpackage.jsonがある場合のバックアップ
if [ -f "package.json" ]; then
    log "現在のディレクトリのpackage.jsonをバックアップ中..."
    cp package.json "${BACKUP_DIR}/package_json_${TIMESTAMP}.json"
fi

# npm設定情報を保存
log "npm設定情報を保存中..."
npm config list > "${BACKUP_DIR}/npm_config_${TIMESTAMP}.txt" 2>/dev/null || log "npm設定情報の取得に失敗しました"

# npmキャッシュ情報を保存
log "npmキャッシュ情報を保存中..."
npm cache verify > "${BACKUP_DIR}/npm_cache_info_${TIMESTAMP}.txt" 2>/dev/null || log "npmキャッシュ情報の取得に失敗しました"

# グローバルパッケージの復元用package.jsonを生成
log "グローバルパッケージ復元用package.jsonを生成中..."
{
    echo "{"
    echo "  \"name\": \"global-packages-backup\","
    echo "  \"version\": \"1.0.0\","
    echo "  \"description\": \"Global npm packages backup\","
    echo "  \"dependencies\": {"

    # グローバルパッケージの名前とバージョンを取得
    npm list -g --depth=0 --json 2>/dev/null | jq -r '.dependencies | to_entries[] | "    \"" + .key + "\": \"" + .value.version + "\","' 2>/dev/null || {
        # jqがない場合は手動でパース
        npm list -g --depth=0 2>/dev/null | grep -E '^├──|^└──' | sed 's/.*@/"/' | sed 's/@/": "/' | sed 's/$/",/' | sed 's/^/    /' || true
    }

    echo "  }"
    echo "}"
} > "${BACKUP_DIR}/global_packages_restore_${TIMESTAMP}.json"

# 最新のバックアップファイルをシンボリックリンクで管理
log "最新バックアップファイルのシンボリックリンクを作成中..."
ln -sf "node_npm_version_${TIMESTAMP}.txt" "${BACKUP_DIR}/node_npm_version_latest.txt"
ln -sf "npm_global_packages_${TIMESTAMP}.txt" "${BACKUP_DIR}/npm_global_packages_latest.txt"
ln -sf "npm_global_packages_json_${TIMESTAMP}.json" "${BACKUP_DIR}/npm_global_packages_json_latest.json"
ln -sf "npm_global_package_names_${TIMESTAMP}.txt" "${BACKUP_DIR}/npm_global_package_names_latest.txt"
ln -sf "npm_config_${TIMESTAMP}.txt" "${BACKUP_DIR}/npm_config_latest.txt"
ln -sf "npm_cache_info_${TIMESTAMP}.txt" "${BACKUP_DIR}/npm_cache_info_latest.txt"
ln -sf "global_packages_restore_${TIMESTAMP}.json" "${BACKUP_DIR}/global_packages_restore_latest.json"

# 古いバックアップファイルの削除（30日以上古いもの）
log "古いバックアップファイルを削除中..."
find "$BACKUP_DIR" -name "*.txt" -mtime +30 -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "*.json" -mtime +30 -delete 2>/dev/null || true

# バックアップ完了
log "npmバックアップが完了しました"
log "バックアップファイル: ${BACKUP_DIR}"
log "ログファイル: ${LOG_FILE}"

# バックアップファイルの一覧を表示
echo ""
echo "=== バックアップファイル一覧 ==="
ls -la "$BACKUP_DIR" | grep -E "(latest|${TIMESTAMP})"

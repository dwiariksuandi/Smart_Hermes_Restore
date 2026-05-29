#!/usr/bin/env bash
# Hermes Control Plane - One-Click Backup Script

set -euo pipefail

HERMES_HOME="$HOME/.hermes"
LOG_FILE="$HERMES_HOME/logs/backup.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log_msg() {
    echo "[$(date -Iseconds)] $1" | tee -a "$LOG_FILE"
}

cd "$HERMES_HOME"

log_msg "🚀 Backup started at $TIMESTAMP"

# 1. Stage all valid changes
log_msg "📥 Staging changes..."
# Only add files that are NOT in .gitignore and are NOT huge
find . -type f \
    -not -path './hermes-agent/venv/*' \
    -not -path './.git/*' \
    -not -path './mcp_servers/*/venv/*' \
    -not -path './logs/*' \
    -not -path './sessions/*' \
    -not -path './state.db*' \
    -not -path './audio_cache/*' \
    -not -path './image_cache/*' \
    -not -name '.env' \
    -not -name '*.bak*' \
    -not -name '*.tmp' \
    -not -name '*.log' \
    -print0 | xargs -0 git add -A 2>/dev/null || true

# 2. Create commit
COMMIT_MSG="[AUTO-BACKUP] $TIMESTAMP - State sync from $(hostname)"
if git diff --cached --quiet; then
    log_msg "✅ No changes to commit. Backup up to date."
else
    git commit -m "$COMMIT_MSG"
    log_msg "📋 Created commit: $COMMIT_MSG"
fi

# 3. Push to remote
log_msg "🚀 Pushing to GitHub..."
git push origin main

log_msg "✅ Backup complete. SHA: $(git rev-parse --short HEAD)"

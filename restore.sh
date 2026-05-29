#!/usr/bin/env bash
# Hermes Control Plane - One-Click Restore Script
# Usage: curl -sSL https://raw.githubusercontent.com/dwiariksuandi/hermes-control-plane/main/restore.sh | bash

set -euo pipefail

HERMES_HOME="$HOME/.hermes"
REPO_URL="git@github.com:dwiariksuandi/hermes-control-plane.git"

echo "🚀 Starting Hermes Restore..."

# 1. SSH Check
if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "❌ SSH Key not found or not authorized for GitHub. Please add your key first."
    exit 1
fi

# 2. Clone/Pull Repo
if [ ! -d "$HERMES_HOME/.git" ]; then
    echo "📂 Cloning Control Plane..."
    git clone "$REPO_URL" "$HERMES_HOME"
else
    echo "🔄 Updating Control Plane..."
    git -C "$HERMES_HOME" pull origin main
fi

cd "$HERMES_HOME"

# 3. Rebuild Virtual Environments
echo "📦 Rebuilding Virtual Environments..."
# Hermes Agent venv
python3 -m venv "$HERMES_HOME/hermes-agent/venv"
"$HERMES_HOME/hermes-agent/venv/bin/pip" install -e "$HERMES_HOME/hermes-agent"

# Composio MCP venv
if [ -d "mcp_servers/composio" ]; then
    python3 -m venv "mcp_servers/composio/venv"
    "mcp_servers/composio/venv/bin/pip" install composio_core mcp
fi

# 4. Setup Systemd Gateway
echo "⚙️ Installing Gateway Service..."
"$HERMES_HOME/hermes-agent/venv/bin/hermes" gateway install --yolo

# 5. Restore Symlinks
echo "🔗 Restoring Memory Links..."
ln -sf "$HERMES_HOME/vault/MEMORY.md" "$HERMES_HOME/MEMORY.md"
ln -sf "$HERMES_HOME/vault/USER.md" "$HERMES_HOME/USER.md"

# 6. Final Health Check
echo "🔍 Running Health Check..."
"$HERMES_HOME/hermes-agent/venv/bin/hermes" doctor

echo "✅ RESTORE COMPLETE. Run 'hermes' to start."

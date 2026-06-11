#!/usr/bin/env bash
# run_all.sh — Runs Python and Java programs, saves logs.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/run_$TIMESTAMP.log"

mkdir -p "$LOG_DIR"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "============================================"
log "   MULTI-LANGUAGE CI/CD RUNNER"
log "============================================"
log "Repo root : $REPO_ROOT"
log "Log file  : $LOG_FILE"

# ── Python ──────────────────────────────────────
log ""
log ">>> Running Python program..."
if command -v python3 &>/dev/null; then
    python3 "$REPO_ROOT/python/stats.py" 2>&1 | tee -a "$LOG_FILE"
    log "Python program completed successfully."
else
    log "ERROR: python3 not found. Install it and retry."
    exit 1
fi

# ── Java ─────────────────────────────────────────
log ""
log ">>> Compiling and running Java program..."
if command -v javac &>/dev/null && command -v java &>/dev/null; then
    JAVA_TMP=$(mktemp -d)
    trap 'rm -rf "$JAVA_TMP"' EXIT
    cp "$REPO_ROOT/java/Stats.java" "$JAVA_TMP/"
    javac "$JAVA_TMP/Stats.java" -d "$JAVA_TMP" 2>&1 | tee -a "$LOG_FILE"
    java -cp "$JAVA_TMP" Stats 2>&1 | tee -a "$LOG_FILE"
    log "Java program completed successfully."
else
    log "ERROR: javac/java not found. Install JDK and retry."
    exit 1
fi

log ""
log "============================================"
log "   ALL PROGRAMS COMPLETED SUCCESSFULLY"
log "============================================"
log "Full log saved to: $LOG_FILE"

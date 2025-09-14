#!/usr/bin/env bash
# Usage: ./script/begin_experiment.sh 001

set -euo pipefail

EXP_ID="${1:-}"
[ -n "$EXP_ID" ] || { echo "[ERROR] Missing EXP_ID. Usage: ./script/begin_experiment.sh 001"; exit 1; }

BASE_DIR="./artifacts/runs_${EXP_ID}"
EXP_FILE=".exp_online"

# --- Pre-checks: Git repo & branch must NOT be 'dev'
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[ERROR] Not a Git repository."
  exit 1
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "$CURRENT_BRANCH" = "dev" ]; then
  echo "[ERROR] You are on 'dev'. Create and switch to a new experiment branch before starting."
  echo "        e.g.: git checkout -b exp/${EXP_ID}"
  exit 1
fi

# 1. Check if .exp_online file exists and is blank
if [ ! -f "$EXP_FILE" ]; then
  echo "" > "$EXP_FILE"
fi

CURRENT_EXP="$(cat "$EXP_FILE")"
if [ -n "$CURRENT_EXP" ]; then
  echo "[ERROR] Experiment already running: $CURRENT_EXP"
  echo "        Please clear $EXP_FILE before starting a new experiment."
  exit 1
fi

# 2. Create experiment folder structure
mkdir -p "${BASE_DIR}/notebooks" \
         "${BASE_DIR}/data/processed" \
         "${BASE_DIR}/logs" \
         "${BASE_DIR}/models" \
         "${BASE_DIR}/reports"

# Create report.md with template
REPORT_FILE="${BASE_DIR}/reports/report.md"
if [ ! -f "$REPORT_FILE" ]; then
  cat <<EOL > "$REPORT_FILE"
# Exp ${EXP_ID}

## Date

## Aim

## Metrics

## Issues

## Signature

EOL
fi

# 3. Write experiment ID to .exp_online
echo "$EXP_ID" > "$EXP_FILE"

echo "[OK] Experiment ${EXP_ID} initialized at ${BASE_DIR}"
echo "[INFO] Current branch: ${CURRENT_BRANCH} (not 'dev')"
echo "[HINT] When finished, run ./script/end_experiment.sh to close and log this experiment."

#!/usr/bin/env bash
# Usage: ./script/end_experiment.sh
# Steps:
# 1) Check if .exp_online is empty
# 2) Check if report.md has a signature under "## Signature"
# 3) Ensure the Git work tree is clean
# 4) If all checks pass, log Aim/Date/Signature to ./experiment_log.md and clear .exp_online
# 5) Switch branch back to dev

set -euo pipefail

EXP_FILE=".exp_online"
LOG_FILE="./experiment_log.md"

err() { echo "[ERROR] $*" >&2; exit 1; }
info() { echo "[INFO] $*"; }

# ---------- 1) Check .exp_online ----------
if [ ! -f "$EXP_FILE" ]; then
  err "File $EXP_FILE not found."
fi

if [ ! -s "$EXP_FILE" ]; then
  err "$EXP_FILE is empty: no experiment is currently running."
fi

EXP_ID=$(cat "$EXP_FILE" | tr -d '[:space:]')
if [ -z "$EXP_ID" ]; then
  err "$EXP_FILE content is blank: no experiment is currently running."
fi
info "Current experiment: $EXP_ID"

REPORT_FILE="./artifacts/runs_${EXP_ID}/reports/report.md"
[ -f "$REPORT_FILE" ] || err "Report file not found: $REPORT_FILE"

# ---------- 2) Check Signature ----------
SIGN_SECTION="$(awk '
  BEGIN{flag=0}
  /^##[[:space:]]+Signature[[:space:]]*$/ {flag=1; next}
  /^##[[:space:]]+/ && flag==1 {flag=0}
  flag==1 {print}
' "$REPORT_FILE" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

SIGN_LINE="$(printf "%s\n" "$SIGN_SECTION" | awk 'NF{print; exit}')"

if [ -z "${SIGN_LINE:-}" ]; then
  err "Report is missing a signature: please fill in the \"## Signature\" section (e.g., C.L.)."
fi

if ! printf "%s" "$SIGN_LINE" | grep -Eq '[A-Za-z]'; then
  err "Invalid signature: \"$SIGN_LINE\". Please provide a valid name or initials."
fi
if printf "%s" "$SIGN_LINE" | grep -Eq '^(TBD|None|N/A|-|—|——)$'; then
  err "Signature is still a placeholder: \"$SIGN_LINE\". Please provide a real signature."
fi
info "Signature found: $SIGN_LINE"

# ---------- 3) Check Git work tree ----------
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  err "This is not a Git repository."
fi

if [ -n "$(git status --porcelain)" ]; then
  git status --porcelain
  err "Git work tree is not clean. Please commit, discard, or ignore all changes before closing the experiment."
fi
info "Git work tree is clean."


# ---------- 54) Switch back to dev ----------
if git show-ref --verify --quiet refs/heads/dev; then
  git checkout dev >/dev/null 2>&1 && info "Switched back to branch: dev" || err "Failed to checkout dev branch."
else
  err "Branch 'dev' does not exist."
fi

echo "[SUCCESS] Experiment ${EXP_ID} closed."

# ---------- 45) Append log ----------
# Extract Aim and Date (first non-empty line after headings)
AIM_LINE=$(grep -n '^##[[:space:]]\+Aim[[:space:]]*$' "$REPORT_FILE" | awk -F: 'NR==1{print $1}')
DATE_LINE=$(grep -n '^##[[:space:]]\+Date[[:space:]]*$' "$REPORT_FILE" | awk -F: 'NR==1{print $1}')

get_next_nonempty_line() {
  local file="$1"; local start_line="$2"
  if [ -z "${start_line:-}" ]; then
    echo ""
    return
  fi
  awk -v s="$start_line" 'NR>s && NF{print; exit}' "$file" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

AIM_VAL="$(get_next_nonempty_line "$REPORT_FILE" "${AIM_LINE:-}")"
DATE_VAL="$(get_next_nonempty_line "$REPORT_FILE" "${DATE_LINE:-}")"

if [ ! -f "$LOG_FILE" ]; then
  echo "# Experiment Log" > "$LOG_FILE"
  echo "" >> "$LOG_FILE"
fi

{
  echo "## Exp ${EXP_ID}"
  echo "- Aim: ${AIM_VAL}"
  echo "- Date: ${DATE_VAL}"
  echo "- Signature: ${SIGN_LINE}"
  echo ""
} >> "$LOG_FILE"

echo "" > "$EXP_FILE"
info "Experiment ${EXP_ID} logged to ${LOG_FILE} and .exp_online cleared."

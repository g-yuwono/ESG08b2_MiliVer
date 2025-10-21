#!/usr/bin/env bash
set -e  # Exit immediately on error

# --- Step 1: Read EXP_ID ---
if [ ! -f ".exp_online" ]; then
    echo "❌ ERROR: '.exp_online' file not found."
    exit 1
fi

EXP_ID=$(cat .exp_online | tr -d '[:space:]')
BASE_DIR="./artifacts/runs_${EXP_ID}"

# --- Step 2: Check if source and target folders exist ---
if [ ! -d "${BASE_DIR}/notebooks" ]; then
    echo "❌ ERROR: Directory '${BASE_DIR}/notebooks' not found."
    exit 1
fi

if [ ! -d "${BASE_DIR}/nbs" ]; then
    echo "❌ ERROR: Directory '${BASE_DIR}/nbs' not found. Please create it manually before running this script."
    exit 1
fi

echo "📁 BASE_DIR = ${BASE_DIR}"
echo "➡️ Copying .py and .ipynb files (excluding .ipynb_checkpoints)..."

# Copy all .py and .ipynb files, excluding .ipynb_checkpoints directories
find "${BASE_DIR}/notebooks" \
    -type d -name ".ipynb_checkpoints" -prune -o \
    -type f \( -name "*.py" -o -name "*.ipynb" \) -print \
    | xargs -I {} cp {} "${BASE_DIR}/nbs/"

# --- Step 3: Convert .ipynb files to .py ---
echo "🪄 Converting .ipynb notebooks to .py scripts..."
for nb in "${BASE_DIR}/nbs"/*.ipynb; do
    if [ -f "$nb" ]; then
        jupyter nbconvert --to script "$nb" --output-dir "${BASE_DIR}/nbs" >/dev/null 2>&1
    fi
done

# --- Step 4: Remove all non-.py files ---
echo "🧹 Removing non-.py files..."
find "${BASE_DIR}/nbs" -type f ! -name "*.py" -delete

echo "✅ Cleanup complete: ${BASE_DIR}/nbs"

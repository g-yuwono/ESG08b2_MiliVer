#!/bin/bash
# ============================================
# Script: update_env.sh
# Purpose: Update environment.yml and requirements.txt
# Author: Your Team
# ============================================

# Exit if any command fails
set -e

# Name of conda environment (edit if different)
ENV_NAME="ESG08b2_MiliVer_Refactor"

echo ">>> Initializing Conda for the script"
source $(conda info --base)/etc/profile.d/conda.sh

echo ">>> Activating conda environment: $ENV_NAME"
conda activate $ENV_NAME

echo ">>> Exporting conda dependencies to environment.yml (history only)"
conda env export --from-history | grep -v "prefix:" > environment.yml

echo ">>> Exporting pip dependencies to requirements.txt"
pip freeze > requirements.txt

echo ">>> Done. Please commit updated files:"
echo "    git add environment.yml requirements.txt"
echo "    git commit -m 'update environment files'"


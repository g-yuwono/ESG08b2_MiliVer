#!/bin/bash
# ============================================
# Script: update_env.sh
# Purpose: Update environment.yml and requirements.txt
# Author: Mike C. Li
# ============================================

# Exit if any command fails
set -e

echo ">>> Please confirm you are in the correct conda environment."
echo -n "Enter the name of the conda environment to update: "
read ENV_NAME
if [ "$ENV_NAME" != "$CONDA_DEFAULT_ENV" ]; then
    echo "Error: You are not in the '$ENV_NAME' conda environment."
    echo "Please activate it using: conda activate $ENV_NAME"
    exit 1
fi

echo ">>> Exporting conda dependencies to environment.yml (history only)"
conda env export --from-history | grep -v "prefix:" > environment.yml

echo ">>> Exporting pip dependencies to requirements.txt"
pip freeze > requirements.txt

echo ">>> Done. Please commit updated files:"
echo "    git add environment.yml requirements.txt"
echo "    git commit -m 'update environment files'"


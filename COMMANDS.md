# Common Commands Handbook

This file collects frequently used commands for Git, DVC, Conda, and HPC.  
Team members can extend it as needed.

---

## 🔹 Git

```bash
# Check current status
git status

# Stage specific files
git add environment.yml requirements.txt

# Commit with message
git commit -m "update environment"

# Push changes to remote
git push

# Pull latest changes
git pull
```

---

## 🔹 Conda & Environment

```bash
# Create environment from environment.yml
conda env create -f environment.yml

# Activate environment
conda activate myproj

# Export environment to environment.yml
conda env export --from-history | grep -v "prefix:" > environment.yml

# Export pip dependencies to requirements.txt
pip freeze > requirements.txt
```

---

## 🔹 Scripts

```bash
# Make update_env.sh executable
chmod +x update_env.sh

# Run environment update script
./update_env.sh
```

---

## 🔹 DVC

```bash
# Initialize DVC
dvc init

# Track a dataset with DVC
dvc add data/raw/big_dataset.csv
git add data/raw/big_dataset.csv.dvc .gitignore
git commit -m "track dataset"

# Push to remote (HPC store)
dvc push

# Pull from remote
dvc pull

# Reproduce pipeline
dvc repro
```

---

## 🔹 HPC (SLURM example)

```bash

```
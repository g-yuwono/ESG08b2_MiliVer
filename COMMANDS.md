# Common Commands Handbook

This file collects frequently used commands for Git, DVC, Conda, and HPC.
Team members can extend it as needed.

---


## Pull from Mike's Github to build a new project
setting your project name
```
export myproj YOUR_PROJECT_NAME
```

pull the repo
```
git clone https://github.com/MichaelChaoLi-cpu/MiliFrame-Template.git
mv MiliFrame-Template $myproj
cd $myproj

git remote rename origin upstream
```

link this folder to your repo
```
git remote add origin REPO_ADD_in_GITHUB.git
git push -u origin main
```

---

## Run from scratch to build a new project
```
conda create -n $myproj python=3.x -y ## please change to the correct version 3.x could be a version like 3.9 0r 3.12
conda activate $myproj ## it is recommended that use you project as the env name

pip install jupytext nbconvert nbformat
pip install pre-commit
pre-commit install

pip install dvc
dvc init
```

### If HPC or Local
HPC
```
dvc remote add -d hpc /home/pj24001881/share/dvc_remote
```

Local
```
dvc remote add -d ANYTHING YOUR/DATA/LOCATION(Another Folder)
```


## Run 
```
conda env create -f environment.yml
conda activate $myproj
git init
pre-commit install
dvc init
```

---

## 🔹 Scripts

```bash
# Make update_env.sh executable
chmod +x update_env.sh

# Run environment update script
./update_env.sh

chmod +x ./script/end_experiment.sh
chmod +x ./script/begin_experiment.sh

# Run for a new experiment
./script/end_experiment.sh 001
./script/begin_experiment.sh
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

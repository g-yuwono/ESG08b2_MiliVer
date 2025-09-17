# README (Before begin, please confirm that you have read and agreed with TEAM_RULE.md)


## Pull
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

## Run from scratch
```
conda create -n myproj python=3.x -y
conda activate myproj

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

## Note:
Once this repo become stable, please remove all this.      
Make your README readable!!!
      
GOOD Luck, Mike!       


# README (Before begin, please confirm that you have read and agreed with TEAM_RULE.md)


## Pull
```
git clone https://github.com/MichaelChaoLi-cpu/MiliFrame-Template.git
mv MiliFrame-Template $myproj
cd $myproj

git remote rename origin upstream
```

```
git remote add origin git@github.com:<teammember-username>/project-stock-prediction.git
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

### If HPC
```
dvc remote add -d hpc /home/pj24001881/share/dvc_remote
```


## Run
```
conda env create -f environment.yml
conda activate myproj
git init
pre-commit install
dvc init
```




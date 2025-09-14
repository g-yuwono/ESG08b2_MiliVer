# Team Collaboration Rules for Jupyter + Git + DVC + HPC

This document defines how our team manages code, notebooks, data, and experiments.
It ensures **reproducibility**, **clarity**, and **efficient collaboration** across our international team.

---

## 1) Repository Structure

```
myproj/
├─ notebooks/         # Source .ipynb (outputs stripped, clean for Git)
├─ nbs/               # Paired .py (percent format, for Git diff/review)
├─ src/               # Reusable Python modules
├─ data/              # Datasets (tracked by DVC, ignored by Git)
├─ artifacts/runs/    # Executed notebooks & run outputs (tracked by DVC)
├─ reports/           # Metrics/plots (tracked by DVC)
├─ params.yaml        # Centralized parameters for experiments
├─ dvc.yaml           # Pipeline definition
├─ environment.yml    # Conda environment definition
├─ .jupytext.toml     # Pairing config for ipynb/py
├─ .pre-commit-config.yaml
└─ .gitignore
```

```
artifacts/runs/<exp_id>/
├─ manifest.json            # Metadata snapshot (commit SHA, environment, dataset hashes)
├─ params.snapshot.yaml     # Exact parameters used for this run
├─ metrics.json             # Final key metrics
├─ metrics_history.csv      # Training/evaluation metrics over time (per epoch/step)
├─ data/                    # Data snapshot (small subset or DVC link, not full raw dataset)
│  ├─ processed_sample.parquet
│  └─ split_info.json
├─ notebooks/               # Notebooks directly related to this run (exploration/preprocessing)
│  ├─ prep_data_exp42.ipynb
│  └─ analysis_exp42.ipynb
├─ model/
│  ├─ checkpoint.pt         # Main model checkpoint
│  └─ tokenizer/            # Tokenizer or vocabulary files if applicable
├─ logs/
│  ├─ train.log             # Training console log
│  ├─ errors.log            # Error/exception log
│  └─ tb/                   # TensorBoard event files
├─ plots/
│  ├─ loss_curve.png        # Training/validation loss curve
│  └─ confusion_matrix.png  # Example evaluation plot
├─ predictions/
│  └─ val_preds.parquet     # Validation predictions for analysis
└─ reports/
   └─ report.md             # Human-readable experiment report (goal, setup, results, insights)
```


---

## 2) Golden Rules

1. **Code → Git**
2. **Data/Outputs → DVC**
3. **Parameters → `params.yaml`**
4. Start an experiment: `./script/begin_experiment.sh ddd`        
5. End an experiment: `./script/end_experiment.sh`     

---

## 3) Git Practices

- Commit paired `.py` files in `nbs/` for readable diffs; keep `notebooks/` outputs stripped via pre-commit.
- Never commit raw datasets or large artifacts to Git.

### Commit Standard
#### Types:
- `feat:` A new feature (e.g., new model, new module, new functionality).
- `fix:` A bug fix (e.g., code error, wrong parameter, pipeline bug).
- `docs:` Documentation changes only (README, docstrings, comments).
- `style:` Code style changes (formatting, indentation, naming) without affecting logic.
- `refactor:` Code refactoring that improves readability/structure but doesn’t change behavior.
- `perf:` Performance improvements (e.g., faster training, memory optimization).
- `test:` Adding or modifying tests.
- `data:` Adding, updating, or cleaning datasets tracked via DVC.
- `exp:` Experiment-related commits (e.g., new run config, changed hyperparameters).
- `build:` Changes to environment setup, dependencies, or build scripts (e.g., environment.yml, Dockerfile).
- `ci:` Changes to CI/CD configuration (e.g., GitHub Actions, pre-commit hooks).
- `chore:` Other maintenance tasks that don’t affect source or data.
- `revert:` Revert a previous commit.

#### Scope
Use to indicate the area affected, e.g.:
model, data, pipeline, notebooks, nbs, docs, infra

#### Summary
Use imperative mood (e.g., “add” not “added” or “adds”).
Keep it concise (≤ 72 characters).

#### Example:
```
feat(model): add custom loss with MSE + regularization
fix(pipeline): correct DVC stage for dataset merge
docs: update README with DVC usage instructions
data: add CMIP6 temperature dataset for 2000–2050
exp: run Experiment 02 with new hyperparameter grid
```


### Core branches

`main`     
- stable, reproducible code + configs. Only “promoted” models land here.  

`dev`    
- integration of recent validated experiments. Can be ahead of main.

Protect main (PR required, CI checks, no direct pushes). Keep dev lightly protected.

### Work branches (short-lived, purpose-driven)

Experiment: `exp/<id>-<topic>`
- For trying ideas & tuning; may be messy.
- Examples: exp/042-longer-context, exp/043-lr-warmup-10k

Spike/Prototype: `spike/<topic>`
- Throwaway exploration; benchmark feasibility; may never merge.
- Example: spike/moe-routing

Feature (productionize a win): `feature/<scope>-<desc>`
- After an experiment proves value; tidy code, add tests/docs.
- Example: feature/model-transformer-encoder

Data Ops: `data/<dataset>-<change>`
- Schema/ingest/cleaning tracked via DVC.
- Example: data/modis-reproj-v1

Hotfix: `hotfix/<issue>-<desc>`
- Urgent fix off main.

Rule of thumb
- New idea? start spike/* → if promising, cut exp/* with proper tracking → once validated, promote via feature/* and merge to dev → release to main.


---

## 4) DVC Practices

- Track large files and executed notebooks with DVC:
  ```bash
  dvc add data/raw/big_dataset.parquet
  git add data/raw/big_dataset.parquet.dvc .gitignore
  git commit -m "track dataset with DVC"
  dvc push
  ```
- Always `dvc push` after adding/updating data/models so collaborators can `dvc pull`.
- Configure shared cache on HPC for group collaboration:
  ```bash
  dvc config cache.shared group
  dvc config cache.type hardlink,symlink
  dvc config cache.protected true
  ```

---

## 5) HPC Remote Storage

- Default DVC remote (edit to your real path):
  ```
  /lustre/share/<your-group>/dvcstore
  ```
- Set it as default once per repo:
  ```bash
  dvc remote add -d hpc /lustre/share/<your-group>/dvcstore
  ```
- Permissions tip (run once, admin or group owner):
  ```bash
  chmod -R g+rwX /lustre/share/<your-group>/dvcstore
  find /lustre/share/<your-group>/dvcstore -type d -exec chmod g+s {} \;
  ```

---

## 6) Notebook Workflow

- Keep **source** notebooks in `notebooks/` (outputs stripped by pre-commit + nbstripout).

- Code Requirement:    
use relative address only, and in the begining of the notebook:
```
import os
from dotenv import load_dotenv

load_dotenv()
os.chdir(os.getenv("PROJECT_ROOT"))
```

- Code Requirement:     
Standard and third-party libraries first    
Internal project imports afterwards      
Absolute imports preferred over relative imports.   
Within each section, sort imports alphabetically    
Put a blank line in between each section  
Separate “from  import ” from standard imports  
Example:  
```
import numpy as np
import os

from my_project.utils import helper_function
```

---

## 7) Experiment Tracking

- Centralize parameters in `params.yaml` and reference them in notebooks.
- Use MLflow to log metrics, params, and artifacts. Always tag the Git commit and (if applicable) the DVC data version.
- Store plots under `reports/` and log them to MLflow; track with DVC if needed for long-term storage.

---

## 8) Collaboration Rhythm

- **Start of day / machine switch**: `git pull && dvc pull`
- **End of session**: `git push && dvc push`
- **Before heavy changes**: branch off `main`
- **After successful run**: save outputs to `artifacts/runs/` and push via DVC

---

## 9) HPC Jobs (SLURM or similar)

- Submit heavy compute via the scheduler; write outputs (logs, metrics, executed notebooks) to a unique `artifacts/runs/<timestamp_label>/`.
- Ensure job scripts exit non-zero on failure so pipelines (e.g., `dvc repro`) can detect errors.

---

## 9) .env: Folder Address
- All notebook should start from
```python
import os
from dotenv import load_dotenv

load_dotenv()
os.chdir(os.getenv("PROJECT_ROOT"))
```

---


## 10) Environment Management

- Create environment:
  ```bash
  conda env create -f environment.yml
  conda activate myproj
  ```
- After changing dependencies:
  ```bash
  conda env export --from-history > environment.yml
  pip freeze > requirements.txt
  git commit -am "update environment"
  ```

---

## 11) Security & Secrets

- Never commit credentials. Use `.env` + a secret manager or HPC-provided key vaults.
- Keep access to `/lustre/share/<your-group>/dvcstore` group-restricted.

---

## 12) Ownership & Maintenance

- The repo owner maintains `main` branch protection, pre-commit config, and DVC remote configuration.
- Each experiment owner documents key runs under `reports/` and ensures `dvc push` is complete.
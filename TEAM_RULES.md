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

---

## 2) Golden Rules

1. **Code → Git**
2. **Data/Outputs → DVC**
3. **Parameters → `params.yaml`**
4. **Experiments → MLflow**
5. **Heavy compute → HPC jobs**

---

## 3) Git Practices

- Commit paired `.py` files in `nbs/` for readable diffs; keep `notebooks/` outputs stripped via pre-commit.
- Never commit raw datasets or large artifacts to Git.
- Use branches for experiments (e.g., `exp-news-sentiment`, `exp-stock-lstm`); merge to `main` after validation.
- Commit message style:
  - `feat: add MODIS preprocessing`
  - `exp: run LSTM for AAPL`
  - `fix: correct date alignment`

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
- To generate an **executed** notebook with outputs, use Papermill and save under `artifacts/runs/<timestamp_label>/`:
  ```bash
  run_id=$(date +"%Y-%m-%d_%H-%M")_train
  outdir=artifacts/runs/$run_id
  mkdir -p "$outdir"
  papermill notebooks/00_example.ipynb "$outdir/00_example_executed.ipynb" -p params_file params.yaml
  dvc add "$outdir"
  git add "$outdir.dvc"
  git commit -m "run: $run_id"
  dvc push
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
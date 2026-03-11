# BRW Sea Duck Incubation Constancy

QA/QC pipeline for Barrow sea duck incubation constancy data.  
Loads Microsoft Access + Excel sources, resolves temporal gaps/overlaps, derives nest fates, and writes a clean SQLite database.
Run brw_qaqc.qmd FIRST to commit data files to memory for downstream analyses. 
---

## Repository structure

```
BRW-Sea-Duck_Incubation_Constancy/
├── brw_qaqc.qmd                          # main QA/QC document (render this)
├── .here                                 # project-root anchor for here::here()
├── README.md
├── data/                                 # ⚠ NOT committed to git (see below)
│   ├── brw_nests_master.xlsx
│   ├── brw_bird_captures_master.xlsx
│   └── BarrowIncConstancy_with2025included_master.accdb
└── outputs/                              # created automatically on first run
    └── brw_qaqc.sqlite                   # pipeline output
```

> **Data files are not tracked in git** (add `data/` to `.gitignore`).  
> Copy them into `data/` manually after cloning.

---

## System requirements

| Requirement | Details |
|---|---|
| **OS** | Windows (Access ODBC driver is Windows-only) |
| **R** | 64-bit, version ≥ 4.2 |
| **Quarto** | Version ≥ 1.4 — <https://quarto.org/docs/get-started/> |
| **Access driver** | Microsoft Access Database Engine 2016 Redistributable, **64-bit** |

### Installing the Access driver

1. Download the **64-bit** installer:  
   <https://www.microsoft.com/en-us/download/details.aspx?id=54920>
2. Run `AccessDatabaseEngine_X64.exe`.
3. Verify in R:

```r
sort(unique(odbc::odbcListDrivers()$name))
# Should include: "Microsoft Access Driver (*.mdb, *.accdb)"
```

> ⚠ **32-bit Office conflict**: if you have 32-bit Microsoft Office installed, the 64-bit ACE driver may refuse to install.  
> Workaround — run from an elevated command prompt:
> ```
> AccessDatabaseEngine_X64.exe /quiet
> ```
> Or uninstall 32-bit Office and reinstall as 64-bit.

---

## R package installation

Install all required packages once:

```r
required_pkgs <- c(
  "odbc", "RODBC", "dplyr", "tidyr", "readr", "readxl",
  "stringr", "lubridate", "janitor", "purrr", "rlang",
  "DBI", "RSQLite", "here"
)
install.packages(required_pkgs)
```

Verify the Access driver is visible to R:

```r
library(odbc)
"Microsoft Access Driver (*.mdb, *.accdb)" %in% odbcListDrivers()$name
# Expected: TRUE
```

---

## Project root anchor

`here::here()` needs a root anchor. The repo includes a `.here` file for this.  
If it is missing, recreate it from the R console (with the repo as working directory):

```r
file.create(".here")
```

Or open/create an RStudio project (`.Rproj`) at the repo root — that works too.

---

## Running the pipeline

### From the terminal (recommended)

```bash
cd BRW-Sea-Duck_Incubation_Constancy
quarto render brw_qaqc.qmd
```

### From RStudio

Open `brw_qaqc.qmd` and click **Render**, or:

```r
quarto::quarto_render("brw_qaqc.qmd")
```

### Output

`outputs/brw_qaqc.sqlite` — four tables:

| Table | Contents |
|---|---|
| `hen_activities_corrected` | Offset-corrected activity rows with gap-resolved timestamps |
| `nests_master_clean` | Nest metadata from `brw_nests_master.xlsx` |
| `qc_overlaps` | Overlap audit (ISO timestamps) |
| `captures_events` | Minimal capture events with ISO datetimes |

---

## Customising parameters

Parameters are declared in the YAML front matter of `brw_qaqc.qmd`.  
Override them at render time without editing the file:

```bash
quarto render brw_qaqc.qmd \
  -P data_dir:data \
  -P gap_abut_threshold_secs:60 \
  -P output_dir:outputs
```

| Parameter | Default | Description |
|---|---|---|
| `data_dir` | `data` | Folder containing input files |
| `nests_master_file` | `brw_nests_master.xlsx` | Nest metadata Excel |
| `capture_master_file` | `brw_bird_captures_master.xlsx` | Capture events Excel |
| `accdb_file` | `BarrowIncConstancy_with2025included_master.accdb` | Access database |
| `tz` | `America/Anchorage` | Timezone applied to all datetimes |
| `output_dir` | `outputs` | Folder for SQLite output |
| `gap_abut_threshold_secs` | `30` | Gaps ≤ this → abutted; gaps > this → `"missing"` row |

---

## Troubleshooting

**`Failed to connect to Access database`**  
→ Confirm the 64-bit ACE driver is installed (see above).  
→ Confirm R is 64-bit: `R.version$arch` should return `"x86_64"`.  
→ Check the `.accdb` path exists: `file.exists(file.path("data", "BarrowIncConstancy_with2025included_master.accdb"))`.

**`here::here()` resolves to the wrong directory**  
→ Ensure `.here` or a `.Rproj` file exists at the repo root.  
→ Restart R and re-render.

**`Auto fate conflict`** error  
→ One or more nests have multiple `fate_*` behavior rows in Hen Activities.  
→ The error message lists the offending `nest_id`s and the conflicting rows — resolve in Access.

# ADNIDOD_MORPHOMETRY

Script 1 : CLEAN_ADNIDOD.R

## Data Preparation and TA/SA Feature Extraction

This section of the workflow imports the dataset, evaluates missing values, identifies morphometry variables, and creates cohort-specific subsets for analysis.

### 1. Load dataset
- Import the ADNI Excel file using **readxl**  
- Store it as a base `data.frame` to ensure compatibility with downstream R functions  

### 2. Audit missing values
- Count missing values per column  
- Calculate the total number and percentage of missing values across the dataset  
- Print a list of columns containing missing values  
- Create a cleaned dataset (`MichelleProjectclean`) by removing any row with missing data (strict listwise deletion)  

### 3. Identify morphometry variables
- Focus on columns 10–152, which contain morphometry features  
- Categorize variables by suffix:  
  - **SA** = columns ending in “SA”  
  - **TA** = columns ending in “TA”  
  - **SA/TA combined** = all columns ending in either “SA” or “TA”  

### 4. Create TA/SA datasets with covariates
- Construct datasets that include:  
  - `COHORT` (group identifier: 2 = TBI, 3 = Control)  
  - Columns 4–8 (independent variables, typically demographics/covariates)  
  - All TA or SA morphometry variables  

### 5. Subset by cohort
- Create separate datasets for each group:  
  - `MP_TAtbi`, `MP_TAcontrol`  
  - `MP_SAtbi`, `MP_SAcontrol`  

### 6. Extract raw TA/SA matrices
- Build TA-only and SA-only matrices from the original dataset (without covariates)  

### 7. Region name mappings
- Use lookup tables (`full_names_TA`, `full_names_SA`) to map coded column names (e.g., `ST102SA`) to human-readable cortical regions (e.g., “Right Paracentral”)  
- These mappings are intended for reports and plots, not for the modeling matrices themselves  

## Outputs produced
- `MichelleProjectclean` → full dataset with NAs removed  
- `MichelleProject_TA`, `MichelleProject_SA` → datasets with covariates  
- `MP_TAtbi`, `MP_TAcontrol`, `MP_SAtbi`, `MP_SAcontrol` → cohort subsets  
- `MichelleProject_TAcodes`, `MichelleProject_SAcodes` → TA/SA only matrices  
- `full_names_TA`, `full_names_SA` → label mappings for reporting

Script 2 : DescriptiveStats_ADNIDOD

# ---------------------------------------------------------------
# 1. PROJECT OVERVIEW
# ---------------------------------------------------------------
# Script Name: Descriptive_Statistics_Morphometry.R
# Purpose:
#   Generates descriptive statistics and visualizations (tables, boxplots)
#   for categorical and continuous morphometry variables (cortical thickness
#   and surface area) across diagnostic cohorts (e.g., TBI vs Control).
# Context of Use:
#   Exploratory data analysis and quality control for neuroimaging datasets.

# ---------------------------------------------------------------
# 2. REPOSITORY STRUCTURE
# ---------------------------------------------------------------
# project_root/
# ├── data/
# │   ├── MichelleProjectclean.csv
# │   ├── MP_TAtbi.csv, MP_TAcontrol.csv
# │   ├── MP_SAtbi.csv, MP_SAcontrol.csv
# │   └── full_names_TA_SA_labels.csv
# ├── scripts/
# │   └── Descriptive_Statistics_Morphometry.R
# ├── outputs/
# │   ├── Descriptive_Statistics_TBI_TA.csv
# │   ├── Descriptive_Statistics_Control_TA.csv
# │   ├── Descriptive_Statistics_TBI_SA.csv
# │   ├── Descriptive_Statistics_Control_SA.csv
# │   └── Boxplots/
# └── docs/
#     └── Data_Dictionary.xlsx

# ---------------------------------------------------------------
# 3. DATA REQUIREMENTS
# ---------------------------------------------------------------
# Primary Dataset: MichelleProjectclean
#   - Includes:
#       * COHORT (integer; 2 = TBI, 3 = Control)
#       * Handedness (categorical)
#       * Columns 10–152: morphometry variables (TA/SA)
# Auxiliary Datasets:
#   - MP_TAtbi, MP_TAcontrol, MP_SAtbi, MP_SAcontrol
#   - full_names_TA, full_names_SA (mappings from codes to full region names)

# ---------------------------------------------------------------
# 4. DEPENDENCIES
# ---------------------------------------------------------------
# R Version: ≥ 4.2.0
# Required Packages:
#   - dplyr     → data manipulation and summaries
#   - tidyr     → reshaping data (pivoting)
#   - ggplot2   → plotting and visualization
#   - utils     → file read/write, View()
#   - stats     → summary statistics (mean, sd, IQR)
# Recommended:
#   - sessioninfo or renv for reproducibility tracking

# ---------------------------------------------------------------
# 5. SCRIPT WORKFLOW
# ---------------------------------------------------------------
# A. Setup
#    - Load packages, disable scientific notation.
# B. Categorical Summaries
#    - Use categorical_summary_clean() to summarize COHORT and Handedness.
# C. Continuous Summaries
#    - Split by cohort (COHORT == 2, COHORT == 3)
#    - Compute mean, sd, median, mode, IQR
# D. Visualization
#    - Base R boxplots and jitter plots by group.
#    - ggplot2 boxplots with mean/SD annotations.
# E. TA/SA Summaries
#    - Repeat analyses separately for thickness (TA) and surface area (SA).
# F. Output
#    - Export descriptive statistics as CSV.
#    - Optionally view interactively via View() in RStudio.

# ---------------------------------------------------------------
# 6. OUTPUTS PRODUCED
# ---------------------------------------------------------------
# Descriptive CSV Files:
#   - Descriptive_Statistics_TBI_TA.csv
#   - Descriptive_Statistics_Control_TA.csv
#   - Descriptive_Statistics_TBI_SA.csv
#   - Descriptive_Statistics_Control_SA.csv
# Combined Data Frames:
#   - combined_desc_stats_TA / combined_desc_stats_SA
# Visuals:
#   - Boxplots comparing TBI vs Control for each region
#   - Jittered individual-level data points

# ---------------------------------------------------------------
# 7. QUALITY CONTROL CHECKLIST
# ---------------------------------------------------------------
# All morphometry columns are numeric.
# COHORT only contains values {2, 3}.
# Group subsets have identical column orders.
# Boxplot scales are consistent across variables.
# Means/SDs fall within biologically plausible ranges.
# Outliers reviewed or documented in QC logs.

# ---------------------------------------------------------------
# 8. REPRODUCIBILITY NOTES
# ---------------------------------------------------------------
# - Save R session info (sessionInfo()) for package versions.
# - Use consistent random seed if introducing sampling.
# - Keep Data_Dictionary.xlsx synced with column updates.
# - Document any code changes or version bumps in CHANGELOG.txt.

# ---------------------------------------------------------------
# 9. CONTACT & AUTHORSHIP
# ---------------------------------------------------------------
# Author: Michelle Eliason, MS, OTR/L
# Affiliation: Buffalo Occupational Therapy / University at Buffalo
# Contact: mcreiner@buffalo.edu
# Citation:
#   Eliason, M. (2025). Descriptive Statistics and Visualization Pipeline
#   for Morphometric Analysis (R Script). 



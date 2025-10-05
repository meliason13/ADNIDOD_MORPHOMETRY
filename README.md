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

# DESCRIPTIVE STATISTICS & VISUALIZATION PIPELINE

## Overview
This section of the workflow generates descriptive statistics and visualizations 
(boxplots and summary tables) for categorical and continuous morphometry variables 
(cortical thickness and surface area) across diagnostic cohorts (e.g., TBI vs Control).  
It supports exploratory data analysis and quality control of morphometric features.

### 1. Data structure
- Primary dataset: `MichelleProjectclean`  
  - Includes:
    - `COHORT` (group identifier: 2 = TBI, 3 = Control)
    - `Handedness` (categorical)
    - Columns 10–152 containing morphometry features (TA/SA)
- Auxiliary datasets:
  - `MP_TAtbi`, `MP_TAcontrol`, `MP_SAtbi`, `MP_SAcontrol` (cohort subsets)
  - `full_names_TA`, `full_names_SA` (lookup tables for descriptive region names)

### 2. Dependencies
- R version ≥ 4.2.0  
- Required packages:
  - `dplyr` – data manipulation and summaries  
  - `tidyr` – reshaping data for visualization  
  - `ggplot2` – boxplots and jitter plots  
  - `utils` and `stats` – file I/O and summary calculations  

### 3. Descriptive statistics
- Summarize categorical variables (`COHORT`, `Handedness`) using `categorical_summary_clean()`  
- Split continuous variables by cohort (`COHORT == 2` or `3`)  
- Compute `mean`, `sd`, `median`, `mode`, and `IQR` for each variable  
- Transpose tables for readability and export as CSV  

### 4. Visualization
- Generate boxplots for each morphometry variable comparing TBI and Control  
- Add jittered data points to visualize within-group spread  
- Create ggplot-based boxplots with annotated mean and SD values  

### 5. TA/SA feature sets
- Run descriptive statistics and plots separately for:
  - Cortical thickness (TA) datasets  
  - Surface area (SA) datasets  
- Combine group-level summaries (`TBI`, `Control`) into unified tables  

### 6. Quality control checks
- Confirm all morphometry variables are numeric  
- Ensure identical variable structure between group subsets  
- Verify COHORT values are restricted to {2, 3}  
- Review distributions and identify outliers as needed  

### 7. Outputs produced
- `Descriptive_Statistics_TBI_TA.csv`  
- `Descriptive_Statistics_Control_TA.csv`  
- `Descriptive_Statistics_TBI_SA.csv`  
- `Descriptive_Statistics_Control_SA.csv`  
- `combined_desc_stats_TA` and `combined_desc_stats_SA` data frames  
- Boxplots visualizing group differences  

### 8. Reproducibility notes
- Save session information using `sessionInfo()`  
- Maintain an updated `Data_Dictionary.xlsx` for all variables  
- Record changes in a `CHANGELOG.txt` file  

### 9. Contact and authorship
- Author: Michelle Eliason, MS, OTR/L  
- Affiliation: Buffalo Occupational Therapy / University at Buffalo  
- Citation:  
  Eliason, M. (2025). *Descriptive Statistics and Visualization Pipeline for Morphometric Analysis (R Script).*

Script 3: NormalityTets_ADNIDOD.R

# ADNIDOD_MORPHOMETRY

Script 3 : NORMALITY_AND_GROUP_COMPARISONS.R

## Purpose
This section evaluates normality assumptions and between-group differences 
(TBI vs. Control) for both independent and morphometric variables.  
It applies Shapiro–Wilk tests for normality, t-tests for parametric comparisons, 
and Mann–Whitney U tests for nonparametric alternatives.

---

### 1. View cleaned dataset
- Confirm contents of `MichelleProjectclean` prior to statistical testing  
  `View(MichelleProjectclean)`

---

### 2. Normality testing for independent variables
- Run Shapiro–Wilk tests across all variables for:
  - `ind_var_tbi` (TBI group)
  - `ind_var_control` (Control group)
- Extract and store test statistics (`W`) and p-values in summary tables
- Combine results for side-by-side comparison (`shapiro_results_combined`)
- View results interactively in RStudio (`View()`)

---

### 3. Group comparison: Independent variables
- Conduct t-test for `MoCA ~ COHORT`  
  - `var.equal = TRUE` assumes equal variances between groups
- Perform Mann–Whitney U tests for nonparametric variables:
  - `Education`, `Age.at.Exam`, `GDS`, and `CAPS`
- Store and print all results in a named list for review

---

### 4. Shapiro–Wilk tests for cortical thickness (TA)
- Remove `COHORT` column from TA group datasets
- Run Shapiro–Wilk tests separately for:
  - `MP_TAtbi_filtered` (TBI)
  - `MP_TAcontrol_filtered` (Control)
- Save each group’s W statistics and p-values into result data frames
  (`shapiro_tbi_dep_results`, `shapiro_control_dep_results`)
- Visualize results via `View()` for quick inspection

---

### 5. Group comparison: Cortical thickness (TA)
- Define a list of TA variables presumed normally distributed (`variables_ta_norm`)
- Loop through each variable:
  - Run independent-samples t-test (`t.test`)
  - Print group means and p-values directly in the console
- Define a separate set of variables for Mann–Whitney U testing (`variables_mw_TA`)
- Loop through each, apply `wilcox.test`, and store results in a list (`mw_results_TA`)

---

### 6. Shapiro–Wilk tests for surface area (SA)
- Filter `MP_SAcontrol` and `MP_SAtbi` to exclude `COHORT`
- Run Shapiro–Wilk tests across all SA variables for each group
- Store test results as:
  - `shapiro_control_dep_results_SA` (Control)
  - `shapiro_tbi_dep_results_SA` (TBI)
- Print and review via `View()` for distribution inspection

---

### 7. Group comparison: Surface area (SA)
- Define a list of SA variables meeting normality assumptions (`variables_ttest_SA`)
- Loop through each variable and run t-tests comparing TBI vs. Control
- Save results in `ttest_results_SA` for later review
- Define nonparametric SA variables (`variables_mw_SA`)
- Loop through and run Mann–Whitney U tests, saving results as `mw_results_SA`

---

### 8. Outputs produced
- `shapiro_results_combined` → summary of normality (TBI vs. Control)
- `shapiro_tbi_dep_results` / `shapiro_control_dep_results` → TA-level normality
- `shapiro_tbi_dep_results_SA` / `shapiro_control_dep_results_SA` → SA-level normality
- `t_test_result` / `ttest_results_SA` → parametric group comparisons
- `mw_results_TA` / `mw_results_SA` → nonparametric group comparisons

---

### 9. Notes and interpretation
- Use p < 0.05 in Shapiro–Wilk to indicate deviation from normality.
- If normality is violated, rely on Mann–Whitney U test instead of t-test.
- t-tests assume independence, normality, and (for `var.equal = TRUE`) equal variances.
- This workflow provides the foundation for subsequent effect-size or 
  correlation analyses across cortical metrics.

---

## Outputs produced
- `shapiro_results_combined` → summary of independent variable normality
- `t_test_result` and Mann–Whitney outputs for independent variables  
- `shapiro_tbi_dep_results`, `shapiro_control_dep_results` → TA normality results  
- `ttest_results_SA`, `mw_results_SA` → surface area group comparisons  
- Ready for import into subsequent modeling or visualization scripts



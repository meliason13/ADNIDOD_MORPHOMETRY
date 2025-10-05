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


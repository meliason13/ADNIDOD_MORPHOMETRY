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

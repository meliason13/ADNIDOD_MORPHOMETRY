# Load Excel-reading package
library("readxl")

# Import the dataset from Excel; use first row as column names
MichelleProject = read_excel("/Users/michelleeliason/Desktop/ADNIDATA_TWO_ME.xlsx", col_names = TRUE)  # read the data


# -----------------------------
# Explore Data and Missing Values
# -----------------------------

# For each column, show a summary of TRUE/FALSE for is.na() (high-level view)
summary(is.na(MichelleProject))

# Count missing values per column
colSums(is.na(MichelleProject))

# Total count of missing values in the entire dataset
total_missing <- sum(is.na(MichelleProject))

# Percentage of missing values out of all cells (rows × columns)
total_missing_percentage <- (total_missing / (nrow(MichelleProject) * ncol(MichelleProject))) * 100

# Print results to console
cat("Total Missing Values:", total_missing, "\n")
cat("Percentage of Missing Values:", round(total_missing_percentage, 2), "%", "\n")


# -----------------------------
# Create a data.frame version and drop rows with any missing values
# -----------------------------

# Ensure base-R data.frame (useful if later code assumes base indexing)
MichelleProject = data.frame(MichelleProject)

# Remove any row that contains at least one NA (strict listwise deletion)
# NOTE: This may substantially reduce sample size if missingness is widespread.
MichelleProjectclean = na.omit(MichelleProject)

# Summarize missing values for each column in the original data (pre-omit)
col_missing <- colSums(is.na(MichelleProject))

# Print only the columns that have at least one missing value
print(col_missing[col_missing > 0])


# -----------------------------
# Identify morphometry variables by suffix
# -----------------------------

# Select the column-name window where your morphometry variables reside
# NOTE: Adjust [10:152] if the dataset schema changes.
variable_names <- colnames(MichelleProjectclean)[10:152]

# All variable names that end with "SA"
MichelleProject_SAnames <- grep("SA$", variable_names, value = TRUE)

# All variable names that end with "SA" or "TA"
MichelleProject_SATAnames <- grep("(SA|TA)$", variable_names, value = TRUE)

# All variable names that end with "TA"
# (Defined after SA to keep TA/SA lists separate)
MichelleProject_TAnames <- grep("TA$", variable_names, value = TRUE)

# Quick checks of the detected sets
head(MichelleProject_SATAnames)
print(MichelleProject_TAnames)


# -----------------------------
# Build TA and SA analysis frames (COHORT + selected IVs + TA/SA variables)
# -----------------------------

# Keep COHORT, a block of independent variables (here columns 4:8), and the TA variables
# NOTE: names(MichelleProjectclean[4:8]) returns the column names at positions 4:8.
#       Ensure these are the intended covariates (and not categorical you plan to exclude).
MichelleProject_TA <- MichelleProjectclean[, c("COHORT", names(MichelleProjectclean[4:8]), MichelleProject_TAnames)]

# Same structure for SA variables
MichelleProject_SA <- MichelleProjectclean[, c("COHORT", names(MichelleProjectclean[4:8]), MichelleProject_SAnames)]

# View column names to confirm structure
colnames(MichelleProject_TA)


# -----------------------------
# Create cohort-specific subsets
# -----------------------------

# TA: TBI cohort (COHORT coded as 2)
MP_TAtbi = MichelleProject_TA[MichelleProject_TA$COHORT == 2, ]

# TA: Control cohort (COHORT coded as 3)
MP_TAcontrol <- MichelleProject_TA[MichelleProject_TA$COHORT == 3, ]

# SA: TBI cohort
MP_SAtbi <- MichelleProject_SA[MichelleProject_SA$COHORT == 2, ]

# SA: Control cohort
MP_SAcontrol <- MichelleProject_SA[MichelleProject_SA$COHORT == 3, ]

# Spot-check output structure/content
colnames(MP_SAcontrol)
print(MP_SAcontrol)


# -----------------------------
# Extract TA/SA code-only matrices from the original data (no covariates)
# -----------------------------

# TA-only columns from the original (pre-omit) dataset
MichelleProject_TAcodes <- MichelleProject[, MichelleProject_TAnames]

# SA-only columns from the original (pre-omit) dataset
MichelleProject_SAcodes <- MichelleProject[, MichelleProject_SAnames]

# (Re-assign variable_names; identical to earlier line, retained as in your script)
variable_names <- colnames(MichelleProjectclean)[10:152]


# -----------------------------
# Region name mappings for SA and TA (for labeling/reporting)
# -----------------------------

# SA mapping: code -> descriptive region (use for tables/figures; do not rename modeling matrices)
full_names_SA <- c(
  "ST102SA" = "Right Paracentral",
  "ST105SA" = "Right Pars Orbitalis",
  "ST108SA" = "Right Postcentral",
  "ST109SA" = "Right Posterior Cingulate",
  "ST110SA" = "Right Precentral",
  "ST111SA" = "Right Precuneus",
  "ST114SA" = "Right Rostral Middle Frontal",
  "ST115SA" = "Right Superior Frontal",
  "ST118SA" = "Right Supramarginal",
  "ST121SA" = "Right Transverse Temporal",
  "ST130SA" = "Right Insula",
  "ST26SA"  = "Left Fusiform",
  "ST28SA"  = "Left Hemisphere WM",
  "ST31SA"  = "Left Inferior Parietal",
  "ST32SA"  = "Left Inferior Temporal",
  "ST34SA"  = "Left Isthmus Cingulate",
  "ST36SA"  = "Left Lateral Orbitofrontal",
  "ST39SA"  = "Left Medial Orbitofrontal",
  "ST40SA"  = "Left Middle Temporal",
  "ST49SA"  = "Left Postcentral",
  "ST50SA"  = "Left Posterior Cingulate",
  "ST51SA"  = "Left Precentral",
  "ST52SA"  = "Left Precuneus",
  "ST54SA"  = "Left Rostral Anterior Cingulate",
  "ST55SA"  = "Left Rostral Middle Frontal",
  "ST56SA"  = "Left Superior Frontal",
  "ST58SA"  = "Left Superior Temporal",
  "ST87SA"  = "Right Hemisphere WM"
)

# TA mapping: code -> descriptive region
# Full names mapping for TA
full_names_TA <- c(
  "ST102TA" = "Right Paracentral",
  "ST104TA" = "Right Pars Opercularis",
  "ST106TA" = "Right Pars Triangularis",
  "ST108TA" = "Right Postcentral",
  "ST111TA" = "Right Precuneus",
  "ST115TA" = "Right Superior Frontal",
  "ST116TA" = "Right Superior Parietal",
  "ST117TA" = "Right Superior Temporal",
  "ST118TA" = "Right Supramarginal",
  "ST119TA" = "Right Temporal Pole",
  "ST121TA" = "Right Transverse Temporal",
  "ST15TA" = "Left Caudal Middle Frontal",
  "ST26TA" = "Left Fusiform",
  "ST31TA" = "Left Inferior Parietal",
  "ST32TA" = "Left Inferior Temporal",
  "ST35TA" = "Left Lateral Occipital",
  "ST36TA" = "Left Lateral Orbitofrontal",
  "ST38TA" = "Left Lingual",
  "ST40TA" = "Left Middle Temporal",
  "ST43TA" = "Left Paracentral",
  "ST45TA" = "Left Pars Opercularis",
  "ST46TA" = "Left Pars Orbitalis",
  "ST49TA" = "Left Postcentral",
  "ST51TA" = "Left Precentral",
  "ST52TA" = "Left Precuneus",
  "ST55TA" = "Left Rostral Middle Frontal",
  "ST56TA" = "Left Superior Frontal",
  "ST57TA" = "Left Superior Parietal",
  "ST58TA" = "Left Superior Temporal",
  "ST59TA" = "Left Supramarginal",
  "ST72TA" = "Right Bankssts",
  "ST74TA" = "Right Caudal Middle Frontal",
  "ST82TA" = "Right Cuneus",
  "ST85TA" = "Right Fusiform",
  "ST90TA" = "Right Inferior Parietal",
  "ST91TA" = "Right Inferior Temporal",
  "ST94TA" = "Right Lateral Occipital",
  "ST95TA" = "Right Lateral Orbitofrontal",
  "ST99TA" = "Right Middle Temporal"
)

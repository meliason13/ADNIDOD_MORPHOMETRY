# ADNIDOD_MORPHOMETRY

#Script 3 : NORMALITY AND GROUP COMPARISONS

## Purpose
# This script tests assumptions of normality (Shapiro–Wilk) and evaluates group
# differences (TBI vs Control) for independent variables and morphometric features
# (cortical thickness = TA; surface area = SA). Parametric (t-test) and 
# nonparametric (Mann–Whitney U) comparisons are both performed.

# ======================================================================
# INITIAL CHECK: VIEW CLEAN DATA
# ======================================================================

# Quickly review cleaned dataset to confirm expected columns and structure
View(MichelleProjectclean)


# ======================================================================
# SHAPIRO–WILK TESTS FOR INDEPENDENT VARIABLES
# ======================================================================

# Run Shapiro–Wilk tests for each independent variable in the TBI group
# `lapply()` applies `shapiro.test()` to every column in `ind_var_tbi`
shapiro_tbi <- lapply(ind_var_tbi, shapiro.test)

# Extract Shapiro–Wilk statistics and p-values into a tidy data frame
shapiro_tbi_results <- data.frame(
  Variable = names(ind_var_tbi),
  Statistic_TBI = sapply(shapiro_tbi, function(x) x$statistic),
  P_Value_TBI = sapply(shapiro_tbi, function(x) x$p.value)
)

# Repeat Shapiro–Wilk testing for the Control group
shapiro_control <- lapply(ind_var_control, shapiro.test)

# Extract statistics and p-values for the Control group
shapiro_control_results <- data.frame(
  Variable = names(ind_var_control),
  Statistic_Control = sapply(shapiro_control, function(x) x$statistic),
  P_Value_Control = sapply(shapiro_control, function(x) x$p.value)
)

# Combine TBI and Control results into a single table for comparison
shapiro_results_combined <- merge(shapiro_tbi_results, shapiro_control_results, by = "Variable")

# Print the combined normality results
print("Shapiro-Wilk Test Results for Normality")
print(shapiro_results_combined)

# Optional: view results in RStudio’s spreadsheet-style viewer
View(shapiro_results_combined)


# ======================================================================
# GROUP COMPARISON: INDEPENDENT VARIABLES
# ======================================================================

# Run independent-samples t-test for MoCA scores by group (TBI vs Control)
# Set `var.equal = TRUE` to assume equal variances between groups
t_test_result <- t.test(MoCA ~ COHORT, data = MichelleProjectclean, var.equal = TRUE)
print(t_test_result)

# Conduct Mann–Whitney U (Wilcoxon rank-sum) tests for nonparametric variables
mw_education <- wilcox.test(Education ~ COHORT, data = MichelleProjectclean, exact = FALSE)
mw_age       <- wilcox.test(Age.at.Exam ~ COHORT, data = MichelleProjectclean, exact = FALSE)
mw_gds       <- wilcox.test(GDS ~ COHORT, data = MichelleProjectclean, exact = FALSE)
mw_caps      <- wilcox.test(CAPS ~ COHORT, data = MichelleProjectclean, exact = FALSE)

# Combine test results into a named list for convenient viewing
list(
  Education = mw_education,
  Age = mw_age,
  GDS = mw_gds,
  CAPS = mw_caps
)


# ======================================================================
# SHAPIRO–WILK TESTS FOR CORTICAL THICKNESS (TA)
# ======================================================================

# Remove COHORT column to retain only morphometry variables
MP_TAtbi_filtered <- MP_TAtbi[, !names(MP_TAtbi) %in% "COHORT"]

# Run Shapiro–Wilk test for each cortical thickness variable in TBI group
shapiro_tbi_dep <- lapply(MP_TAtbi_filtered, shapiro.test)

# Store TBI group normality results in a table
shapiro_tbi_dep_results <- data.frame(
  Variable = names(MP_TAtbi_filtered),
  Statistic_TBI_dep = sapply(shapiro_tbi_dep, function(x) x$statistic),
  P_Value_TBI_dep = sapply(shapiro_tbi_dep, function(x) x$p.value)
)

# Print and view the results
print(shapiro_tbi_dep_results)
View(shapiro_tbi_dep_results)


# Repeat normality testing for cortical thickness in Control group
MP_TAcontrol_filtered <- MP_TAcontrol[, !names(MP_TAcontrol) %in% "COHORT"]
shapiro_control_dep <- lapply(MP_TAcontrol_filtered, shapiro.test)

# Store Control group normality results in a table
shapiro_control_dep_results <- data.frame(
  Variable = names(MP_TAcontrol_filtered),
  Statistic_control_dep = sapply(shapiro_control_dep, function(x) x$statistic),
  P_Value_control_dep = sapply(shapiro_control_dep, function(x) x$p.value)
)

# Print and view Control group results
print(shapiro_control_dep_results)
View(shapiro_control_dep_results)


# ======================================================================
# GROUP COMPARISON: CORTICAL THICKNESS (TA)
# ======================================================================

# Define variables that appear normally distributed (from Shapiro-Wilk results)
variables_ta_norm <- c(
  "ST114TA", "ST105TA", "ST102TA", "ST103TA", "ST104TA", "ST106TA",
  "ST107TA", "ST108TA", "ST109TA", "ST110TA", "ST113TA", "ST129TA",
  "ST130TA", "ST13TA", "ST115TA", "ST117TA", "ST116TA", "ST14TA",
  "ST23TA", "ST15TA", "ST24TA", "ST25TA", "ST31TA", "ST26TA", "ST32TA",
  "ST34TA", "ST36TA", "ST38TA", "ST39TA", "ST43TA", "ST44TA", "ST46TA",
  "ST47TA", "ST48TA", "ST45TA", "ST54TA", "ST52TA", "ST51TA", "ST57TA",
  "ST56TA", "ST58TA", "ST59TA", "ST60TA", "ST55TA", "ST62TA", "ST74TA",
  "ST82TA", "ST72TA", "ST84TA", "ST91TA", "ST93TA", "ST95TA", "ST97TA",
  "ST98TA", "ST99TA"
)

# Loop through each variable and perform independent-samples t-test
for (variable in variables_ta_norm) {
  t_test_result <- t.test(
    MichelleProjectclean[[variable]] ~ MichelleProjectclean$COHORT,
    var.equal = TRUE
  )
  cat(paste("T-Test results for", variable, "\n"))
  print(t_test_result)
  cat("\n")
}

# Define variables that were non-normal for Mann–Whitney testing
variables_mw_TA <- c(
  "ST111TA", "ST119TA", "ST121TA", "ST118TA",
  "ST35TA", "ST40TA", "ST49TA", "ST50TA",
  "ST73TA", "ST83TA", "ST90TA", "ST85TA",
  "ST94TA"
)

# Initialize a list to store nonparametric test results
mw_results_TA <- list()

# Loop through each variable and perform Mann–Whitney U test
for (variable in variables_mw_TA) {
  mw_test_TA <- wilcox.test(
    MichelleProjectclean[[variable]] ~ MichelleProjectclean$COHORT,
    data = MichelleProjectclean,
    exact = FALSE
  )
  mw_results_TA[[variable]] <- mw_test_TA
}

# Print all Mann–Whitney results for TA variables
mw_results_TA


# ======================================================================
# SHAPIRO–WILK TESTS FOR SURFACE AREA (SA)
# ======================================================================

# Remove COHORT column and test normality for Control group SA metrics
MP_SAcontrol_filtered <- MP_SAcontrol[, !names(MP_SAcontrol) %in% "COHORT"]
shapiro_control_dep_SA <- lapply(MP_SAcontrol_filtered, shapiro.test)

shapiro_control_dep_results_SA <- data.frame(
  Variable = names(MP_SAcontrol_filtered),
  Statistic_control_dep_SA = sapply(shapiro_control_dep_SA, function(x) x$statistic),
  P_Value_control_dep_SA = sapply(shapiro_control_dep_SA, function(x) x$p.value)
)

print(shapiro_control_dep_results_SA)
View(shapiro_control_dep_results_SA)


# Repeat for TBI group SA metrics
MP_SAtbi_filtered <- MP_SAtbi[, !names(MP_SAtbi) %in% "COHORT"]
shapiro_tbi_dep_SA <- lapply(MP_SAtbi_filtered, shapiro.test)

shapiro_tbi_dep_results_SA <- data.frame(
  Variable = names(MP_SAtbi_filtered),
  Statistic_tbi_dep_SA = sapply(shapiro_tbi_dep_SA, function(x) x$statistic),
  P_Value_tbi_dep_SA = sapply(shapiro_tbi_dep_SA, function(x) x$p.value)
)

print(shapiro_tbi_dep_results_SA)
View(shapiro_tbi_dep_results_SA)


# ======================================================================
# GROUP COMPARISON: SURFACE AREA (SA)
# ======================================================================

# Define variables meeting normality criteria for t-test comparison
variables_ttest_SA <- c(
  "ST87SA", "ST28SA", "ST102SA", "ST103SA", "ST104SA", "ST105SA",
  "ST106SA", "ST107SA", "ST114SA", "ST116SA", "ST26SA", "ST31SA",
  "ST32SA", "ST34SA", "ST35SA", "ST36SA", "ST38SA", "ST46SA",
  "ST47SA", "ST48SA", "ST50SA", "ST51SA", "ST39SA", "ST40SA",
  "ST43SA", "ST44SA", "ST113SA", "ST119SA", "ST121SA", "ST129SA",
  "ST130SA", "ST52SA", "ST54SA", "ST55SA", "ST56SA", "ST57SA",
  "ST58SA", "ST62SA", "ST13SA", "ST23SA", "ST24SA", "ST25SA",
  "ST109SA", "ST115SA", "ST118SA", "ST111SA", "ST72SA", "ST73SA",
  "ST82SA", "ST83SA", "ST84SA", "ST91SA", "ST94SA", "ST95SA",
  "ST97SA", "ST98SA", "ST99SA", "ST117SA"
)

# Perform t-tests for each normal SA variable
ttest_results_SA <- list()
for (variable in variables_ttest_SA) {
  t_test_SA <- t.test(
    MichelleProjectclean[[variable]] ~ MichelleProjectclean$COHORT,
    var.equal = TRUE
  )
  ttest_results_SA[[variable]] <- t_test_SA
}

# Display all parametric results
ttest_results_SA


# Define variables that were non-normal for Mann–Whitney U testing
variables_mw_SA <- c(
  "ST108SA", "ST110SA", "ST45SA", "ST49SA",
  "ST59SA", "ST60SA", "ST14SA", "ST15SA",
  "ST74SA", "ST85SA", "ST90SA", "ST93SA"
)

# Perform Mann–Whitney U tests for non-normal SA variables
mw_results_SA <- list()
for (variable in variables_mw_SA) {
  mw_test_SA <- wilcox.test(
    MichelleProjectclean[[variable]] ~ MichelleProjectclean$COHORT,
    data = MichelleProjectclean,
    exact = FALSE
  )
  mw_results_SA[[variable]] <- mw_test_SA
}

# Display all nonparametric results for SA
mw_results_SA

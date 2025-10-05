# ===============================================================
# DESCRIPTIVE STATISTICS + VISUALIZATION WORKFLOW (ANNOTATED)
# ---------------------------------------------------------------
# EXPECTED OBJECTS ALREADY IN MEMORY:
# - MichelleProjectclean : data.frame with cohort labels and morphometry cols
#   * Column 'COHORT' uses numeric codes (e.g., 2 = TBI, 3 = Control)
#   * Columns 10:152 are continuous features (e.g., morphometry)
# - MP_TAtbi, MP_TAcontrol : data.frames of TA variables (TBI vs Control)
# - MP_SAtbi, MP_SAcontrol : data.frames of SA variables (TBI vs Control)
# - full_names_TA, full_names_SA : named character vectors that map
#   short variable codes -> human-readable names
#     e.g., full_names_TA["lh_bankssts_TA"] = "Banks of STS (CT, mm)"
#
# NOTE: View() calls open a data viewer in RStudio; they’re safe to remove
# in non-interactive/session scripts.
# ===============================================================

library(dplyr)
library(ggplot2)
library(tidyr)

# Avoid scientific notation in printed outputs (nicer tables/logs)
options(scipen = 999)

# ---------------------------------------------------------------
# 1) DESCRIPTIVE STATS FOR CATEGORICAL VARIABLES
# ---------------------------------------------------------------
# Helper that tabulates counts and row-percentages for each categorical
# variable name you pass in `variables`. It returns a single stacked table.

categorical_summary_clean <- function(data, variables) {
  result <- lapply(variables, function(var) {
    # Defensive check: warn if variable is missing
    if (!var %in% names(data)) {
      warning(sprintf("Variable '%s' not found in data.", var))
      return(data.frame(
        Variable = var, Category = NA, Count = NA, Percentage = NA
      ))
    }
    
    counts <- table(data[[var]], useNA = "ifany")     # frequency table
    percentages <- prop.table(counts) * 100           # row % (0–100)
    
    data.frame(
      Variable   = var,
      Category   = names(counts),
      Count      = as.numeric(counts),
      Percentage = round(as.numeric(percentages), 2),
      row.names  = NULL
    )
  })
  
  # Bind all variable summaries together
  do.call(rbind, result)
}

# Choose which categorical columns to summarize.
# Make sure these exist in MichelleProjectclean.
categorical_vars_clean <- c("COHORT", "Handedness")

# Build and print the summary table
categorical_summary_data_clean <-
  categorical_summary_clean(MichelleProjectclean, categorical_vars_clean)

print(categorical_summary_data_clean)

# ---------------------------------------------------------------
# 2) DESCRIPTIVE STATS FOR CONTINUOUS INDEPENDENT VARIABLES
# ---------------------------------------------------------------
# We split the full dataset by cohort and then summarize columns 10:152.
# Assumes those columns are numeric (continuous morphometry features).

# Filter row subsets by cohort code
ind_var_tbi <- MichelleProjectclean[MichelleProjectclean$COHORT == 2,
                                    names(MichelleProjectclean)[10:152]]

ind_var_control <- MichelleProjectclean[MichelleProjectclean$COHORT == 3,
                                        names(MichelleProjectclean)[10:152]]

# Summaries include mean, sd, median, a simple 'mode' (most frequent value),
# and IQR. Note that 'mode' for continuous data is often not meaningful; we
# include it because it can still be informative for discretized features.
desc_stats_ind_var_tbi <- ind_var_tbi %>%
  summarise(across(everything(), list(
    mean   = ~mean(.x, na.rm = TRUE),
    sd     = ~sd(.x, na.rm = TRUE),
    median = ~median(.x, na.rm = TRUE),
    mode   = ~as.numeric(names(sort(table(.x), decreasing = TRUE)[1])),
    IQR    = ~IQR(.x, na.rm = TRUE)
  )))

# Transpose so each row = variable, each col = stat
desc_stats_t_ind_var_tbi <- as.data.frame(t(desc_stats_ind_var_tbi))

# Same summary for Control
desc_stats_ind_var_control <- ind_var_control %>%
  summarise(across(everything(), list(
    mean   = ~mean(.x, na.rm = TRUE),
    sd     = ~sd(.x, na.rm = TRUE),
    median = ~median(.x, na.rm = TRUE),
    mode   = ~as.numeric(names(sort(table(.x), decreasing = TRUE)[1])),
    IQR    = ~IQR(.x, na.rm = TRUE)
  )))

desc_stats_t_ind_var_control <- as.data.frame(t(desc_stats_ind_var_control))

# ---------------------------------------------------------------
# 3) QUICK LOOK: PRINT/TABLE VIEWS + BASE R BOXPLOTS
# ---------------------------------------------------------------
print("Descriptive Statistics for TBI Group")
print(desc_stats_t_ind_var_tbi)
View(desc_stats_t_ind_var_tbi)

print("Descriptive Statistics for Control Group")
print(desc_stats_t_ind_var_control)
View(desc_stats_t_ind_var_control)

# Base R boxplots per variable comparing TBI vs Control.
# Colors and jitter points help visualize distribution and overlap.
variables <- colnames(ind_var_tbi)  # assume both groups share columns

for (variable in variables) {
  boxplot(
    ind_var_tbi[[variable]], ind_var_control[[variable]],
    names = c("TBI", "Control"),
    col   = c("orange", "yellow"),
    main  = paste(
      "Box Plot for",
      # If a friendly name exists in your mapping vectors, use it; else code.
      ifelse(!is.na(c(full_names_SA, full_names_TA)[variable]),
             unname(c(full_names_SA, full_names_TA)[variable]),
             variable),
      ""
    ),
    ylab  = ifelse(!is.na(c(full_names_SA, full_names_TA)[variable]),
                   unname(c(full_names_SA, full_names_TA)[variable]),
                   variable)
  )
  
  # Jittered raw points for context (TBI = blue, Control = red)
  points(jitter(rep(1, length(ind_var_tbi[[variable]])), amount = 0.1),
         ind_var_tbi[[variable]], col = "blue", pch = 16, cex = 0.7)
  
  points(jitter(rep(2, length(ind_var_control[[variable]])), amount = 0.1),
         ind_var_control[[variable]], col = "red", pch = 16, cex = 0.7)
}

# ---------------------------------------------------------------
# 4) TA (CORTICAL THICKNESS) STATS BY GROUP
# ---------------------------------------------------------------
# Same descriptive pattern, but specifically for TA matrices you’ve already
# created: MP_TAtbi and MP_TAcontrol. These should be numeric-only frames.

desc_stats_tbi_TA <- MP_TAtbi %>%
  summarise(across(everything(), list(
    mean   = ~mean(.x, na.rm = TRUE),
    sd     = ~sd(.x, na.rm = TRUE),
    median = ~median(.x, na.rm = TRUE),
    mode   = ~as.numeric(names(sort(table(.x), decreasing = TRUE)[1])),
    IQR    = ~IQR(.x, na.rm = TRUE)
  )))

desc_stats_t_tbi_TA <- as.data.frame(t(desc_stats_tbi_TA))

desc_stats_control_TA <- MP_TAcontrol %>%
  summarise(across(everything(), list(
    mean   = ~mean(.x, na.rm = TRUE),
    sd     = ~sd(.x, na.rm = TRUE),
    median = ~median(.x, na.rm = TRUE),
    mode   = ~as.numeric(names(sort(table(.x), decreasing = TRUE)[1])),
    IQR    = ~IQR(.x, na.rm = TRUE)
  )))

desc_stats_t_control_TA <- as.data.frame(t(desc_stats_control_TA))

print("Descriptive Statistics for TBI Group")
print(desc_stats_t_tbi_TA); View(desc_stats_t_tbi_TA)

print("Descriptive Statistics for Control Group")
print(desc_stats_t_control_TA); View(desc_stats_t_control_TA)

# Merge TBI + Control TA summaries into one table for side-by-side review.
combined_desc_stats_TA <- cbind(
  Variable = rownames(desc_stats_t_tbi_TA),
  desc_stats_t_tbi_TA,
  desc_stats_t_control_TA
)
rownames(combined_desc_stats_TA) <- NULL

print("Combined Descriptive Statistics for TA")
print(combined_desc_stats_TA)
View(combined_desc_stats_TA)

# Base R boxplots for each TA variable with friendly names where available.
variables <- colnames(MP_TAtbi)

for (variable in variables) {
  boxplot(
    MP_TAtbi[[variable]], MP_TAcontrol[[variable]],
    names = c("TBI", "Control"),
    col   = c("orange", "yellow"),
    main  = paste(
      "Box Plot for",
      ifelse(!is.na(full_names_TA[variable]),
             unname(full_names_TA[variable]),
             variable),
      "(mm)"
    ),
    ylab  = ifelse(!is.na(full_names_TA[variable]),
                   unname(full_names_TA[variable]),
                   variable)
  )
  
  points(jitter(rep(1, length(MP_TAtbi[[variable]])), amount = 0.1),
         MP_TAtbi[[variable]], col = "blue", pch = 16, cex = 0.7)
  
  points(jitter(rep(2, length(MP_TAcontrol[[variable]])), amount = 0.1),
         MP_TAcontrol[[variable]], col = "red", pch = 16, cex = 0.7)
}

# ---------------------------------------------------------------
# 5) TA BOXPLOTS WITH GGPLOT + INLINE MEAN/SD LABELS
# ---------------------------------------------------------------
# Reshape wide -> long so ggplot can facet/iterate cleanly.

MP_TAtbi_long     <- pivot_longer(MP_TAtbi, cols = everything(),
                                  names_to = "Variable_Code", values_to = "Value")
MP_TAcontrol_long <- pivot_longer(MP_TAcontrol, cols = everything(),
                                  names_to = "Variable_Code", values_to = "Value")

# Add group labels and combine
MP_TAtbi_long$Group     <- "TBI"
MP_TAcontrol_long$Group <- "Control"
MP_combined_long        <- bind_rows(MP_TAtbi_long, MP_TAcontrol_long)

# Swap short codes for friendly names when present
MP_combined_long$Variable <- ifelse(
  MP_combined_long$Variable_Code %in% names(full_names_TA),
  full_names_TA[MP_combined_long$Variable_Code],
  MP_combined_long$Variable_Code
)

# Loop each variable, compute per-group mean/SD, and render a plot.
for (var in unique(MP_combined_long$Variable)) {
  
  subset_data <- MP_combined_long %>% filter(Variable == var)
  
  summary_stats <- subset_data %>%
    group_by(Group) %>%
    summarise(
      Mean = mean(Value, na.rm = TRUE),
      SD   = sd(Value, na.rm = TRUE),
      .groups = "drop"
    )
  
  summary_text <- paste0(
    "TBI: Mean = ", round(summary_stats$Mean[summary_stats$Group == "TBI"], 2),
    ", SD = ",   round(summary_stats$SD[summary_stats$Group == "TBI"], 2), "\n",
    "Control: Mean = ", round(summary_stats$Mean[summary_stats$Group == "Control"], 2),
    ", SD = ",         round(summary_stats$SD[summary_stats$Group == "Control"], 2)
  )
  
  plot <- ggplot(subset_data, aes(x = Group, y = Value, fill = Group)) +
    geom_boxplot(alpha = 0.6, outlier.shape = NA) +
    geom_jitter(width = 0.2, size = 1.5, aes(color = Group), alpha = 0.7) +
    annotate("text",
             x = 1.5,
             y = max(subset_data$Value, na.rm = TRUE) * 1.1,  # clears the top
             label = summary_text, size = 5, color = "black", hjust = 0) +
    labs(title = paste("Box Plot for", var),
         x = "Group", y = "Measurement Value") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  print(plot)
}

# ---------------------------------------------------------------
# 6) SA (SURFACE AREA) STATS BY GROUP
# ---------------------------------------------------------------
# Same pipeline for SA matrices. Note: using reframe() here mirrors your code,
# but summarise() would also work and is more typical for scalar summaries.

desc_stats_tbi_SA <- MP_SAtbi %>%
  reframe(across(everything(), list(
    mean   = ~mean(.x, na.rm = TRUE),
    sd     = ~sd(.x, na.rm = TRUE),
    median = ~median(.x, na.rm = TRUE),
    mode   = ~as.numeric(names(sort(table(.x), decreasing = TRUE)[1])),
    IQR    = ~IQR(.x, na.rm = TRUE)
  )))
desc_stats_t_tbi_SA <- as.data.frame(t(desc_stats_tbi_SA))

desc_stats_control_SA <- MP_SAcontrol %>%
  reframe(across(everything(), list(
    mean   = ~mean(.x, na.rm = TRUE),
    sd     = ~sd(.x, na.rm = TRUE),
    median = ~median(.x, na.rm = TRUE),
    mode   = ~as.numeric(names(sort(table(.x), decreasing = TRUE)[1])),
    IQR    = ~IQR(.x, na.rm = TRUE)
  )))
desc_stats_t_control_SA <- as.data.frame(t(desc_stats_control_SA))

print("Descriptive Statistics for TBI Group");     print(desc_stats_t_tbi_SA)
print("Descriptive Statistics for Control Group"); print(desc_stats_t_control_SA)

# Side-by-side SA table
combined_desc_stats_SA <- cbind(
  Variable = rownames(desc_stats_t_tbi_SA),
  desc_stats_t_tbi_SA,
  desc_stats_t_control_SA
)
rownames(combined_desc_stats_SA) <- NULL

print("Combined Descriptive Statistics for TA")  # label says TA; content is SA
print(combined_desc_stats_SA)
View(combined_desc_stats_SA)

# Base R SA boxplots with friendly names if available
variables <- colnames(MP_SAtbi)

for (variable in variables) {
  boxplot(
    MP_SAtbi[[variable]], MP_SAcontrol[[variable]],
    names = c("TBI", "Control"),
    col   = c("orange", "yellow"),
    main  = paste(
      "Box Plot for",
      ifelse(!is.na(full_names_SA[variable]),
             unname(full_names_SA[variable]),
             variable),
      "(mm²)"
    ),
    ylab  = ifelse(!is.na(full_names_SA[variable]),
                   unname(full_names_SA[variable]),
                   variable)
  )
  
  points(jitter(rep(1, length(MP_SAtbi[[variable]])), amount = 0.1),
         MP_SAtbi[[variable]], col = "blue", pch = 16, cex = 0.7)
  
  points(jitter(rep(2, length(MP_SAcontrol[[variable]])), amount = 0.1),
         MP_SAcontrol[[variable]], col = "red", pch = 16, cex = 0.7)
}

# ---------------------------------------------------------------
# 7) EXPORT: WRITE SUMMARY TABLES TO CSV
# ---------------------------------------------------------------
# Useful for supplement tables or sharing stats with collaborators.

write.csv(desc_stats_t_tbi_TA,     "Descriptive_Statistics_TBI_TA.csv",     row.names = TRUE)
write.csv(desc_stats_t_control_TA, "Descriptive_Statistics_Control_TA.csv", row.names = TRUE)
write.csv(desc_stats_t_tbi_SA,     "Descriptive_Statistics_TBI_SA.csv",     row.names = TRUE)
write.csv(desc_stats_t_control_SA, "Descriptive_Statistics_Control_SA.csv", row.names = TRUE)

# ===============================================================
# END OF SCRIPT
# ---------------------------------------------------------------
# QUICK QA IDEAS (OPTIONAL):
# - assertthat::assert_that(all(sapply(MichelleProjectclean[10:152], is.numeric)))
# - check for equal column sets between group data.frames
# - consider winsorization or outlier inspection if distributions are skewed
# ===============================================================


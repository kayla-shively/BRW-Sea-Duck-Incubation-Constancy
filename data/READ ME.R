
# Sea Duck Incubation Constancy Analysis

# 1. Open `sea_duck_incubation.qmd` in RStudio.

# 2. Make sure the CSVs in `data/` have these names:
#   - hen_activities_final_20251201.csv
#   - nests_final_20251201.csv
#   - barrow_ghcnd_daily.csv

# 3. If you want to use different files, edit the paths under `params:` at the top of the .qmd.

# 4. install required packages
install.packages(c(
  "tidyverse","lubridate","knitr","kableExtra","gt","xfun",
  "rstatix","coin","patchwork","gridExtra","glmmTMB","performance",
  "purrr","broom","glue","car","cowplot","broom.mixed","DHARMa","FSA",
  "tidyr","gtable","scales","dplyr","tibble","ggh4x","lmerTest","MuMIn"
))

# 5. Click "Render" to generate the HTML report.
